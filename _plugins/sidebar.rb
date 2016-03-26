module Jekyll
  class Sidebar < Liquid::Block
    def initialize(tag_name, text, tokens)
      super
      @text = text
      @tokens = tokens
    end

    def render(context)
      context["page"]["custom_sidebar"] = super
      ""
    end
  end
end

Liquid::Template.register_tag('sidebar', Jekyll::Sidebar)
