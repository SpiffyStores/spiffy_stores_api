module SpiffyStoresAPI
  class Event < Base
    include DisablePrefixCheck

    conditional_prefix :resource, true
  end
end
