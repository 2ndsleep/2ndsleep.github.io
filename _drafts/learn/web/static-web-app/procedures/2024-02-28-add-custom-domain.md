---
title: Add Custom Domain
categories: web static-web-app procedure
sort_order: 6
description: Let's use a real URL instead of stupid one.
published: false
---
{% assign engineer_name = site.fake_username | capitalize %}
{% assign fake_company_name_lower = site.fake_company_name | downcase %}
{% assign infrastructure_repo = '-infrastructure' | prepend: fake_company_name_lower %}
{% assign branch_name = 'custom-domain' %}
{% assign swa_url = 'witty-pond-0f141550f.4.azurestaticapps.net' %}

Right now, our Static Web App is using the default URL that was assigned to it by Microsoft, which is **{{ swa_url }}**. As I noted earlier, we don't want to put "Visit us at {{ swa_url }}!" in our email signature. We want to use the corporate domain for {{ site.fake_company_name }}, which is **{{ site.fake_company_domain }}**.<!--more-->

{{ site.fake_company_name }} isn't using Azure DNS quite yet which would make this a tad bit easier. We purchased the domain of {{ site.fake_company_domain }} from a third-party like GoDaddy ({% include reference.html item='fake_company' anchor_text=site.fake_ceo_name %} can't remember because he purchased it while at Burning Man). But in any event, we can use CNAME records to point to our Static Web App.

The last few posts have dealt with our web application, but we're switching gears back to our infrastructure management using Terraform.
{: .notice--info}

## 