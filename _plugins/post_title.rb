module Jekyll
  class PostTitle < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
      @tokens = tokens
    end

    def render(context)
      post = context[@text]
      externalUrl = post["external_url"]
      url = post["url"]
      title = post["title"]

      if externalUrl
        link = <<-external
          <a href="#{externalUrl}">
            <i class=\"fa fa-bookmark-o small\"></i> #{title}
          </a>
        external
      elsif context["page"]["url"] != url
        link = <<-internal
          <a href="#{url}">#{title}</a>
        internal
      else
        link = title
      end

      <<-return
        <h1 class="post-title">#{link}</h1>
      return
    end
  end
end

Liquid::Template.register_tag('post_title', Jekyll::PostTitle)
