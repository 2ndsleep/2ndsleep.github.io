---
title: Terraform Version Constraint Syntax (Or "Learning From Our Mistakes")
category: thoughts
tags: static-web-app terraform git
toc: true
---
So I've just started this project and spent all this time fine-tuning my first series of actionable posts to deploy an [Azure Static Web App]({% link _services/web/static-web-app.md %}). I published the last post on March 4, 2024 and four effing days later, Terraform releases an update where they are deprecating the **azurerm_static_site** resource. We're now supposed to use the [**azurerm_static_web_app**](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/static_web_app) resource. Are you serious??!!<!--more-->

The procedures in those posts will still work as of now but they will eventually stop working. I'd like to make this as evergreen as possible, so I am going to update those posts soon. But now I have to make new little screenshots which is kind of a pain in the ass. I set an artificial deadline for myself to have all the posts released by the first week of March, but if I had waited, I could have made those changes before releasing it. Let this be a lesson: always procrastinate.

Anyway, if you've already followed the posts and received your [certificate of completion]({% post_url /learn/web/static-web-app/procedures/2024-03-04-update-app %}#{{ 'Achievement Unlocked!' | slugify }}) and want to update everything to the correct Terraform resources, I'll show you how. This conveniently is a way to demonstrate how the Terraform syntax works for versioning.

## Update Terraform Configuration

This is pretty easy, but there's a little wrinkle with updating the **azurerm** provider that makes it not super straightforward.

### I Can Admit My Mistakes

