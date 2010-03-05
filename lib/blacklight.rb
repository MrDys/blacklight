module Blacklight
  
  autoload :CoreExt, 'blacklight/core_ext.rb'
  # load up the CoreExt by referencing it:
  CoreExt
  
  module Controller
    autoload :Application, 'blacklight/controller/application'
    autoload :Bookmarks, 'blacklight/controller/bookmarks'
    autoload :Catalog, 'blacklight/controller/catalog'
    autoload :Feedback, 'blacklight/controller/feedback'
    autoload :SavedSearches, 'blacklight/controller/saved_searches'
    autoload :SearchHistory, 'blacklight/controller/search_history'
  end
  
  module Helper
    autoload :Application, 'blacklight/helper/application'
    autoload :Bookmarks, 'blacklight/helper/bookmarks'
    autoload :Catalog, 'blacklight/helper/catalog'
    autoload :Feedback, 'blacklight/helper/feedback'
    autoload :SavedSearches, 'blacklight/helper/saved_searches'
    autoload :SearchHistory, 'blacklight/helper/search_history'
  end
  
  autoload :Configurable, 'blacklight/configurable'
  autoload :SearchFields, 'blacklight/search_fields'

  autoload :Solr, 'blacklight/solr.rb'
  autoload :Marc, 'blacklight/marc.rb'
  
  autoload :SolrHelper, 'blacklight/solr_helper'
  
  autoload :Routes, 'blacklight/routes'
  
  extend Configurable
  extend SearchFields
  
  class << self
    attr_accessor :solr, :solr_config
  end
  
  # The configuration hash that gets used by RSolr.connect
  @solr_config ||= {}
  
  def self.init
    
    solr_config = YAML::load(File.open("#{RAILS_ROOT}/config/solr.yml"))
    raise "The #{RAILS_ENV} environment settings were not found in the solr.yml config" unless solr_config[RAILS_ENV]
    
    Blacklight.solr_config[:url] = solr_config[RAILS_ENV]['url']
    
    if Gem.available? 'curb'
      require 'curb'
      Blacklight.solr = RSolr::Ext.connect(Blacklight.solr_config.merge(:adapter=>:curb))
    else
      Blacklight.solr = RSolr::Ext.connect(Blacklight.solr_config)
    end
    
    # set the SolrDocument.connection to Blacklight.solr
    SolrDocument.connection = Blacklight.solr
    
    logger.info("BLACKLIGHT: initialized with Blacklight.solr_config: #{Blacklight.solr_config.inspect}")
    logger.info("BLACKLIGHT: initialized with Blacklight.solr: #{Blacklight.solr.inspect}")
    logger.info("BLACKLIGHT: initialized with Blacklight.config: #{Blacklight.config.inspect}")
    
  end

  def self.logger
    RAILS_DEFAULT_LOGGER
  end
  
  # returns the full path the the blacklight plugin installation
  def self.root
    @root ||= File.expand_path File.join(__FILE__, '..', '..')
  end
  
  # Searches Rails.root then Blacklight.root for a valid path
  # returns a full path if a valid path is found
  # returns nil if nothing is found.
  # First looks in Rails.root, then Blacklight.root
  #
  # Example:
  # full_path_to_solr_marc_jar = Blacklight.locate_path 'solr_marc', 'SolrMarc.jar'
  
  def self.locate_path *subpath_fragments
    subpath = subpath_fragments.join('/')
    base_match = [Rails.root, Blacklight.root].find do |base|
      File.exists? File.join(base, subpath)
    end
    File.join(base_match.to_s, subpath) if base_match
  end
  
end