module SpiffyStoresAPI
  class Transaction < Base
    include DisablePrefixCheck

    conditional_prefix :order
  end
end
