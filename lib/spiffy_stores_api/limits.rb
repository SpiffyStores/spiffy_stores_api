module SpiffyStoresAPI
  module Limits
    class LimitUnavailable < StandardError; end

    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods

      # The ratelimit header comes from rack-ratelimit
      # The parameters provided are
      # name
      # period
      # limit
      # remaining
      # until
      # {"name":"API","period":300,"limit":500,"remaining":496,"until":"2014-11-28T03:45:00Z"}
      CREDIT_LIMIT_HEADER_PARAM = {
        :store => 'http_x_ratelimit'
      }

      ##
      # How many more API calls can I make?
      # @return {Integer}
      #
      def credit_left
        credit_limit(:store) - credit_used(:store)
      end
      alias_method :available_calls, :credit_left

      ##
      # Have I reached my API call limit?
      # @return {Boolean}
      #
      def credit_maxed?
        credit_left <= 0
      end
      alias_method :maxed?, :credit_maxed?

      ##
      # How many total API calls can I make?
      # NOTE: subtracting 1 from credit_limit because I think SpiffyStoresAPI cuts off at 299 or store limits.
      # @param {Symbol} scope [:store]
      # @return {Integer}
      #
      def credit_limit(scope=:store)
        @api_credit_limit ||= {}
        @api_credit_limit[scope] ||= api_credit_limit_param(scope).pop.to_i - 1
      end
      alias_method :call_limit, :credit_limit

      ##
      # How many API calls have I made?
      # @param {Symbol} scope [:store]
      # @return {Integer}
      #
      def credit_used(scope=:store)
        api_credit_limit_param(scope).shift.to_i
      end
      alias_method :call_count, :credit_used

      ##
      # @return {HTTPResonse}
      #
      def response
        Store.current unless SpiffyStoresAPI::Base.connection.response
        SpiffyStoresAPI::Base.connection.response
      end

      private

      ##
      # @return {Array}
      #
      def api_credit_limit_param(scope)
        header = response[CREDIT_LIMIT_HEADER_PARAM[scope]]
        raise LimitUnavailable unless header
        p = JSON.parse(header)
        p_limit = p['limit'].to_i
        p_used = p_limit - p['remaining'].to_i
        [p_used, p_limit]
      end
    end
  end
end
