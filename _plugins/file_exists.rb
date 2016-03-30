module FileExistsFilter
  def file_exists(input)
    input.to_s.split(",")
     .map{|s| s.strip }
     .map{|s| File.exists?(s) }
     .reduce(:&)
  end
end

Liquid::Template.register_filter(FileExistsFilter)
