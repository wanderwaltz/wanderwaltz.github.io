source 'https://rubygems.org'

gem 'webrick'
gem 'midnight'

group :jekyll_plugins do
  gem 'jekyll-feed', '~> 0.6'
  gem 'github-pages', '~> 223'
end

install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.0", :install_if => Gem.win_platform?
gem "kramdown-parser-gfm"
