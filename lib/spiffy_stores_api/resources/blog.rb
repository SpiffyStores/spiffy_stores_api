module SpiffyStoresAPI
  class Blog < Base
    include Metafields

    def articles
      Article.find(:all, :params => { :blog_id => id })
    end
  end
end
