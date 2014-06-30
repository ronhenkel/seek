#DO NOT EDIT THIS FILE TO CHANGE SETTINGS. THESE ARE ONLY USED TO PRE-POPULATE THE DEFAULT VALUES.
#CHANGE THESE VALUES THROUGH THE ADMIN PAGES WHILST RUNNING SEEK.
require 'seek/config'
require 'seek/seek_render_override'

SEEK::Application.configure do
  #Main settings
  Seek::Config.default :public_seek_enabled,true
  Seek::Config.default :sycamore_enabled,false
  Seek::Config.default :events_enabled,true
  Seek::Config.default :jerm_enabled,false
  Seek::Config.default :email_enabled,false
  Seek::Config.default :smtp, {:address => '', :port => '25', :domain => '', :authentication => :plain, :user_name => '', :password => '', :enable_starttls_auto=>false}
  Seek::Config.default :noreply_sender, 'no-reply@sysmo-db.org'
  Seek::Config.default :solr_enabled,false
  Seek::Config.default :jws_enabled, true
  Seek::Config.default :jws_online_root,"https://jws.sysmo-db.org/"
  Seek::Config.default :sabiork_ws_base_url, "http://sabiork.h-its.org/sabioRestWebServices/"
  Seek::Config.default :exception_notification_enabled,false
  Seek::Config.default :exception_notification_recipients,""
  Seek::Config.default :hide_details_enabled,false
  Seek::Config.default :activation_required_enabled,false
  Seek::Config.default :google_analytics_enabled, false
  Seek::Config.default :google_analytics_tracker_id, '000-000'
  Seek::Config.default :piwik_analytics_enabled, false
  Seek::Config.default :piwik_analytics_id_site, 1
  Seek::Config.default :piwik_analytics_url, 'localhost/piwik/'
  Seek::Config.default :bioportal_api_key,''
  Seek::Config.default :project_news_enabled,false
  Seek::Config.default :project_news_feed_urls,''
  Seek::Config.default :project_news_number_of_entries,10
  Seek::Config.default :community_news_enabled,false
  Seek::Config.default :community_news_feed_urls,''
  Seek::Config.default :community_news_number_of_entries,10
  Seek::Config.default :home_description, 'You can configure the text that goes here within the Admin pages: Site Configuration->Home page settings.'
  Seek::Config.default :tagline_prefix, 'Find, share and exchange <b>Data</b>, <b>Models</b> and <b>Processes</b> within the'
  Seek::Config.default :publish_button_enabled, true
  Seek::Config.default :auth_lookup_enabled,true
  Seek::Config.default :sample_parser_enabled,false
  Seek::Config.default :external_search_enabled, true
  Seek::Config.default :project_browser_enabled,false
  Seek::Config.default :experimental_features_enabled,false
  Seek::Config.default :pdf_conversion_enabled,true
  Seek::Config.default :delete_asset_version_enabled, false
  Seek::Config.default :forum_enabled,false
  Seek::Config.default :filestore_path,"filestore"
  Seek::Config.default :biosamples_enabled, true
  Seek::Config.default :modelling_analysis_enabled,true
  Seek::Config.default :organisms_enabled,true
  Seek::Config.default :models_enabled,true
  Seek::Config.default :guide_box_enabled,true
  Seek::Config.default :treatments_enabled,true
  Seek::Config.default :factors_studied_enabled,true
  Seek::Config.default :experimental_conditions_enabled,true
  Seek::Config.default :tagging_enabled, true
  Seek::Config.default :workflows_enabled,false
  Seek::Config.default :authorization_checks_enabled, true
  Seek::Config.default :documentation_enabled,true
  Seek::Config.default :assay_type_ontology_file, "JERM-RDFXML.owl"
  Seek::Config.default :technology_type_ontology_file, "JERM-RDFXML.owl"
  Seek::Config.default :modelling_analysis_type_ontology_file, "JERM-RDFXML.owl"
  Seek::Config.default :assay_type_base_uri,"http://www.mygrid.org.uk/ontology/JERMOntology#Experimental_assay_type"
  Seek::Config.default :technology_type_base_uri,"http://www.mygrid.org.uk/ontology/JERMOntology#Technology_type"
  Seek::Config.default :modelling_analysis_type_base_uri,"http://www.mygrid.org.uk/ontology/JERMOntology#Model_analysis_type"
  Seek::Config.default :profile_select_by_default,true
  Seek::Config.default :programmes_enabled, true

  Seek::Config.default :header_tagline_text_enabled, true

#time in minutes that the feeds on the front page are cached for
  Seek::Config.default :home_feeds_cache_timeout,2

# Branding
  Seek::Config.default :project_name,'SysMO'
  Seek::Config.default :project_type,'Consortium'
  Seek::Config.default :project_link,'http://www.sysmo.net'

  Seek::Config.default :application_name,"SEEK"
  Seek::Config.default :dm_project_name,"SysMO-DB"
  Seek::Config.default :dm_project_link,"http://www.sysmo-db.org"
  Seek::Config.default :header_image_enabled,true
  Seek::Config.default :header_image_title, "SysMO-DB"
  Seek::Config.default :header_image_link,"http://www.sysmo-db.org"
  Seek::Config.default :header_image,'sysmo-db-logo_smaller.png'
  Seek::Config.default :header_home_logo_image,'seek-logo-smaller.png'
  Seek::Config.default :copyright_addendum_enabled,false
  Seek::Config.default :copyright_addendum_content,'Additions copyright ...'

  Seek::Config.default :is_virtualliver, false

# Pagination
  Seek::Config.default :default_pages,{:specimens => 'latest',:samples => 'latest', :people => 'latest', :projects => 'latest', :institutions => 'latest', :investigations => 'latest',:studies => 'latest', :assays => 'latest', :data_files => 'latest', :models => 'latest',:sops => 'latest', :publications => 'latest',:events => 'latest', :strains => 'latest', :presentations => 'latest'}
  Seek::Config.default :limit_latest,7

  Seek::Config.default :related_items_limit,5

# Others
  Seek::Config.default :type_managers_enabled,true
  Seek::Config.default :type_managers,'admins'
  Seek::Config.default :tag_threshold,1
  Seek::Config.default :max_visible_tags,20
  Seek::Config.default :pubmed_api_email,nil
  Seek::Config.default :crossref_api_email,nil
  Seek::Config.default :site_base_host,"http://localhost:3000"
  Seek::Config.default :open_id_authentication_store,:memory

  Seek::Config.default :max_attachments_num,100

  Seek::Config.default :datacite_url,"https://mds.datacite.org/"

  #MERGENOTE - why are these here? they should be in the database under the Scale model. Maybe an old relic
  Seek::Config.default :scales,["organism","liver","liverLobule","intercellular","cell"]

  #magic guest is a special user required by BioVel, where a logged out user adopts a special guest user, but still appears to be logged out
  Seek::Config.default :magic_guest_enabled,false

  Seek::Config.default :recaptcha_enabled, true

  Seek::Config.default :seek_video_link, "http://www.youtube.com/user/elinawetschHITS?feature=mhee#p/u"

  Seek::Config.fixed :css_prepended,''
  Seek::Config.fixed :css_appended,''
  Seek::Config.fixed :main_layout,'application'

end

