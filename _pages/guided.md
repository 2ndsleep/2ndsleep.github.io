---
title: Guided Training
permalink: /guided
layout: archive
collection: service
---
If you're starting out, consider doing the training in this order.

{% assign entries_layout = page.entries_layout | default: 'list' %}
<div class="entries-{{ entries_layout }}">
  {% include filtered_collection.html collection='services' filter_key='guided' filter_value=true sort_by=guided_order sort_order=page.sort_order type=entries_layout %}
</div>