First, I screwed up a bit. On line 5 of the [*base.tf*]({% post_url /learn/web/static-web-app/procedures/2024-02-28-swa-terraform %}#{{ 'Terraform Settings' | slugify }}) file, I said to specify the provider version as `~> 3.9.0`. That is a mistake. At the time that I published my original post, the newest release of the azurerm Terraform provider was [3.93.0](https://registry.terraform.io/providers/hashicorp/azurerm/3.93.0/docs). My stupid brain was thinking "we need at least version 3.90," but the code I used says "we need the most recent version of 3.9.x but less than 3.10."

This is stupid for two reasons. One is that I messed up the syntax like I mentioned (let's get over that, okay??). Secondly is that there is nothing special about version 3.90 that I was interested in, so I honestly don't know what I was thinking. Either way, let's talk about how to fix that.

You can find the original *incorrect* Terraform code [here](https://github.com/2ndsleep/{{ site.data.fake.infrastructure_repo }}/releases/tag/web%2Fstatic-web-app%2Fbasic) and the *correct* Terraform code [here](https://github.com/2ndsleep/{{ site.data.fake.infrastructure_repo }}/releases/tag/web%2Fstatic-web-app%2Fnew-terraform-resource).
{: .notice--info}

### Update azurerm Provider

Remember that when you run `terraform init`, the **azurerm** provider is downloaded to the *.terraform* folder. But since I used the wrong [version constraint syntax](https://developer.hashicorp.com/terraform/language/expressions/version-constraints#version-constraint-syntax), we'll never get anything higher than version 3.9.x of the azurerm provider. There are a few ways to fix it, and I'll demonstrate each of the Terraform version constraint syntax options to show you how.

A quick note about versioning. A common type of versioning is [semantic versioning](https://semver.org/) where you have your version numbers in this format: `MAJOR.MINOR.PATCH` (example: `3.14.2`). The highest number (`3` in our example) is the major version that has significant changes that may break your Terraform configuration. The middlest number (`14`) is the minor version and it's expected that this version will have improvements over the previous minor version but will not break your configuration. The patch number (`2`) usually addresses a bug fix and is not expected to break your configuration.
{: .notice--info}

#### `=` Operator

The first way is to use the brute force method of the `=` operator to say "we only want a specific version and no other version."

``` terraform
version = "= 3.95.0"
```

This is useful if you know that there is only a certain version that will work for your configuration. However, you're also saying you never want to use a future version. Maybe that's your scenario, but it's not the one I want to use here. I want to be able to use future versions because the azurerm provider will change as Azure changes.

#### `!=` Operator

The second option is to say that we *don't* want to use version 3.9.0, but we can use any other version.

``` terraform
version = "!= 3.9.0"
```

This might be useful if there is a bug in a certain version and you want to make sure it's never used, but otherwise you don't care.

#### `>`, `>=`, `<`, `>=` Operators

The last two options will work, but we have some more flexibility to allow us to specify a minimum. Using the `>` syntax, we can say we want anything greater than 3.9.

``` terraform
version = "> 3.9.0"
```

This will tell Terraform to download anything newer than 3.9.0 which effectively is telling it to download the newest version. You can also use the `>=`, `<`, and `<=` operators to respectively specify versions greater than or equal to, less than, and less than or equal to.

#### `~>` Operator

Finally, on to the most confusing operator and the one that I used. The `~>` operator (known as the **pessimistic constraint operator**) says three things:

- Use the version specified as the minimum.
- Use the newest version of the rightmost version component. For example, the `3` in version `1.2.3`. 
- Do not use a higher version than the next rightmost version component. For example, the `2` in version `1.2.3`.

Here are the examples from the [Terraform docs](https://developer.hashicorp.com/terraform/language/expressions/version-constraints#-3):

> - `~> 1.0.4`: Allows Terraform to install `1.0.5` and `1.0.10` but not `1.1.0`.
> - `~> 1.1`: Allows Terraform to install `1.2` and `1.10` but not `2.0`.

Like I said, I don't know what was going through my head when I originally authored my configuration, so let's go through two possibilities.

It's possible that I meant any minor version greater than version 3.9 but no major versions above 3. In that case, here's the syntax I should have used.

``` terraform
version = "~> 3.9"
```

It's possible that I meant that I wanted any patch fixes to version 3.90 (meaning any 3.90.x version, but not 3.91 or greater). However, that would still be a problem in this case since we couldn't get to version 3.95 or greater which has the new Static Web App resource that we want to use. I think what I most likely meant was this:

``` terraform
version = "~> 3.90"
```

This says use version 3.90 or greater, but less than version 4. Version 4 would be a major version update and a major version is more likely to have breaking changes that will make our configuration stop working whereas a minor version update is less likely to break things.

Any of the above examples will work to get us to the newest version *except for `~> 3.9` for reasons I'll explain later*, but what I didn't know at the time was that version 3.95 was about to be released that has a new resource that I want to use. So let's affirmatively state that we want at least 3.95 by using `~> 3.95`. Update your *base.tf* file to this.

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

### Update Resource

This part is easy. We need to replace every instance of **azurerm_static_site** with **azurerm_static_web_app** in our *main.tf* file. This is the resource definition on line 6 and the output value on line 13.

{% highlight terraform linenos %}
resource "azurerm_resource_group" "public_site" {
  name = "{{ site.data.fake.company_code }}-webpub-prd-1"
  location = "East US 2"
}

resource "azurerm_static_web_app" "public_site" {
  name = "{{ site.data.fake.company_code }}-webpub-prd-1"
  resource_group_name = azurerm_resource_group.public_site.name
  location = azurerm_resource_group.public_site.location
}

output "static_site_hostname" {
  value = azurerm_static_web_app.public_site.default_host_name
}
{% endhighlight %}

## Re-Initialize Configuration

Now that you've updated your provider version, you'd think you could simply run `terraform plan` and away you go. If you do, you'll get a message like this.

{% highlight console %}
│ Error: Inconsistent dependency lock file
│ 
│ The following dependency selections recorded in the lock file are inconsistent with the current configuration:
│   - provider registry.terraform.io/hashicorp/azurerm: locked version selection 3.9.0 doesn't match the updated version constraints "~> 3.95"
│ 
│ To update the locked dependency selections to match a changed configuration, run:
│   terraform init -upgrade
|
{% endhighlight %}

Terraform is saying that the provider you've already downloaded isn't the version you specified in your *base.tf* file. Terraform is playing it safe by not automatically updating the provider in case you're still in the middle of testing things.

Similarly, if you run `terraform validate`, you'll get a message saying that it doesn't know what the azurerm_static_web_app resource is. That's because it's still using version 3.9 and the azurerm_static_web_app resource isn't defined there.
{: .notice--info}

Terraform tells you exactly what you need to do here, which is run this command.

``` shell
terraform init -upgrade
```

After running that, you'll see that there will be two versions of the azurerm provider in your *.terraform* folder: version 3.9.0 and whatever the newest 3.x version is.

## Re-Deploy Configuration Or Maybe Not

Now you're finally ready to deploy. As always, let's be safe and run a plan to see what's going to happen.

``` shell
terraform plan
```

Now you'd expect it to tell you that there is nothing to change, correct? After all, we haven't made any changes to our actual resource. Well unfortch, we did specify a different type of resource and in Terraform's view that means a brand new resource will be created and the old one no longer exists. You'll see output like this:

{% highlight console %}
Terraform will perform the following actions:

  # azurerm_static_site.public_site will be destroyed
  # (because azurerm_static_site.public_site is not in configuration)
  - resource "azurerm_static_site" "public_site" {
      - api_key             = (sensitive value) -> null
      - app_settings        = {} -> null
      - default_host_name   = "kind-stone-02389c60f.4.azurestaticapps.net" -> null
      - id                  = "/subscriptions/{{ site.data.fake.subscription_guid }}/resourceGroups/{{ site.data.fake.company_code }}-webpub-prd-1/providers/Microsoft.Web/staticSites/{{ site.data.fake.company_code }}-webpub-prd-1" -> null
      - location            = "eastus2" -> null
      - name                = "{{ site.data.fake.company_code }}-webpub-prd-1" -> null
      - resource_group_name = "{{ site.data.fake.company_code }}-webpub-prd-1" -> null
      - sku_size            = "Free" -> null
      - sku_tier            = "Free" -> null
      - tags                = {} -> null

      - timeouts {}
    }

  # azurerm_static_web_app.public_site will be created
  + resource "azurerm_static_web_app" "public_site" {
      + api_key                            = (sensitive value)
      + configuration_file_changes_enabled = true
      + default_host_name                  = (known after apply)
      + id                                 = (known after apply)
      + location                           = "eastus2"
      + name                               = "{{ site.data.fake.company_code }}-webpub-prd-1"
      + preview_environments_enabled       = true
      + resource_group_name                = "{{ site.data.fake.company_code }}-webpub-prd-1"
      + sku_size                           = "Free"
      + sku_tier                           = "Free"
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ static_site_hostname = "kind-stone-02389c60f.4.azurestaticapps.net" -> (known after apply)
{% endhighlight %}

Never mind that it's the same underlying type of Azure resource. That's just the way Terraform works. In the Terraformm state file, this is a different resource, so the old one's gotta go and a new "different" resource will be created.

**But wait, don't run `terraform apply` yet!** (I'm sorry if you already did. I should have warned you earlier. If you did, it's okay, I have a [solution](#whoops-i-accidentally-applied-my-configuration).) We can fix this without redeploying by updating our state file.

## Update State File

Terraform has some commands to make your state file align with reality. What we need to do is get rid of our **azurerm_static_site** resource from the state file and import the Static Web App Azure resource as an **azurerm_static_web_app** Terraform resource. Whew, that sounds like a lot!

First, let's import our **azurerm_static_web_app** resource using the `terraform import` command. The full syntax looks like this:

``` shell
terraform import TERRAFORM_RESOURCE AZURE_RESOURCE_ID
```

The **TERRAFORM_RESOURCE** is in the form of **RESOURCE_TYPE.NAME** just as we have it defined in our configuration. In our case, it is `azurerm_static_web_app.public_site`.

The **AZURE_RESOURCE_ID** is the unique ID given to each resource in Azure. We haven't talked about it much, but you can find it in most resources' Properties blade in the portal, except for a Static Web App for some reason. In our case, we'll grab it from the state. Open the *terraform.state* file and look for the azurerm_static_site resource (`"type": "azurerm_static_site"`). In that resource, you'll find the Azure ID (`"id": "/subscriptions/{{ site.data.fake.subscription_guid }}/resourceGroups/{{ site.data.fake.company_code }}-webpub-prd-1/providers/Microsoft.Web/staticSites/{{ site.data.fake.company_code }}-webpub-prd-1"`).

Put those two things together, and you get the command below which is saying "import the Azure resource with this ID into the azurerm_static_web_app.public_site Terraform resource in our state file." Yours will have a different subscription ID but will otherwise look the same if you've been following along.

``` shell
terraform import "azurerm_static_web_app.public_site" "/subscriptions/{{ site.data.fake.subscription_guid }}/resourceGroups/{{ site.data.fake.company_code }}-webpub-prd-1/providers/Microsoft.Web/staticSites/{{ site.data.fake.company_code }}-webpub-prd-1"
```

You'll see the output below and you'll see the **azurerm_static_web_app** resource in your state file.

{% highlight console %}
azurerm_static_web_app.public_site: Importing from ID "/subscriptions/{{ site.data.fake.subscription_guid }}/resourceGroups/{{ site.data.fake.company_code }}-webpub-prd-1/providers/Microsoft.Web/staticSites/{{ site.data.fake.company_code }}-webpub-prd-1"...
azurerm_static_web_app.public_site: Import prepared!
  Prepared azurerm_static_web_app for import
azurerm_static_web_app.public_site: Refreshing state... [id=/subscriptions/{{ site.data.fake.subscription_guid }}/resourceGroups/{{ site.data.fake.company_code }}-webpub-prd-1/providers/Microsoft.Web/staticSites/{{ site.data.fake.company_code }}-webpub-prd-1]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
{% endhighlight %}

Now let's remove the old **azurerm_static_site** Terraform resource from our state file. This uses the following syntax:

``` shell
terraform state rm TERRAFORM_RESOURCE
```

We only need to specify the Terraform resource because we're just deleting whatever is defined by that in the state file. So our command will be this:

``` shell
terraform state rm "azurerm_static_site.public_site"
```

{% highlight console %}
Removed azurerm_static_site.public_site
Successfully removed 1 resource instance(s).
{% endhighlight %}

Now your state file should look the way want it without having to redeploy. Let's run the plan again to make sure Terraform is seeing that everything is updated now.

``` shell
terraform plan
```

{% highlight console %}
No changes. Your infrastructure matches the configuration.
{% endhighlight %}

Noice, bro.

## Whoops, I Accidentally Applied My Configuration

If you ran `terraform apply` too quickly, you probably saw an error like this:

{% highlight console %}
│ Error: A resource with the ID "/subscriptions/{{ site.data.fake.subscription_guid }}/resourceGroups/{{ site.data.fake.company_code }}-webpub-prd-1/providers/Microsoft.Web/staticSites/{{ site.data.fake.company_code }}-webpub-prd-1"
already exists - to be managed via Terraform this resource needs to be
imported into the State. Please see the resource documentation for
"azurerm_static_web_app" for more information.
{% endhighlight %}

What happened is that Terraform destroyed the Azure resource and removed the azurerm_static_site Terraform resource from the state file. Then it went to create the azurerm_static_web_app resource immediately after that, but it did it so quickly that the Azure API hadn't quite caught up and told Terraform that the Static Web App resource was still there.

All you need to do is run `terraform apply` again and it will create the new azure_static_web_app resource.

This restores your Azure resource, but it is a different Static Web App resource which means it does not have our website content deployed to it. If you visit the site, it will be the temporary site that Microsoft throws up there. You'll need to run the GitHub Actions workflow again to deploy our custom site content. But another freaking problem is that the workflow only runs when we update the main branch of our {{ site.data.fake.web_public_repo }} repository.

But we can trick our repo into thinking something changed by adding an **empty commit**. This is exactly how it sounds: a commit without any changes. To do that, open a console in your local {{ site.data.fake.web_public_repo }} repo and run these commands:

``` shell
git commit --allow-empty -m "Trigger GitHub Actions workflow"
git push
```

Now go look at your GitHub Actions for the {{ site.data.fake.web_public_repo }} repo and make sure the workflow runs successfully.