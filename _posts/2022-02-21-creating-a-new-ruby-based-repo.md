---
title: "Creating a new Ruby-based repo: a reminder"
description: >-
  So, you need a new repo using Ruby language. Just remember to follow
  these simple rules and everything is going to be OK.
date: 2022-02-21 02:19:00 +0700
tags: [Ruby, RVM, M1, Tips, New Mac setup]
---

Keeping this as a note to myself. A cheatsheet, if you must.

This is a step-by-step guide which I've made for myself while trying to set up a Ruby installation on a fresh MacBook Pro M1 2020. It may or may not be relevant to your setup.

This is needed if you use [CocoaPods](https://cocoapods.org) in your iOS project, or if you use [Jekyll](https://jekyllrb.com) as your static site generator of choice.

<details>
<summary>Short list collapsed</summary>
<ol>
<li>install rvm (see <a href="https://rvm.io">https://rvm.io</a>)</li>
<li>add <code>.ruby-version</code></li>
<li>install ruby via rvm</li>
<li>add <code>.ruby-gemset</code></li>
<li><code>rvm use .</code></li>
<li><code>gem install bundler</code></li>
<li>add <code>Gemfile</code></li>
<li><code>bundle install</code></li>
<li><code>bundle exec &lt;command&gt;</code></li>
</ol>
<br/>
</details>
<br/>

## Step 1: Install RVM/rbenv

Each Ruby-based app/repo needs a Ruby version manager. Period. I've been there and seen how things break with time if you don't fix Ruby version used in your project.

I'm personally more familiar with RVM aka Ruby Version Manager, so to start I check whether 

```
which rvm
```

returns anything in my terminal of choice and go to [https://rvm.io](https://rvm.io) and follow the installation instructions in case the output is empty.

## Step 2: .ruby-version

In order to tell RVM which exact Ruby version you're going to use, create a file at the root of your repo named

```
.ruby-version
```

with the version number as its contents.

```
echo "3.0.0" > .ruby-version
```

## Step 3: Install the required Ruby version

If you've just installed RVM, there are no Ruby versions packaged with it. You have to manually install Ruby specified in your `.ruby-version` file. To list versions known to RVM, use

```
rvm list known
```

and then install the one you need:

```
rvm install ruby-3.0.0
```

After that, checking `which ruby` in terminal should yield a path in `.rvm` directory:

```
which ruby
/Users/username/.rvm/rubies/ruby-3.0.0/bin/ruby
```

## Step 4: .ruby-gemset

I understand a Ruby gemset as sort of a namespace in which your dependencies are installed. So, if you need some specific version of a gem in one app and a different version of the same gem in another app, RVM can easily manage these for you if the gems are installed in different gemsets. It's just good manners to declare a separate gemset for each app you're working on.

```
echo "wanderwaltz.github.io" > .ruby-gemset
```

## Step 5: rvm use .

Make sure you're using the gemset you're declaring. In the root of the repo call

```
rvm use .
```

to make sure RVM has read the `.ruby-version` and `.ruby-gemset` files and taken their contents into account.

## Step 6. Install bundler

```
gem install bundler
```

[Bundler](https://bundler.io) is used to manage all your other Ruby dependencies. While all other stuff will be installed via

```
bundle install
```

command, you have to install bundler itself directly via `gem install`.

## Step 7. Make a Gemfile

Create a `Gemfile` and list your dependencies there. See [https://bundler.io/gemfile.html](https://bundler.io/gemfile.html) for info on the syntax. Remember that the `Gemfile` is basically a Ruby script so if you need to do some complex logic in there, you can (although this may not be that great of an idea).

Install dependencies via

```
bundle install
```

## Bonus step: problems with installing gems

Sometimes unexpected problems arise when installing dependencies. Usually Stack Overflow has a solution for these. This time I was installing Jekyll and its transitive dependencies and encountered the following error:

```
compiling binder.cpp
In file included from binder.cpp:20:
./project.h:116:10: fatal error: 'openssl/ssl.h' file not found
#include <openssl/ssl.h>
```

[A question on Stack Overflow](https://stackoverflow.com/questions/30818391/gem-eventmachine-fatal-error-openssl-ssl-h-file-not-found) contained enough info to solve the problem, although I needed to follow the steps from the comments, not the actual answer.

For future reference, the steps which helped me were the following:

```
brew install openssl
brew link openssl --force
gem install eventmachine -v 1.0.8 -- --with-cppflags=-I/usr/local/opt/openssl/include
bundle install
```

## Step 8: Always bundle exec

To make sure you're using the right gems, always use

```
bundle exec <command>
```

afterwards, not just `<command>`. This is for the Ruby-based commands obviously. For example, in case of wanderwaltz.github.io the commands I run are usually related to Jekyll and take the following form:

```
bundle exec jekyll serve
```
