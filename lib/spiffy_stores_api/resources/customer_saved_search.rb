require 'spiffy_stores_api/resources/customer'

module SpiffyStoresAPI
  class CustomerSavedSearch < Base
    def customers(params = {})
      Customer.search(params.merge({:saved_search_id => self.id}))
    end
  end
end
