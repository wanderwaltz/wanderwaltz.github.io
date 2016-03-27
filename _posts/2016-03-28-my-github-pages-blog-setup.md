---
title: My GitHub Pages Blog Setup
description: "A practical setup of a GitHub Pages blog with custom deployment."
date: 2016-03-28 01:11:00 +0600
tags: [Jekyll, GitHub, Plugins, Rakefile, Rake, Ruby, Git, Commit, Push, Blog]
---
I've [mentioned]({% post_url 2016-03-27-web-design-with-a-coding-mentality %}) before that this blog
is a custom deployed one. While GitHub Pages support some of the Jekyll plugins, I'd like to have
more flexibility and freedom to use any other plugins, some of which I've made myself. As stated in
the GitHub Pages
[documentation](https://help.github.com/articles/adding-jekyll-plugins-to-a-github-pages-site/),

>Other plugins are not supported, so the only way to incorporate them in your site is to generate
your site locally and then push your site's static files to your GitHub Pages site.

So this is exactly what I'm doing here. I think it may be useful for someone if I share my setup
of this blog's development and deployment process.
<!--more-->

## Basic Setup

I'm using a variation of the setup [suggested](http://stackoverflow.com/a/27666206/892696) by David
Jacquel on Stack Overflow. The idea is to have **a single Git repository** with the source and built
site living in **two separate branches**. The `master` branch contains the built static site and
is used for publishing content on `{{ site.url }}`. The `source` branch contains the site source,
templates, Jekyll plugins and all the stuff, which is used to actually build the site.

Calling

    jekyll build

in the source directory builds the site inside a `_site` subdirectory, which needs to be pushed to
the root of the `master` branch in order to actually be presented on `{{ site.url }}`.

In order to achieve this, I have **two local git repos**, each having the corresponding branch
checked out. The directory structure looks like this:

      .
      ├── .git          // source branch is checked out
      ├── _drafts
      ├── _includes
      ├── _layouts
      ├── _plugins
      ├── _posts
      ├── _sass
      └── _site
          ├── .git      // master branch is checked out
          ├── .nojekyll // tells GitHub not to run Jekyll for the site
          └──           // the built site is here

The `_site` directory is added to `.gitignore` of the repo, so it is not committed or pushed to the
`source` branch ever.

When editing the blog, I add posts to the `_posts` directory of the outer repo, then run

    jekyll build

and then **commit and push both of the repos** in order to deploy.

## Rakefile

Doing all this by hand would be cumbersome and error-prone, so I'm using
[rake](https://github.com/ruby/rake) to perform each step automatically.

The `Rakefile` I'm using can be found
[here](https://github.com/wanderwaltz/wanderwaltz.github.io/blob/source/Rakefile). It mostly
functions by making system calls to `jekyll` and `git`, and I've had to add a helper function,
which allows seeing the output of these commands interactively while the Ruby process is running:

{% highlight ruby %}
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
{% endhighlight %}

At the time of writing my `Rakefile` contains the following task definitions:

### :build

Simply calling

    rake build

from the command line builds the site in the `_site` directory by calling `jekyll build`. It
also automatically includes the `--lsi` build flag to produce an index for related posts (AFAIK,
`--lsi` option is not supported currently when building the site on GitHub Pages, so this is another
reason to build locally).

Implementation of the `build` task is pretty much straightforward:

{% highlight ruby %}
def build
  execute("bundle exec jekyll build --lsi")
end

task :build do
  build
end
{% endhighlight %}

You may notice that I'm also using [Bundler](http://bundler.io) to manage the gems used by the
project.

### :serve

Calling

    rake serve

from the command line invokes `jekyll serve` and automatically opens the local blog in Safari. It is
used while writing new posts or editing the layout to allow checking the immediate results in
browser. It also includes the `--lsi` flag.

`serve` task is also implemented as a helper function with a small twist of having a `suffix`
parameter, which is used to run another shell command while the first one is still running.

{% highlight ruby %}
def serve(suffix)
  if suffix != nil
    suffix = " & #{suffix}"
  end

  execute("bundle exec jekyll serve --lsi" + suffix.to_s)
end

task :serve do
  serve("sleep 5s && open -a Safari http://127.0.0.1:4000")
end
{% endhighlight %}

`jekyll serve` will run indefinitely unless stopped and won't allow us to open Safari right after
the site is built, so I'm doing it simultaneously with a fixed delay. There is a chance that the
site won't yet be built and served by the time the delay ends, but it works for now.

### :commit

Calling

    rake commit["Message"]

adds and commits all files in the root directory to the `source` branch of the repo with the
commit message provided. It then builds the site and commits the output to the `master` branch
with the same commit message. Since the `master` branch is checked out in the `_site` directory,
where the build results are located, we will have both the source and the built site committed
to their respective branches of the main repo (remember that both directories have the same repo
cloned, just with different branches checked out).

{% highlight ruby %}
def commit(message)
  build

  commit_source = "git add -A && git commit -m \"#{message}\""
  commit_site = "cd _site && git add -A && git commit -m \"#{message}\""

  execute(commit_source)
  execute(commit_site)
end

task :commit, :message do |t, args|
  commit(args[:message])
end
{% endhighlight %}

Note that all of the tasks and helper functions execute synchronously, so the `commit` function
will first build the site and only after Jekyll finishes working will it commit all changes in both
of the repos.

A noteworthy detail is that each call of the `execute` function spawns a new shell process, so no
state is preserved between the calls. Because of that we have to make all the commands essentially
one-liners by joining them via `&&`. This also allows us doing `cd _site` in the second step and
not worrying about returning back to the current directory after `git` has finished.

### :publish

Calling

    rake publish["Message"]

does the same thing as `commit`, but also pushes both branches to the remote. There is also an
option to call `publish` without parameters

    rake publish

which then only pushes both of the branches to remote without committing anything.

Implementation of `publish` task is almost trivial:

{% highlight ruby %}
def push_origin
  push_source = "git push origin"
  push_site = "cd _site && git push origin"

  execute(push_source)
  execute(push_site)
end

task :publish, :message do |t, args|
  if args[:message] != nil
    commit(args[:message])
  end

  push_origin
end
{% endhighlight %}

### :init

Calling

    rake init

Resets the `_site` directory completely by cloning a fresh `master` branch from GitHub repository.

{% highlight ruby %}
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
{% endhighlight %}

## Other Details

In order to tell GitHub to leave the site alone and don't try to build anything, an empty
`.nojekyll` file is added to the repo's `master` branch. Jekyll ignores hidden files by default and
therefore would delete the `.nojekyll` file each time the site is built (it deletes the `_site`
contents including the `.nojekyll`, but leaves `.git` alone - probably a feature of Jekyll itself).

In order to keep `.nojekyll` in the `_site` forever, I've pushed it to the `source` branch and added
the following line into the `_config.yml`:

{% highlight yaml %}
# _config.yml
include:
 - .nojekyll
{% endhighlight %}

On the other side, Jekyll copies all files not starting with `.` or `_` into the build directory,
so lots of internal stuff ends up there, while I don't really want this to happen. Thankfully,
Jekyll configuration supports file exclusion too:

{% highlight yaml %}
# _config.yml
exclude:
  - 'Rakefile'
  - 'Gemfile'
  - 'Gemfile.lock'
  - 'LICENSE.md'
{% endhighlight %}

## In Conclusion

Deploying a locally built Jekyll site on GitHub Pages seemed to be a cumbersome task at first, but
with right setup and the help of `rake` it becomes a piece of cake. Writing a good post is a lot
more difficult problem than calling

    rake publish["Add a new post"]

in the command line to finish the job afterwards.
