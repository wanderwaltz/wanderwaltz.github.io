require 'Open3'

def execute(cmd)
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    while line = stdout.gets
      puts line
    end
  end
end


def serve(suffix)
  if suffix != nil
    suffix = " & #{suffix}"
  end

  execute("bundle exec jekyll serve --lsi" + suffix.to_s)
end


def build
  execute("bundle exec jekyll build --lsi")
end


def commit(message)
  build

  commit_source = "git add -A && git commit -m \"#{message}\""
  commit_site = "cd _site && git add -A && git commit -m \"#{message}\""

  execute(commit_source)
  execute(commit_site)
end


def push_origin
  push_source = "git push origin"
  push_site = "cd _site && git push origin"

  execute(push_source)
  execute(push_site)
end


task :serve do
  serve("sleep 5s && open -a Safari http://127.0.0.1:4000")
end


task :build do
  build
end


task :commit, :message do |t, args|
  commit(args[:message])
end


task :publish, :message do |t, args|
  if args[:message] != nil
    commit(args[:message])
  end

  push_origin
end

