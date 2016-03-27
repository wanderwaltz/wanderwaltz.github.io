require 'Open3'

def execute(cmd)
  result = ""
  Open3.popen2e(cmd) do |stdin, stdout, wait_thr|
    while line = stdout.gets
      result << line << "\n"
      puts line
    end
  end
  result
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


task :init do
  git_remote_url = `git config --get remote.origin.url`.strip

  commands = [
    "rm -rf _site",
    "mkdir _site",
    "cd _site",
    "git clone #{git_remote_url} .",
  ]

  execute(commands.join(" && "))
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


task :status do
  execute("git status")
end

