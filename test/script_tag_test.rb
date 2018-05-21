require 'test_helper'

class ScriptTagTest < Test::Unit::TestCase
  test "get all should get all script tags" do
    fake 'script_tags', :method => :get, :status => 200, :body => load_fixture('script_tags')
    script_tags = SpiffyStoresAPI::ScriptTag.all
    assert_equal "http://js-aplenty.com/bar.js", script_tags.first.src
  end

  test "get should get a script tag" do
    fake 'script_tags/421379493', :method => :get, :status => 200, :body => load_fixture('script_tag')
    script_tag = SpiffyStoresAPI::ScriptTag.find(421379493)
    assert_equal "http://js-aplenty.com/bar.js", script_tag.src
  end

  test "create should create a new script tag" do
    fake 'script_tags', :method => :post, :status => 201, :body => load_fixture('script_tag')
    script_tag = SpiffyStoresAPI::ScriptTag.create(event: "onload", src: "http://js-aplenty.com/bar.js")
    assert_equal "http://js-aplenty.com/bar.js", script_tag.src
  end

  test "editing script tag should update script tag" do
    fake 'script_tags/421379493', :method => :get, :status => 200, :body => load_fixture('script_tag')
    script_tag = SpiffyStoresAPI::ScriptTag.find(421379493)
    script_tag.src = "http://js-aplenty.com/bar.js"
    fake 'script_tags/421379493', :method => :put, :status => 200, :body => load_fixture('script_tag')
    script_tag.save
    assert_equal "http://js-aplenty.com/bar.js", script_tag.src
  end
end
