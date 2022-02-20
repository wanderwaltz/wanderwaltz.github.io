---
layout: home
---

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">
      <span class="post-date">{{ post.date | date_to_string }}</span> {{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
