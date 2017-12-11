class ReindexingJob < SeekJob
  BATCHSIZE = 100

  include Rails.application.routes.url_helpers

  def perform_job(item)

    if item.respond_to?(:content_blobs) || item.respond_to?(:content_blob)
      blobs = item.respond_to?(:content_blobs) ? item.content_blobs: [item.content_blob]
      blobs.each do |blob|
        if blob.content_type == "text/xml"
          add_to_masymos(item)
        end
      end
    end


    if Seek::Config.solr_enabled
      item.solr_index!
    end
  end

  def gather_items
    ReindexingQueue.order('id ASC').limit(BATCHSIZE).collect do |queued|
      take_queued_item(queued)
    end.uniq.compact
  end

  def default_priority
    2
  end

  def follow_on_job?
    ReindexingQueue.count > 0 && !exists?
  end

  def add_items_to_queue(items, time = default_delay.from_now, priority = default_priority)
    items = Array(items)
    puts "!!!!!!!!!!!!!!!!!!!!!!!Added MasyMos Item to queue"


    disable_authorization_checks do
      items.uniq.each do |item|

        path = polymorphic_path(item, action: :download)
        puts "!!!!!!!!!!!!!Path: #{path}"
        download_url = "http://localhost:3000#{path}"
        puts "!!!!!!!!!!!!!URL: #{download_url}"
        uri = URI('http://localhost:7474/morre/model_update_service/add_model/')
        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        #req.body = {fileId: "aa", url:item.model_version_url, modelType:"SBML"}.to_json
        req.body = {fileId: download_url, url:download_url, modelType:'SBML'}.to_json
        puts "!!!!!!!!!!!!!Path: #{uri.to_json}"
        puts "!!!!!!!!!!!!!Request: #{req.to_json}"
        puts "!!!!!!!!!!!!!Body: #{req.body}"


        #add_to_masymos(item)
        ReindexingQueue.create item: item
      end
    end
    queue_job(priority, time) unless exists?
  end

  def add_to_masymos(item)
    path = polymorphic_path(item, action: :download)
    download_url = "http://localhost:3000#{path}"
    uri = URI('http://localhost:7474/morre/model_update_service/add_model/')
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    #req.body = {fileId: "aa", url:item.model_version_url, modelType:"SBML"}.to_json
    req.body = {fileId: download_url, url:download_url, modelType:'SBML'}.to_json
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    #masymos_json_result = JSON.load `curl -X POST http://localhost:7474/morre/model_update_service/add_model -H 'Content-Type: application/json' -d '{"fileId":"http://localhost:3000/models/22/download","url":"http://localhost:3000/models/22/download","modelType":"SBML"}'`
    #IO.write('/home/x.txt',res.body.to_json)
    #masymos_json_result = JSON.parse(res.body)
    #puts "!!!!!!!!!!!!!!!!!!!!!!!Response: #{masymos_json_result}"
  end

  def delete_from_masymos(item)
    puts "!!!!!!!!!!!!!!!!!!!!!!!Starting delete Model MasyMos"
    puts "Item: #{item.to_json}"
    uri = URI('http://139.30.4.72:7474/morre/model_update_service/delete_model/')
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    #req.body = {fileID: "aa", url:item.model_version_url, modelType:"SBML"}.to_json
    req.body = {url:"http://www.ebi.ac.uk/biomodels-main/download?mid=BIOMD0000000005", uuID:"00000"}.to_json
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    masymos_json_result = JSON.parse(res.body)
    puts "!!!!!!!!!!!!!!!!!!!!!!!Response: #{masymos_json_result}"
  end
end
