require 'test_helper'

class LimitsTest < Test::Unit::TestCase
  def setup
    SpiffyStoresAPI::Base.site = "test.spiffystores.com"
    @header_hash = {'http_x_ratelimit' => { 'name' => 'API', 'period' => 300, 'limit' => 300, 'remaining' => 200, 'until' => '2014-11-28T03:45:00Z'}.to_json}

    SpiffyStoresAPI::Base.connection.expects(:response).at_least(0).returns(@header_hash)
  end

  context "Limits" do
    should "fetch limit total" do
      assert_equal(299, SpiffyStoresAPI.credit_limit(:shop))
    end

    should "fetch used calls" do
      assert_equal(100, SpiffyStoresAPI.credit_used(:shop))
    end

    should "calculate remaining calls" do
      assert_equal(199, SpiffyStoresAPI.credit_left)
    end

    should "flag maxed out credits" do
      assert !SpiffyStoresAPI.maxed?
      @header_hash = {'http_x_ratelimit' => { 'name' => 'API', 'period' => 300, 'limit' => 300, 'remaining' => 1, 'until' => '2014-11-28T03:45:00Z'}.to_json}
      SpiffyStoresAPI::Base.connection.expects(:response).at_least(1).returns(@header_hash)
      assert SpiffyStoresAPI.maxed?
    end

    should "raise error when header doesn't exist" do
      @header_hash = {}
      SpiffyStoresAPI::Base.connection.expects(:response).at_least(1).returns(@header_hash)
      assert_raises SpiffyStoresAPI::Limits::LimitUnavailable do
        SpiffyStoresAPI.credit_left
      end
    end
  end
end
