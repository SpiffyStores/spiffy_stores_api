require 'test_helper'

class StoreTest < Test::Unit::TestCase
  def setup
    super
    fake "store"
    @store = SpiffyStoresAPI::Store.current
  end

  def test_current_should_return_current_store
    assert @store.is_a?(SpiffyStoresAPI::Store)
    assert_equal "Apple Computers", @store.name
    assert_equal "apple.spiffystores.com", @store.spiffystores_domain
    assert_equal 690933842, @store.id
    assert_equal "2015-05-08T16:02:51.611-08:00", @store.created_at
    assert_equal true, @store.tax_shipping
    assert_equal false, @store.tax_export_shipping
    assert_equal true, @store.force_ssl
  end

  def test_current_with_options_should_return_current_store
    fake "store.json?fields=name%2Cspiffystores_domain", :extension => false, :method => :get, :status => 201, :body => load_fixture('store')

    @store = SpiffyStoresAPI::Store.current(params: { fields: 'name,spiffystores_domain' })
    assert @store.is_a?(SpiffyStoresAPI::Store)
    assert_equal "Apple Computers", @store.name
    assert_equal "apple.spiffystores.com", @store.spiffystores_domain
  end

  def test_get_metafields_for_store
    fake "metafields"

    metafields = @store.metafields

    assert_equal 2, metafields.length
    assert metafields.all?{|m| m.is_a?(SpiffyStoresAPI::Metafield)}
  end

  def test_add_metafield
    fake "metafields", :method => :post, :status => 201, :body =>load_fixture('metafield')

    field = @store.add_metafield(SpiffyStoresAPI::Metafield.new(:namespace => "contact", :key => "email", :value => "123@example.com", :value_type => "string"))
    assert_equal ActiveSupport::JSON.decode('{"metafield":{"namespace":"contact","key":"email","value":"123@example.com","value_type":"string"}}'), ActiveSupport::JSON.decode(FakeWeb.last_request.body)
    assert !field.new_record?
    assert_equal "contact", field.namespace
    assert_equal "email", field.key
    assert_equal "123@example.com", field.value
  end

# def test_events
#   fake "events"
#
#   events = @store.events
#
#   assert_equal 3, events.length
#   assert events.all?{|m| m.is_a?(SpiffyStoresAPI::Event)}
# end
end
