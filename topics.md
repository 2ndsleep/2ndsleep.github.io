---
title: Blog Topics
---
# Topics

This will be a list of topics that I've blogged about. Visitors will be able to go directly to the topic instead of searching through my blog. Clicking an item will take you to a description of the topic and a list of all the different procedures associated with the topic, like "how to deploy a new virtual machine," or "how to install a DNS server."

I don't think I like the bullet points next to each item.

{% for service in site.services %}
- ### [{{ service.name }}]({{ service.url }})
{% endfor %}
