require 'spiffy_stores_api/connection'

module ActiveResource
  class Connection
    attr_reader :response

    prepend SpiffyStoresAPI::Connection::ResponseCapture
    prepend SpiffyStoresAPI::Connection::RequestNotification
  end
end
