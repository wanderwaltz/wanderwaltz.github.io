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


def build_cv
  unless File.exists?('_plugins/_md2resume')
    return
  end

  commands = [
    "rm cv.html",
    "rm cv.pdf",
    "_plugins/_md2resume html _cv.md .",
    "_plugins/_md2resume pdf _cv.md .",
    "mv _cv.html cv.html",
    "mv _cv.pdf cv.pdf",
  ]

  execute(commands.join(" && "))
end


def build
  build_cv
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
    "cd ../_plugins",
    "rm _md2resume",
    "curl -L https://github.com/there4/markdown-resume/raw/master/bin/md2resume > _md2resume",
    "chmod +x _md2resume"
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

