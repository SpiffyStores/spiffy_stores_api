module SpiffyStoresAPI
  class Article < Base
    include Metafields
    include DisablePrefixCheck

    conditional_prefix :blog

#   def comments
#     Comment.find(:all, :params => { :article_id => id })
#   end

    def self.authors(options = {})
      get(:authors, options)
    end

    def self.tags(options={})
      get(:tags, options)
    end
  end
end
