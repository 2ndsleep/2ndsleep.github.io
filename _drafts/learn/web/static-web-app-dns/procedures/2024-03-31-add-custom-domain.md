---
title: Add Custom www Domain
categories: web static-web-app-custom-domain procedure
sort_order: 6
description: Let's use a real URL instead of stupid one.
---
{% assign fqdn = 'www.' | append: site.data.fake.company_domain %}

Right now, our Static Web App is using the default URL that was assigned to it by Microsoft, which is **{{ site.data.web.static_web_app_basic.swa_url }}**. As I noted earlier, we don't want to put "Visit us at {{ site.data.web.static_web_app_basic.swa_url }}!" in our email signature. We want to use the corporate domain for {{ site.data.fake.company_name }}, which is **{{ site.data.fake.company_domain }}**.<!--more-->

{{ site.data.fake.company_name }} isn't using Azure DNS quite yet which would make this a tad bit easier. We purchased the domain of {{ site.data.fake.company_domain }} from a third-party like GoDaddy ({% include reference.html item='fake_company' anchor_text=site.data.fake.ceo_name %} can't remember because he bought it while at Burning Man). In any event, we can use CNAME records to point to our Static Web App.

This post shows you how to add the **www** domain (**{{ fqdn }}** in our case). But you can use any domain you want. Maybe your business is way into squirrels, so you create **squirrels.example.com**?
{: .notice--info}

The previous [basic Static Web App]({% link _services/web/static-web-app.md %}) series dealt with our web application, but we're switching gears back to pure infrastructure management using Terraform. This post will show you how to do this through infrastructure as code, since that's what we do here at Second Sleep. But the approach is based on [this Microsoft doc](https://learn.microsoft.com/en-us/azure/static-web-apps/custom-domain-external).

## Add CNAME Record in Your DNS

First, you'll need to add a CNAME record in your DNS provider that points to the default *azurestaticapps.net* domain of your Static Web App that is created automatically by Azure.

If you don't do this part, your Terraform deployment will fail.
{: .notice--info}

### Get Default URL

In our [Deploy Static Web App]({% post_url /learn/web/static-web-app/procedures/2024-02-28-swa-terraform %}#{{ 'Admire Our Work' | slugify }}) post, we had three ways to find the default URL. Pick your favorite and copy the URL.

### Update DNS

Okay, this will depend on your DNS provider so I can't offer step-by-step instructions. See your provider's documentation (here's a few common ones: [GoDaddy](https://www.godaddy.com/help/add-a-cname-record-19236), [Namecheap](https://www.namecheap.com/support/knowledgebase/article.aspx/434/2237/how-do-i-set-up-host-records-for-a-domain/), [Squarespace](https://support.squarespace.com/hc/en-us/articles/360002101888-Adding-custom-DNS-records-to-your-Squarespace-managed-domain)).

However you do it, here are the values you'll need to add.

|Setting|Value|
|-------|-----|
|Type|`CNAME`|
|Host|`www.yourdomain.com`|
|Value|the default URL of your Static Web App you copied in the section above|
|TTL (if applicable)|leave as the default value|

*Just in case you need to be told this, replace the `yourdomain.com` value with your actual domain.*

## Update Terraform

Now let's define our custom domain resource in Terraform. Add the following to your *main.tf* file.

``` terraform
resource "azurerm_static_web_app_custom_domain" "public_site_www" {
  static_web_app_id = azurerm_static_web_app.public_site.id
  domain_name = "www.example.com"
  validation_type = "cname-delegation"
}
```

A few notes here.

- The `azurerm_static_web_app_custom_domain` resource needs to know which Static Web App resource we're adding the custom domain to. Since we have defined the Static Web App already, we'll use that value for the `static_web_app_id` property.
- We're using CNAME validation (`validation_type = "cname-delegation"`), meaning that the Static Web App is going to check that the CNAME record actually exists when we deploy this.
- The `domain_name` value is hard-coded, meaning we've explicitly defined it as `www.example.com`. We've already hard-coded a few values, which I don't love. In this case, your custom domain is not going to be `www.example.com`, so we need a better way to do this.

### Terraform Variables

So far, I've been encouraging a bad practice, which is hard-coding all your values. I'll allow what we've hard-coded so far in the `azurerm_resource_group` and `azurerm_static_web_app` resources, but it's high time we do things a little more flexibly.

Instead of hard-coding our custom domain, let's pass it to the Terraform configuration as a variable. Create a new file named *variables.tf* and add the following.

``` terraform
variable "www_domain_name" {
  type = string
  description = "FQDN of the www name for this custom domain."
}
```

Great! Now we have defined a variable that we will specify when we apply our configuration. Now we need to reference this variable in our configuration. Update the `domain_name` line in *main.tf* to the following.

``` terraform
resource "azurerm_static_web_app_custom_domain" "public_site_www" {
  static_web_app_id = azurerm_static_web_app.public_site.id
  domain_name = var.www_domain_name
  validation_type = "cname-delegation"
}
```

But how do we specify the actual custom domain value for that variable? There's a few ways and that's next.

### Input Variable

One way to supply the value of the `www_domain_name` variable is to let Terraform ask you. Let's run a plan to see it in action.

``` shell
terraform plan
```

{% highlight output %}
var.www_domain_name
  FQDN of the www name for this custom domain.

  Enter a value: 
{% endhighlight %}

Enter the full-qualified domain name for your custom domain and press Enter. In my case, I'm going to type `{{ fqdn }}`.

### Pass Variable in Command Line

You can also pass the command line directly on the command line using the `-var` option instead of waiting for Terraform to ask.

``` shell
terraform plan -var="www_domain_name={{ fqdn }}"
```

The syntax for passing a command line is a little funky and gets funkier when the value has strange characters or is an array or object. You probably won't use this much because it's difficult to automate and just kind of sucks in general. For more about the command line variable syntax, see [this](https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line).

### Variable Definition File

Here's 
**scramoose.tfvars**

``` terraform
www_domain_name = "www.scramoose.dev"
```