require 'bundler/setup'

config = YAML::load(File.open(File.expand_path("../configuration.yml", __FILE__)))
AMAZON_KEY           = config['aws']['key']
AMAZON_SECRET        = config['aws']['secret']
AMAZON_ASSOCIATE_TAG = config['aws']['associate_tag']
AMAZON_SEARCH_INDEX  = config['aws']['search_index']
AMAZON_KEYWORDS      = config['aws']['keywords']
COUCHDB_SERVER       = config['couchdb']['couch']
COUCHDB              = config['couchdb']['db']