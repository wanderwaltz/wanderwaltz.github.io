module LiquifyFilter
  def liquify(input)
    site = @context.registers[:site]
    page = @context.registers[:page]
    info = { 'site' => site.site_payload['site'], 'page' => page }
    Liquid::Template.parse(input).render(info)
  end
end

Liquid::Template.register_filter(LiquifyFilter)
