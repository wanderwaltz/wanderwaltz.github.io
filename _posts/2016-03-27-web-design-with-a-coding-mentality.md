---
title: Web Design with a Coding Mentality
description: "Managing a Jekyll blog from a programmer's perspective."
date: 2016-03-27 20:39:00 +0600
tags: [Thoughts, Jekyll, Meta, Liquid, Templates, Ruby]
---
Recently I've come to a realization that I like coding better than writing. Consider this blog for
example. I've been tinkering with it for a couple of days now: changing the theme, moving CSS styles
around, optimizing usage of templates etc. - all that instead of actually writing some content,
which someone could actually read.

It is a funny thought - as a programmer, I value the internal structure, the beauty of the source
files more than the actual product, which will be used by the consumer.

Maybe this comes from the fact that I'm not really a good writer, but there is one more thing that
makes me do all this: I see this blog as a piece of software, with all the usual concerns such as
maintainability, extendibility etc.

They say that if all you have is a hammer, everything looks like a nail. Programming is my hammer
and I'd like to share an example of a practical problem, which ended up not being a nail after all.
<!--more-->

## Don't Repeat Yourself

One of the important principles of software engineering is *"Don't Repeat Yourself"*, which
is stated as *"Every piece of knowledge must have a single, unambiguous, authoritative
representation within a system."*[^1]

[^1]: Citation from [Wikipedia](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

While trying to apply the DRY principle to this blog, I've stumbled upon a repeating sequence in
my `index.html` and `post` template. When displaying the post title, a conditional logic is
necessary to properly render link post titles.

<span class="note">
There a two general types of posts in this blog: a default and a link post. Link posts differ from
the default posts in that they do not really have a lot of meaningful text written by me, they are
a pair of an external URL and a short comment explaining why I'd find this particular page
interesting enough to share here. As an example of link post, consider
[Damn Cool Algorithms]({% post_url 2015-04-11-damn-cool-algorithms %}).
</span>

While usual post title looks like this:

>**Default Post Title**

The link post title should look like this:

>**{% icon fa-bookmark-o %} Link Post Title**

And the bookmark icon[^2] should be added to all link post titles regardless of where the title is
displayed.

[^2]: Via [Font-Awesome](http://fontawesome.io).

It was implemented in the source files like that:

{% highlight html %}
{{ "{% if post.external_url" }} %}
  <h1 class="post-title">
    <a href="{{ "{{ post.external_url" }} }}">
      {{ "{% icon fa-bookmark-o" }} %} {{ "{{ post.title" }} }}
    </a>
   </h1>
{{ "{% else" }} %}
  <h1 class="post-title">
    <a href="{{ "{{ post.url" }} }}">
      {{ "{{ post.title" }} }}
    </a>
  </h1>
{{ "{% endif" }} %}
{% endhighlight %}

This snippet of a Liquid template was used on both `index.html` and in `post` template.

Obviously, I wanted to avoid duplication and reuse this code somehow. The first thing I thought of is
making a custom Liquid tag, which would check the condition and render the necessary HTML depending
on the post type (well, I'm probably not being absolutely honest here - it is probably not the most
obvious solution, but yes, it's the first thing coming in mind while I already know that making
custom Liquid tags is even possible).

So the following Jekyll plugin is born:

{% highlight ruby %}
# post_title.rb
module Jekyll
  class PostTitle < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
      @tokens = tokens
    end

    def render(context)
      post = context[@text]
      externalUrl = post["external_url"]
      url = post["url"]
      title = post["title"]

      # check for link posts
      if externalUrl
        link = <<-external
          <a href="#{externalUrl}">
            <i class=\"fa fa-bookmark-o small\"></i> #{title}
          </a>
        external
      # link the post only if the title is not displayed on the post's
      # page itself - in this case just use the <h1> without href.
      elsif context["page"]["url"] != url
        link = <<-internal
          <a href="#{url}">#{title}</a>
        internal
      else
        link = title
      end

      <<-return
        <h1 class="post-title">#{link}</h1>
      return
    end
  end
end

Liquid::Template.register_tag('post_title', Jekyll::PostTitle)
{% endhighlight %}

A rather straightforward solution, I think. Now this new `post_title` tag can be used in
`index.html` like this:

{% highlight html %}
<!-- index.html -->
{{ "{% for post in paginator.posts" }} %}
  <div class="post">
    {{ "{% post_title post" }} %}
  </div>
{{ "{% endfor" }} %}
{% endhighlight %}

## The Right Way?

After more CSS-tinkering and adjusting the blog code, I've started to think whether using Ruby for
this simple thing is actually the right way to do. I'm thinking a coder instead of as a web designer
here. Maybe writing a new plugin just for that is an overkill, and a simple mixin template would
work?

Putting the repeating piece of HTML above into a separete file:

{% highlight html %}
<!-- post_title.html -->
<h1 class="post-title">
{{ "{% if post.external_url" }} %}
  <a href="{{ "{{ post.external_url" }} }}">
    {{ "{% icon fa-bookmark-o" }} %} {{ "{{ post.title" }} }}
  </a>
{{ "{% elsif page.url != post.url" }} %}
  <a href="{{ "{{ post.url" }} }}">
    {{ "{{ post.title" }} }}
  </a>
{{ "{% else" }} %}
  {{ "{{ post.title" }} }}
{{ "{% endif" }} %}
</h1>
{% endhighlight %}

And then just including it where needed:

{% highlight html %}
<!-- index.html -->
{{ "{% for post in paginator.posts" }} %}
  <div class="post">
    {{ "{% include post_title.html" }} %}
  </div>
{{ "{% endfor" }} %}
{% endhighlight %}

It does the same trick without any plugin magic. On the plus side, it works in GitHub Pages, where
usage of custom plugins is prohibited[^3].

[^3]: Lack of custom plugins was the actual reason for me to drop dynamic GitHub page generation and
      proceed with a static approach (i.e. `.nojekyll`), but this is a topic for another post.

The case in point: I'm thinking as a programmer and my solution to everything is programming.
It's OK I think when it works. But sometimes it is a good practice to think outside of one's
comfort zone.

