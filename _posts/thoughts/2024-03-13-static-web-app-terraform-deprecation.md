---
title: Terraform Version Constraint Syntax (Or "Learning From Our Mistakes")
category: thoughts
tags: static-web-app terraform
---
So I've just started this project and spent all this time fine-tuning my first series of actionable posts to deploy an [Azure Static Web App]({% link _services/web/static-web-app.md %}). I published the last post on March 4, 2024 and fucking four days later, Terraform releases an update where they are deprecating the **azurerm_static_site** resource. Are you serious??!!<!--more-->

The procedures in those posts will still work as of now but eventually will stop working. I'd like to make this as evergreen as possible, so I am going to update those posts soon. But now I have to make new little screenshots which is kind of a pain in the ass. I set an artificial deadline for myself to have all the posts released by the first week of March, but if I had waited, I could have made those changes before releasing it. Let this be a lesson: always procrastinate.

Anyway, if you've already followed the posts and received your [certificate of completion]({% post_url /learn/web/static-web-app/procedures/2024-03-04-update-app %}#{{ 'Achievement Unlocked!' | slugify }}) and want to update everything to the correct Terraform resources, I'll show you how. This conveniently is a way to demonstrate how the Terraform syntax works for versioning.

## Update Terraform Configuration

This is pretty easy, but there's a little wrinkle with updating the **azurerm** provider that makes it not super straightforward.

### I Can Admit My Mistakes

First, I screwed up a bit. On line 5 of the [*base.tf*]({% post_url /learn/web/static-web-app/procedures/2024-02-28-swa-terraform %}#{{ 'Terraform Settings' | slugify }}) file, I said to specify the provider version as `~> 3.9.0`. That is a mistake. At the time that I published my original post, the newest release of the azurerm Terraform provider was [3.93.0](https://registry.terraform.io/providers/hashicorp/azurerm/3.93.0/docs). My stupid brain was thinking "we need at least version 3.90," but what I used says "we need the most recent version of 3.9.x but less than 3.10."

This is stupid for two reasons. One is that I fucked up the syntax like I mentioned (let's get over that, okay??). Secondly is that there is nothing special about version 3.90 that I was interested in, so I honestly don't know what I was thinking. Either way, let's talk about how to fix that.

You can find the original **incorrect** Terraform code [here](https://github.com/2ndsleep/{{ site.data.fake.infrastructure_repo }}/tree/web/static-web-app/terraform/public-web-site-swa).
{: .notice--info}

### Update azurerm Provider

Remember that when you run `terraform init`, the **azurerm** provider is downloaded to the *.terraform* folder. But since I used the wrong [version constraint syntax](https://developer.hashicorp.com/terraform/language/expressions/version-constraints#version-constraint-syntax), we'll never get anything higher than version 3.9.x of the azurerm provider. There are a few ways to fix it, and I'll demonstrate each of the Terraform version constraint syntax options to show you how.

A quick note about versioning. A common type of versioning is [semantic versioning](https://semver.org/) where you have your version numbers in this format: `MAJOR.MINOR.PATCH` (example: `3.14.2`). The highest number (`3` in our example) is the major version that has significant changes that may break your Terraform configuration. The middlest number (`14`) is the minor version and it's expected that this version will have improvements over the previous minor version but will not break your configuration. The patch number (`2`) usually addresses a bug fix and is not expected to break your configuration.
{: .notice--info}

The first way is to use the brute force method of the `=` operator to say "we only want a specific version and no other version."

``` terraform
version = "= 3.95.0"
```

This is useful if you know that there is only a certain version that will work for your configuration. However, you're also saying you never want to use a future version. Maybe that's your scenario, but it's not the one I want to use here. I want to be able to use future versions because the provider changes as Azure changes.

The second option is to say that we *don't* want to use version 3.9.0, but we can use any other version.

``` terraform
version = "!= 3.9.0"
```

This might be useful if there is a bug in a certain version and you want to make sure it's never used, but otherwise you don't care.

Those two options will work, but we have some more flexibility to allow us to specify a minimum. Using the `>` syntax, we can say we want anything greater than 3.9.

``` terraform
version = "> 3.9.0"
```

This will tell Terraform to download anything newer than 3.9.0 which effectively is telling it to download the newest version. You can also use the `>=`, `<`, and `<=` operators to respectively specify versions greater than or equal to, less than, and less than or equal to.

Finally, on to the most confusing operator and the one that I used. The `~>` operator (known as the **pessimistic constraint operator**) says three things:

- Use the version specified as the minimum.
- Use the newest version of the rightmost version component. For example, the `3` in version `1.2.3`. 
- Do not use a higher version than the next rightmost version component. For example, the `2` in version `1.2.3`.

Here are the examples from the [Terraform docs](https://developer.hashicorp.com/terraform/language/expressions/version-constraints#-3):

- `~> 1.0.4`: Allows Terraform to install `1.0.5` and `1.0.10` but not `1.1.0`.
- `~> 1.1`: Allows Terraform to install `1.2` and `1.10` but not `2.0`.

Like I said, I don't know what was going through my head when I originally authored my configuration, so let's go through two possibilities.

It's possible that I meant any minor version greater than version 3.9 but no major versions above 3. In that case, here's the syntax to use.

``` terraform
version = "~> 3.9"
```

It's possible that I meant that I wanted any patch fixes to version 3.90 (meaning any 3.90.x version, but not 3.91 or greater). However, that would still be a problem in this case since we couldn't get to version 3.95 or greater which has the new Static Web App resource that we want to use. I think what I most likely meant was this:

``` terraform
version = "~> 3.90"
```

This says use version 3.90 or greater, but less than version 4. Version 4 would be a major version update and a major version is more likely to have breaking changes that will make our configuration stop working whereas a minor version update is less likely to break things.

Any of the above examples will work, but what I didn't know at the time was that version 3.95 was about to be released that has a new resource that I want to use. So let's affirmatively state that we want at least 3.95 by using `~> 3.95`. Update your *base.tf* file to this:

``` terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.95"
    }
  }

  required_version = ">= 0.12"
}

provider "azurerm" {
  features {}
}
```
