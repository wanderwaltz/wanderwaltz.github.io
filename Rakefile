require 'Open3'

def execute(cmd)
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    while line = stdout.gets
      puts line
    end
  end
end


def serve
  execute("bundle exec jekyll serve --lsi")
end


def build
  execute("bundle exec jekyll build --lsi")
end


task :serve do
  serve
end


task :build do
  build
end


task :commit, :message do |t, args|
  build

  commit_source = "git add -A && git commit -m \"#{args[:message]}\""
  commit_site = "cd _site && git add -A && git commit -m \"#{args[:message]}\""

  execute(commit_source)
  execute(commit_site)
end
