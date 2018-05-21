module SpiffyStoresAPI
  # Store object. Use Store.current to retrieve the store settings.
  class Store < Base
    def self.current(options={})
      find(:one, options.merge({from: "/api/store.#{format.extension}"}))
    end

    def metafields
      Metafield.find(:all)
    end

    def add_metafield(metafield)
      raise ArgumentError, "You can only add metafields to resource that has been saved" if new?
      metafield.save
      metafield
    end

    def events
      Event.find(:all)
    end
  end
end
