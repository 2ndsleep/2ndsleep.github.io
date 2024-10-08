---
title: Terraform Variables
categories: devops terraform-variables explainer
sort_order: 1
description: Variables make your Terraform code more flexible and reusable.
tags: terraform 
---
If you've completed the [Static Web App]({% link _services/web/static-web-app.md %}) series, I've got a confession. I took a few shortcuts in my Terraform code by hard-coding some values.<!--more--> Like the `name` argument here:

``` terraform
resource "azurerm_static_web_app" "public_site" {
  name = "{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1"
  resource_group_name = azurerm_resource_group.public_site.name
  location = azurerm_resource_group.public_site.location
}
```

And like everything here:

``` terraform
resource "azurerm_resource_group" "public_site" {
  name = "{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1"
  location = "East US 2"
}
```

Why is this a problem? Well, technically it's not. You can use the name `{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1` and the region `East US 2` everywhere in your code if you want. But as your company grows, you may want to deploy these resources in another region for redundancy.

In our scenario, {% include reference.html item='fake_company' %} decides they want to have another static web site deployed in the Central US region in case our site in the East US 2 region goes down. We also want to give the new static web app a different name so we can distinguish the resources from each other.

If you're not familiar with the term *hard-coded*, it simply means that you're typing the value directly into the configuration like we have done with the `"{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1"` name value.
{: .notice--info}

## What We *Don't* Want to Do

If you're new to IaC, you may immediately think of two ways to accomplish this.

- :x: Change the name and region values and deploy again.
- :x: Add a new `azurerm_resource_group` and `azurerm_static_web_app` resource for the new static web app.

These approaches will work, but they aren't good practices. For the first option, if you change the values, you can deploy the new static web app in the Central US region, but then you lose the configuration for the first static web app you deployed in the East US 2 region. Let's say your intern goes into the portal and deletes your original static web app in the East US 2 region. To re-create that static web app, you'd have to change your configuration back to the original values and redeploy. And if you wanted to add features to both of these static web apps, you'd have to deploy your configuration for one web app, change the values to the other web app, and deploy again. This gets messy. Plus which version is the "correct" one to commit to Git?

The second method to add another set of resources is a better option. You'd simply double up your resources with one for each region, like this.

``` terraform
resource "azurerm_static_web_app" "public_site" {
  name = "{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1"
  resource_group_name = azurerm_resource_group.public_site.name
  location = azurerm_resource_group.public_site.location
}

resource "azurerm_resource_group" "public_site" {
  name = "{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1"
  location = "East US 2"
}

resource "azurerm_static_web_app" "public_site" {
  name = "{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-2"
  resource_group_name = azurerm_resource_group.public_site.name
  location = azurerm_resource_group.public_site.location
}

resource "azurerm_resource_group" "public_site" {
  name = "{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-2"
  location = "Central US"
}
```

This works better but the sting here is that it violates the [DRY]({% post_url /learn/basics/iac/explainer/2024-01-31-iac-principles %}#dry) principle. In short, we're copying a lot of the same code which means that if we want to change something about our static web apps for both regions, we have to remember to do it for all of the resource blocks. This wastes time and you can easily forget to update all of the resources.

## How Variables Help

Up until now, variables wouldn't have been very useful for us. But since we want to deploy two static web apps that are identical in every way except for their name and region, we will want to use variables for the name and region values. This will allow us to specify a different name and region for each deploy, but keep every other part of the static web app the same for both.

You can see that we've used variables on lines 2, 8, and 9 instead of creating resources for each region.

{% highlight terraform linenos %}
resource "azurerm_static_web_app" "public_site" {
  name = var.static_web_app_name
  resource_group_name = azurerm_resource_group.public_site.name
  location = azurerm_resource_group.public_site.location
}

resource "azurerm_resource_group" "public_site" {
  name = var.resource_group_name
  location = var.location
}
{% endhighlight %}

There are three main parts to using Terraform variables.

- Define the variable using a `variable` block. This is a way of telling Terraform that a variable exists and will be used somewhere in your configuration.
- Use the variable in your configuration with the `var` keyword instead of hard-coded values.
- Give the variable a value when you deploy the configuration. This will be the value that's actually used for that variable.

## Defining Variables

You can define variables in any *.tf* files, but most people put them in a file called *variables.tf*. You can have as many variables as you like. The basic syntax for a variable looks like this:

``` terraform
variable "some_variable_name" {
  type = <type>
  description = "Some description here."
}
```

The `description` property is optional and some people argue that it shouldn't be required if its description is obvious from the name. I think that's a perfectly valid philosophy and you should follow that if that feels right. I always supply the description probably due to some undiagnosed personality disorder. My brain won't let me not add a description!

The `type` property is optional and defaults to `any`, but no serious Terraform developer will forgo the `type` value so I'm not even entertaining it here.

Okay, since both the `type` and `description` properties are optional, I guess the most basic syntax to define a variable is actually `variable "some_variable_name" {}`. But I don't want to live in a world that defines Terraform variables that way, so I'm always going to include at least a `type` and `description`.
{: .notice--info}

## Using Variables

To use a variable in a configuration, you just use the `var` keyword followed by a `.` and the name of the variable. In the example below, we added the `some_variable_name` variable by adding `var.some_variable_name` on line 2.

{% highlight terraform linenos %}
resource "azurerm_resource_group" "some_resource_group" {
  name = var.some_variable_name
  location = "East US 2"
}
{% endhighlight %}

## Setting Variable Values



setting vars
variable precedence
setting variables
    input
    command line
    tfvars