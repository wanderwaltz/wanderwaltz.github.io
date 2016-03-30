---
layout: page
title: About
comments: false
modified: 2015-03-26
---

<figure class="photo float-right">
  <img src="/images/avatar.jpg" alt="" width="200" height="200">
</figure>

<span style="white-space: nowrap;"> About something or other.</span>

Hi, my name is Egor, I've been writing apps for iOS since 2009 and this is yet another tech blog related to various coding stuff I encounter in my everyday life.

I like creative coding which sometimes results in things which are better kept out of production but still worth pondering about. If you're looking for something like that, you've come to the right place.

It's [#justcodingthings](http://wanderwaltz.github.io), ya know?

<!-- Link CV if corresponding files exist -->
{% assign both_cv_versions_present = "cv.html, cv.pdf" | file_exists  %}
{% assign html_cv_present = "cv.html" | file_exists  %}
{% assign pdf_cv_present = "cv.pdf" | file_exists  %}

{% assign please_see_my_cv = "If you're interested in offering me a job, please see my" %}

{% if both_cv_versions_present %}
  _{{ please_see_my_cv }} CV here:
  [html]({{ "cv.html" | prepend: site.baseurl }}),
  [pdf]({{ "cv.pdf" | prepend: site.baseurl }})._
{% elsif html_cv_present %}
  _{{ please_see_my_cv }} [CV]({{ "cv.html" | prepend: site.baseurl }})._
{% elsif pdf_cv_present %}
  _{{ please_see_my_cv }} [CV]({{ "cv.pdf" | prepend: site.baseurl }})._
{% endif %}
