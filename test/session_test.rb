require 'test_helper'

class SessionTest < Test::Unit::TestCase

  def setup
    SpiffyStoresAPI::Session.secret = 'secret'
  end

  test "not be valid without a url" do
    session = SpiffyStoresAPI::Session.new(nil, "any-token")
    assert_not session.valid?
  end

  test "not be valid without token" do
    session = SpiffyStoresAPI::Session.new("testshop.spiffystores.com")
    assert_not session.valid?
  end

  test "be valid with any token and any url" do
    session = SpiffyStoresAPI::Session.new("testshop.spiffystores.com", "any-token")
    assert session.valid?
  end

  test "not raise error without params" do
    assert_nothing_raised do
      session = SpiffyStoresAPI::Session.new("testshop.spiffystores.com", "any-token")
    end
  end

  test "ignore everything but the subdomain in the shop" do
    assert_equal "https://testshop.spiffystores.com/api", SpiffyStoresAPI::Session.new("http://user:pass@testshop.notspiffy.net/path", "any-token").site
  end

  test "append the spiffystores domain if not given" do
    assert_equal "https://testshop.spiffystores.com/api", SpiffyStoresAPI::Session.new("testshop", "any-token").site
  end

  test "not raise error without params" do
    assert_nothing_raised do
      session = SpiffyStoresAPI::Session.new("testshop.spiffystores.com", "any-token")
    end
  end

  test "raise error if params passed but signature omitted" do
    assert_raises(SpiffyStoresAPI::ValidationException) do
      session = SpiffyStoresAPI::Session.new("testshop.spiffystores.com")
      session.request_token({'code' => 'any-code'})
    end
  end

  test "setup api_key and secret for all sessions" do
    SpiffyStoresAPI::Session.setup(:api_key => "My test key", :secret => "My test secret")
    assert_equal "My test key", SpiffyStoresAPI::Session.api_key
    assert_equal "My test secret", SpiffyStoresAPI::Session.secret
  end

  test "use 'https' protocol by default for all sessions" do
    assert_equal 'https', SpiffyStoresAPI::Session.protocol
  end

  test "#temp reset SpiffyStoresAPI::Base.site to original value" do

    SpiffyStoresAPI::Session.setup(:api_key => "key", :secret => "secret")
    session1 = SpiffyStoresAPI::Session.new('fakeshop.spiffystores.com', 'token1')
    SpiffyStoresAPI::Base.activate_session(session1)

    SpiffyStoresAPI::Session.temp("testshop.spiffystores.com", "any-token") {
      @assigned_site = SpiffyStoresAPI::Base.site
    }
    assert_equal 'https://testshop.spiffystores.com/api', @assigned_site.to_s
    assert_equal 'https://fakeshop.spiffystores.com/api', SpiffyStoresAPI::Base.site.to_s
  end

  test "create_permission_url returns correct url with single scope no redirect uri" do
    SpiffyStoresAPI::Session.setup(:api_key => "My_test_key", :secret => "My test secret")
    session = SpiffyStoresAPI::Session.new('http://localhost.spiffystores.com')
    scope = ["write_products"]
    permission_url = session.create_permission_url(scope)
    assert_equal "https://localhost.spiffystores.com/api/oauth/authorize?client_id=My_test_key&scope=write_products", permission_url
  end

  test "create_permission_url returns correct url with single scope and redirect uri" do
    SpiffyStoresAPI::Session.setup(:api_key => "My_test_key", :secret => "My test secret")
    session = SpiffyStoresAPI::Session.new('http://localhost.spiffystores.com')
    scope = ["write_products"]
    permission_url = session.create_permission_url(scope, "http://my_redirect_uri.com")
    assert_equal "https://localhost.spiffystores.com/api/oauth/authorize?client_id=My_test_key&scope=write_products&redirect_uri=http://my_redirect_uri.com", permission_url
  end

  test "create_permission_url returns correct url with dual scope no redirect uri" do
    SpiffyStoresAPI::Session.setup(:api_key => "My_test_key", :secret => "My test secret")
    session = SpiffyStoresAPI::Session.new('http://localhost.spiffystores.com')
    scope = ["write_products","write_customers"]
    permission_url = session.create_permission_url(scope)
    assert_equal "https://localhost.spiffystores.com/api/oauth/authorize?client_id=My_test_key&scope=write_products,write_customers", permission_url
  end

  test "create_permission_url returns correct url with no scope no redirect uri" do
    SpiffyStoresAPI::Session.setup(:api_key => "My_test_key", :secret => "My test secret")
    session = SpiffyStoresAPI::Session.new('http://localhost.spiffystores.com')
    scope = []
    permission_url = session.create_permission_url(scope)
    assert_equal "https://localhost.spiffystores.com/api/oauth/authorize?client_id=My_test_key&scope=", permission_url
  end

  test "raise exception if code invalid in request token" do
    SpiffyStoresAPI::Session.setup(:api_key => "My test key", :secret => "My test secret")
    session = SpiffyStoresAPI::Session.new('http://localhost.spiffystores.com')
    fake nil, :url => 'https://localhost.spiffystores.com/api/oauth/access_token',:method => :post, :status => 404, :body => '{"error" : "invalid_request"}'
    assert_raises(SpiffyStoresAPI::ValidationException) do
      session.request_token(params={:code => "bad-code"})
    end
    assert_equal false, session.valid?
  end

  test "#temp reset SpiffyStoresAPI::Base.site to original value when using a non-standard port" do
    SpiffyStoresAPI::Session.setup(:api_key => "key", :secret => "secret")
    session1 = SpiffyStoresAPI::Session.new('fakeshop.spiffystores.com:3000', 'token1')
    SpiffyStoresAPI::Base.activate_session(session1)
  end

  test "spiffystores_domain supports non-standard ports" do
    begin
      SpiffyStoresAPI::Session.setup(:api_key => "key", :secret => "secret", :spiffystores_domain => 'localhost', port: '3000')
      session = SpiffyStoresAPI::Session.new('fakeshop.localhost:3000', 'token1')
      SpiffyStoresAPI::Base.activate_session(session)
      assert_equal 'https://fakeshop.localhost:3000/api', SpiffyStoresAPI::Base.site.to_s

      session = SpiffyStoresAPI::Session.new('fakeshop', 'token1')
      SpiffyStoresAPI::Base.activate_session(session)
      assert_equal 'https://fakeshop.localhost:3000/api', SpiffyStoresAPI::Base.site.to_s
    ensure
      SpiffyStoresAPI::Session.spiffystores_domain = "spiffystores.com"
      SpiffyStoresAPI::Session.port = nil
    end
  end

  test "return site for session" do
    session = SpiffyStoresAPI::Session.new("testshop.spiffystores.com", "any-token")
    assert_equal "https://testshop.spiffystores.com/api", session.site
  end

  test "return_token_if_signature_is_valid" do
    params = {:code => 'any-code', :timestamp => Time.now}
    sorted_params = make_sorted_params(params)
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new(), SpiffyStoresAPI::Session.secret, sorted_params)
    fake nil, :url => 'https://testshop.spiffystores.com/api/oauth/access_token',:method => :post, :body => '{"access_token" : "any-token"}'
    session = SpiffyStoresAPI::Session.new("testshop.spiffystores.com")
    token = session.request_token(params.merge(:hmac => signature))
    assert_equal "any-token", token
  end

  test "raise error if signature does not match expected" do
    params = {:code => "any-code", :timestamp => Time.now}
    sorted_params = make_sorted_params(params)
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new(), SpiffyStoresAPI::Session.secret, sorted_params)
    params[:foo] = 'world'
    assert_raises(SpiffyStoresAPI::ValidationException) do
      session = SpiffyStoresAPI::Session.new("testshop.spiffystores.com")
      session.request_token(params.merge(:hmac => signature))
    end
  end

  test "raise error if timestamp is too old" do
    params = {:code => "any-code", :timestamp => Time.now - 2.days}
    sorted_params = make_sorted_params(params)
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new(), SpiffyStoresAPI::Session.secret, sorted_params)
    params[:foo] = 'world'
    assert_raises(SpiffyStoresAPI::ValidationException) do
      session = SpiffyStoresAPI::Session.new("testshop.spiffystores.com")
      session.request_token(params.merge(:hmac => signature))
    end
  end

  test "return true when the signature is valid and the keys of params are strings" do
    now = Time.now
    params = {"code" => "any-code", "timestamp" => now}
    sorted_params = make_sorted_params(params)
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new(), SpiffyStoresAPI::Session.secret, sorted_params)
    params = {"code" => "any-code", "timestamp" => now, "hmac" => signature}
  end

  test "return true when validating signature of params with ampersand and equal sign characters" do
    SpiffyStoresAPI::Session.secret = 'secret'
    params = {'a' => '1&b=2', 'c=3&d' => '4'}
    to_sign = "a=1%26b=2&c%3D3%26d=4"
    params['hmac'] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SpiffyStoresAPI::Session.secret, to_sign)

    assert_equal true, SpiffyStoresAPI::Session.validate_signature(params)
  end

  test "return true when validating signature of params with percent sign characters" do
    SpiffyStoresAPI::Session.secret = 'secret'
    params = {'a%3D1%26b' => '2%26c%3D3'}
    to_sign = "a%253D1%2526b=2%2526c%253D3"
    params['hmac'] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SpiffyStoresAPI::Session.secret, to_sign)

    assert_equal true, SpiffyStoresAPI::Session.validate_signature(params)
  end

  private

  def make_sorted_params(params)
    sorted_params = params.with_indifferent_access.except(:signature, :hmac, :action, :controller).collect{|k,v|"#{k}=#{v}"}.sort.join('&')
  end
end
