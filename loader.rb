#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require 'amazon_product'
require 'json'
require 'couchrest'

require File.expand_path('../helper.rb', __FILE__)

# Check configuration
if COUCHDB_SERVER.nil?
  raise RuntimeError, "Loader requires a CouchDB server url in the configuration.yml file."
end
if COUCHDB.nil?
  raise RuntimeError, "Loader requires a CouchDB db name in the configuration.yml file."
end
if AMAZON_KEY.nil?
  raise RuntimeError, "Loader requires an AWS Key in the configuration.yml file."
end
if AMAZON_SECRET.nil?
  raise RuntimeError, "Loader requires an AWS Secret in the configuration.yml file."
end
if AMAZON_ASSOCIATE_TAG.nil?
  raise RuntimeError, "Loader requires a AWS Associate ID in the configuration.yml file."
end
if AMAZON_SEARCH_INDEX.nil?
  raise RuntimeError, "Loader requires an AMAZON Product Advertising Search Index in the configuration.yml file."
end
if AMAZON_KEYWORDS.nil?
  raise RuntimeError, "Loader requires AMAZON Product Advertising Keywords in the configuration.yml file."
end

req = AmazonProduct["de"]

req.configure do |c|
  c.key    = AMAZON_KEY
  c.secret = AMAZON_SECRET
  c.tag    = AMAZON_ASSOCIATE_TAG
end

# Load Products from Amazon
# req << { :operation    => 'ItemSearch',
#          :search_index => 'Books',
#          :power        => 'author:geisler',
#          :keywords     => 'Semantic Web' }
req << { :operation    => 'ItemSearch',
         :search_index => AMAZON_SEARCH_INDEX,
         :keywords     => AMAZON_KEYWORDS }
resp = req.get

#puts resp.to_hash.to_json
#puts resp['Item'].to_json

# Connect to CouchDB
couch = CouchRest.new(URI.escape(COUCHDB_SERVER))
@db = couch.database(URI.escape(COUCHDB))

# Save Products in CouchDB Documents
if(resp.valid? && !resp.has_errors?)
  resp.each('Item') do |item|
    @db.save_doc({
      'sku' => item['ASIN'],
      'title' => item['ItemAttributes']['Title'],
      'url' => item['DetailPageURL'],
      'attributes' => item['ItemAttributes'],
      'links' => item['ItemLinks']
    })
  end
end