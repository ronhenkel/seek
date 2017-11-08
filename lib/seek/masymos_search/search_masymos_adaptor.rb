require 'search_biomodel'

module Seek
  module MasymosSearch
    class SearchMasymosAdaptor < AbstractSearchAdaptor
      def perform_search(query)
        Rails.cache.clear #DEV only
        yaml = Rails.cache.fetch("masymos_search_#{URI.encode(query)}", expires_in: 1.second) do
          #masymos_json_result = JSON.load `curl -X POST http://139.30.4.72:7474/morre/query/model_query/ -H 'Content-Type: application/json' -d '{"keyword":"cell"}'`

          uri = URI('http://139.30.4.72:7474/morre/query/model_query/')
          req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
          req.body = {keyword: query}.to_json
          res = Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.request(req)
          end

          masymos_json_result = JSON.parse(res.body)
#          puts "!!!!!!!!!!!!!!!!!!!!!!!Body for Query #{query}"
#          puts masymos_json_result
          masymos_search_results = masymos_json_result.each do |result|
            !(result.nil?)
          end

         results = masymos_search_results.collect do |result|
            r = MasymosSearchResult.new(result["modelName"], result["modelID"],
                                      result["documentID"], result["filename"])


          end.compact
          results.to_yaml
        end
        YAML.load(yaml)

      end
#        yaml = Rails.cache.fetch("masymos_search_#{URI.encode(query)}", expires_in: 1.day) do
#          connection = SysMODB::SearchBiomodel.instance
#          masymos_search_results = connection.models(query).select do |result|
#            !(result.nil? || result[:publication_id].nil?)
#          end
#          results = masymos_search_results.collect do |result|
#            r = MasymosSearchResult.new result
#          end.compact.select do |masymos_result|
#            !masymos_result.title.blank?
#          end
#          results.to_yaml
#        end


=begin
      def fetch_item(item_id)
        yaml = Rails.cache.fetch("masymos_search_#{item_id}") do
          connection = SysMODB::SearchBiomodel.instance
          masymos_result = connection.getSimpleModel(item_id)
          unless masymos_result.blank?
            hash_result = Nori.parse(masymos_result)[:simple_models][:simple_model]
          end

          unless hash_result[:publication_id].nil?
            result = MasymosSearchResult.new hash_result
            result = result.title.blank? ? nil : result
          else
            result = nil
          end
          result.to_yaml
        end

        YAML.load(yaml)
      end
=end
    end

    class MasymosSearchResult < Struct.new(:authors, :abstract, :title, :published_date, :publication_id, :publication_title, :model_id, :last_modification_date)
      include Seek::ExternalSearchResult

      alias_attribute :id, :model_id

#      def initialize(masymos_search_result)
      def initialize(modelName, modelID, documentURI, filename)
        self.authors = []
        self.model_id = modelID
        self.last_modification_date = ''#filename #masymos_search_result[:last_modification_date]
        self.publication_id = documentURI #masymos_search_result[:publication_id]
        self.title = modelName
        #populate
      end
=begin
      private

      def populate
        if publication_id_is_doi?
          populate_from_doi
        else
          populate_from_pubmed
        end
      end

      def populate_from_doi
        query_result = Rails.cache.fetch("biomodels_doi_fetch_#{publication_id}", expires_in: 1.week) do
          query = DOI::Query.new(Seek::Config.crossref_api_email)
          result = query.fetch(publication_id)
          hash = {}
          hash[:published_date] = result.date_published
          hash[:title] = result.title
          hash[:authors] = result.authors.collect(&:name)
          hash
        end

        self.published_date = query_result[:published_date]
        self.title ||= query_result[:title]
        self.publication_title = query_result[:title]
        self.authors = query_result[:authors]
      end

      def populate_from_pubmed
        query_result = Rails.cache.fetch("biomodels_pubmed_fetch_#{publication_id}", expires_in: 1.week) do
          begin
            result = Bio::MEDLINE.new(Bio::PubMed.efetch(publication_id).first).reference
          rescue Exception => e
            result = Bio::MEDLINE.new('').reference
          end
          hash = {}
          hash[:abstract] = result.abstract
          hash[:title] = result.title
          hash[:published_date] = result.published_date
          hash[:authors] = result.authors.collect { |a| a.name.to_s }
          hash
        end
        self.abstract = query_result[:abstract]
        self.published_date = query_result[:published_date]
        self.title ||= query_result[:title]
        self.publication_title = query_result[:title]
        self.authors = query_result[:authors]
      end

      def publication_id_is_doi?
        publication_id.include?('.')
      end
=end
    end
  end
end
