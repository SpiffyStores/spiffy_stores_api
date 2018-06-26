require 'test_helper'


class BaseTest < Test::Unit::TestCase

  def setup
    @session1 = SpiffyStoresAPI::Session.new('shop1.spiffystores.com', 'token1')
    @session2 = SpiffyStoresAPI::Session.new('shop2.spiffystores.com', 'token2')
  end

  def teardown
    clear_header('X-Custom')
  end

  test '#activate_session should set site and headers for given session' do
    SpiffyStoresAPI::Base.activate_session @session1

    assert_nil ActiveResource::Base.site
    assert_equal 'https://shop1.spiffystores.com/api', SpiffyStoresAPI::Base.site.to_s
    assert_equal 'https://shop1.spiffystores.com/api', SpiffyStoresAPI::Store.site.to_s

    assert_nil ActiveResource::Base.headers['Authorization']
    assert_equal 'Bearer token1', SpiffyStoresAPI::Base.headers['Authorization']
    assert_equal 'Bearer token1', SpiffyStoresAPI::Store.headers['Authorization']
  end

  test '#clear_session should clear site and headers from Base' do
    SpiffyStoresAPI::Base.activate_session @session1
    SpiffyStoresAPI::Base.clear_session

    assert_nil ActiveResource::Base.site
    assert_nil SpiffyStoresAPI::Base.site
    assert_nil SpiffyStoresAPI::Store.site

    assert_nil ActiveResource::Base.headers['Authorization']
    assert_nil SpiffyStoresAPI::Base.headers['Authorization']
    assert_nil SpiffyStoresAPI::Store.headers['Authorization']
  end

  test '#activate_session with one session, then clearing and activating with another session should send request to correct shop' do
    SpiffyStoresAPI::Base.activate_session @session1
    SpiffyStoresAPI::Base.clear_session
    SpiffyStoresAPI::Base.activate_session @session2

    assert_nil ActiveResource::Base.site
    assert_equal 'https://shop2.spiffystores.com/api', SpiffyStoresAPI::Base.site.to_s
    assert_equal 'https://shop2.spiffystores.com/api', SpiffyStoresAPI::Store.site.to_s

    assert_nil ActiveResource::Base.headers['Authorization']
    assert_equal 'Bearer token2', SpiffyStoresAPI::Base.headers['Authorization']
    assert_equal 'Bearer token2', SpiffyStoresAPI::Store.headers['Authorization']
  end

  test '#activate_session with nil raises an InvalidSessionError' do
    assert_raises SpiffyStoresAPI::Base::InvalidSessionError do
      SpiffyStoresAPI::Base.activate_session nil
    end
  end

  test "#delete should send custom headers with request" do
    SpiffyStoresAPI::Base.activate_session @session1
    SpiffyStoresAPI::Base.headers['X-Custom'] = 'abc'
    SpiffyStoresAPI::Base.connection.expects(:delete).with('/api/bases/1.json', has_entry('X-Custom', 'abc'))
    SpiffyStoresAPI::Base.delete "1"
  end

  test "#headers includes the User-Agent" do
    assert_not_includes ActiveResource::Base.headers.keys, 'User-Agent'
    assert_includes SpiffyStoresAPI::Base.headers.keys, 'User-Agent'
    thread = Thread.new do
      assert_includes SpiffyStoresAPI::Base.headers.keys, 'User-Agent'
    end
    thread.join
  end

  if ActiveResource::VERSION::MAJOR >= 4
    test "#headers propagates changes to subclasses" do
      SpiffyStoresAPI::Base.headers['X-Custom'] = "the value"
      assert_equal "the value", SpiffyStoresAPI::Base.headers['X-Custom']
      assert_equal "the value", SpiffyStoresAPI::Product.headers['X-Custom']
    end

    test "#headers clears changes to subclasses" do
      SpiffyStoresAPI::Base.headers['X-Custom'] = "the value"
      assert_equal "the value", SpiffyStoresAPI::Product.headers['X-Custom']
      SpiffyStoresAPI::Base.headers['X-Custom'] = nil
      assert_nil SpiffyStoresAPI::Product.headers['X-Custom']
    end
  end

  if ActiveResource::VERSION::MAJOR >= 5 || (ActiveResource::VERSION::MAJOR >= 4 && ActiveResource::VERSION::PRE == "threadsafe")
    test "#headers set in the main thread affect spawned threads" do
      SpiffyStoresAPI::Base.headers['X-Custom'] = "the value"
      Thread.new do
        assert_equal "the value", SpiffyStoresAPI::Base.headers['X-Custom']
      end.join
    end

    test "#headers set in spawned threads do not affect the main thread" do
      Thread.new do
        SpiffyStoresAPI::Base.headers['X-Custom'] = "the value"
      end.join
      assert_nil SpiffyStoresAPI::Base.headers['X-Custom']
    end
  end

  def clear_header(header)
    [ActiveResource::Base, SpiffyStoresAPI::Base, SpiffyStoresAPI::Product].each do |klass|
      klass.headers.delete(header)
    end
  end
end
