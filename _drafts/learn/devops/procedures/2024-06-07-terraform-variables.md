---
title: Add Terraform Variables
categories: devops terraform-variables procedure
sort_order: 1
description: Let's convert those hard-coded values to variables!
repos:
  - alias: infrastructure_repo
    tag: web/static-web-app/new-terraform-resource
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

We want to change all those quoted values into variables so that we can potentially use the same configuration again but with different names and regions.

## Define Variables

Alright then, let's get to it. The first thing we do is define our Terraform variables for these properties:

- resource group name
- resource group location
- Static Web App name

Create a file named *variables.tf* and add the following:

``` terraform
variable "resource_group_name" {
  type = string
  description = "Name of the resource group where this Static Web App will be deployed."
}

variable "resource_group_location" {
  type = string
  description = "Region where the resource group for this Static Web App will be created."
}

variable "public_site_name" {
  type = string
  description = "Name of the Static Web App resource."
}
```

The `description` property is optional and some people argue that it shouldn't be required if its description is obvious from the name. I think that's a perfectly valid philosophy and you should follow that if that feels right. I always supply the description probably due to some undiagnosed personality disorder. My brain won't let me not add a description!

The `type` property is optional and defaults to `any`, but no serious Terraform developer will forgo the `type` value so I'm not even entertaining it here.
{: .notice--info}

That wasn't too hard. We haven't used our variables, but let's validate our configuration just to make it's error-free.


``` shell
terraform validate
```

{% highlight console %}
Terraform validate output
{% endhighlight %}

## Use Variables

Okay we defined variables, but this configuration won't do shit until we actually tell Terraform that we want to use them. We reference our variables by using the `var.<variable>` format. Let's update our configuration to reference our new variables by replacing every argument value in our *main.tf* that is quoted with the variable reference. Your file should look like this now.

``` terraform
resource "azurerm_resource_group" "public_site" {
  name = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_static_web_app" "public_site" {
  name = var.public_site_name
  resource_group_name = azurerm_resource_group.public_site.name
  location = azurerm_resource_group.public_site.location
}

output "static_site_hostname" {
  value = azurerm_static_web_app.public_site.default_host_name
}
```

## Specify Variable Values

If this is your first time using Terraform variables, you're probably wondering "how do I actually set the variable value?" In other words, "how do I tell Terraform that `resource_group_name` should be `{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1`?" Well, there's a few ways to set those variables values.

### Type Variables at Runtime

One way to supply the value of the variables is to let Terraform ask you. Let's run a plan to see it in action.

``` shell
terraform plan
```

{% highlight output %}
Terraform output
{% endhighlight %}

### Pass Variable in Command Line

You can also pass the value of variables directly on the command line using the `-var` option instead of waiting for Terraform to ask.

``` shell
terraform plan -var="resource_group_name={{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1" -var="resource_group_location=East US 2" -var="public_site_name={{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1"
```

Specifying your variables this way can be kind of sucky, especially if the values contain unusually characters, so see [this](https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line) for help.

### Variable Definition File

The most IaC-ish way to do this is to define the variable values in a *.tfvars* file. If you've used the standard Terraform exclusions in your *.gitignore* file, then this file won't be committed to your repository, which is good if you're using this for local testing.

Create a file named *terraform.tfvars* and add the following.

``` terraform
resource_group_name = "{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1"
resource_group_location = "East US 2"
public_site_name = "{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1"
```

Now run your plan and you'll see that it will use the variables you defined in the *terraform.tfvars* file.

