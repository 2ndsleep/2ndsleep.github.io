---
title: Services
permalink: /services
layout: single
---
{% assign services = site.services | sort: "name" %}

{% for service in services %}
## [{{ service.name }}]({{ service.url }})
{{ service.excerpt }}
{% endfor %}

*Done*