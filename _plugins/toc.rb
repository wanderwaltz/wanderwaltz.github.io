module TocFilter
  def toc(input)
    input = Kramdown::Document.new(input).to_html

    output = ""
    # output = '<ul class="toc">'

    current_level = nil

    input.scan(/<(h(2))(?:>|\s+(.*?)>)([^<]*)<\/\1\s*>/mi).each do |entry|
      level = entry[1].to_i

      # unless current_level == nil
      #   if level > current_level
      #     output << '<ul>'
      #   elsif level < current_level
      #     output << '</ul>'
      #   end
      # end

      current_level = level

      id = (entry[2][/^id=(['"])(.*)\1$/, 2] rescue nil)
      title = entry[3].gsub(/<(\w*).*?>(.*?)<\/\1\s*>/m, '\2').strip

      if id
        output << %{<a class="sidebar-nav-item" href="##{id}">
                      <i class="fa fa-angle-right"></i> #{title}</a>}
      else
        output << %{> #{title}}
      end

    end

    # while current_level > 0
    #   output << '</ul>'
    #   current_level -= 1
    # end

    output
  end
end

Liquid::Template.register_filter(TocFilter)
