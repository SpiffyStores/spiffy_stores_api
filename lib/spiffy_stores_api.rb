$:.unshift File.dirname(__FILE__)

require 'active_resource'
require 'active_support/core_ext/class/attribute_accessors'
require 'digest/md5'
require 'base64'
require 'active_resource/detailed_log_subscriber'
require 'spiffy_stores_api/limits'
require 'spiffy_stores_api/json_format'
require 'active_resource/json_errors'
require 'active_resource/disable_prefix_check'
require 'active_resource/base_ext'
require 'active_resource/to_query'

module SpiffyStoresAPI
  include Limits
end

require 'spiffy_stores_api/metafields'
require 'spiffy_stores_api/countable'
require 'spiffy_stores_api/resources'
require 'spiffy_stores_api/session'
require 'spiffy_stores_api/connection'

if SpiffyStoresAPI::Base.respond_to?(:connection_class)
  SpiffyStoresAPI::Base.connection_class = SpiffyStoresAPI::Connection
else
  require 'active_resource/connection_ext'
end
