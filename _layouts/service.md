---
layout: single
---
{{ content }}


{% assign service_posts = site.posts | where: "service", page.title %}
{% assign description_posts = service_posts | where: "type", "description" %}
{% assign procedures = site.procedures | where: "service", page.title | sort: "order" %}

{% if description_posts.size > 0 %}
<h2>Learn more about {{ page.title }}</h2>
<ul>
  {% for description_post in description_posts %}
    <li><a href="{{ description_post.url }}">{{ description_post.title }}</a></li>
  {% endfor %}
</ul>
{% endif %}

{% if procedures.size > 0 %}
  <h2>Do it yourself</h2>
  {% for procedure in procedures %}
    <ul>
      <li>
        <a href="{{ procedure.url }}">{{ procedure.name }}</a><br />
        {{ procedure.excerpt }}
      </li>
    </ul>
  {% endfor %}
{% endif %}