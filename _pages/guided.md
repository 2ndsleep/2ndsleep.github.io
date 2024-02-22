---
title: Guided Training
permalink: /guided
layout: single
collection: service
header:
  overlay_image: /assets/images/pages/second-sleep-banner.png
---
The [training](/learn) content on this site is part of building the platform infrastructure for a fictional company called [{{ site.data.fake.company_name }}](/about#{{ site.data.fake.company_name }}). You can drop into the training at any point you want, but if you'd like to follow along with creating {{ site.data.fake.company_name }} from scratch, consider doing the training in this order. This is especially great if you're beginning your cloud journey.

{% assign entries_layout = page.entries_layout | default: 'list' %}
<div class="entries-{{ entries_layout }}">
  {% include filtered_collection.html collection='services' filter_key='guided' filter_value=true sort_by='guided_order' sort_order=page.sort_order type=entries_layout %}
</div>