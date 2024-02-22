---
title: Terraform
categories: basics iac explainer
sort_order: 3
description: Terraform can be used to manage Azure and more!
folder_tf:
  - name: web-api (working directory)
    children:
      - name: .terraform (providers and other Terraform stuff)
      - name: main.tf (configuration file)
        type: file
folder_tfstate:
  - name: web-api
    children:
      - name: .terraform
      - name: main.tf
        type: file
      - name: terraform.tfstate
        type: file
folder_tf_workspaces:
  - name: web-api
    children:
      - name: .terraform
      - name: terraform.tfstate.d
        children:
          - name: workspace1
            children:
              - name: terraform.tfstate
                type: file
          - name: workspace2
            children:
              - name: terraform.tfstate
                type: file
      - name: main.tf
        type: file
      - name: terraform.tfstate (default workspace state file)
        type: file
folder_tf_env:
  - name: terraform-configs
    children:
      - name: cool-new-app
        children:
          - name: dev
            children:
              - name: main.tf
                type: file
          - name: tst
            children:
              - name: main.tf
                type: file
          - name: prd
            children:
              - name: main.tf
                type: file
folder_tf_env_with_module:
  - name: terraform-configs
    children:
      - name: cool-new-app
        children:
          - name: app-module
            children:
              - name: main.tf
                type: file
          - name: dev
            children:
              - name: main.tf (references app-module)
                type: file
          - name: tst
            children:
              - name: main.tf (references app-module)
                type: file
          - name: prd
            children:
              - name: main.tf (references app-module)
                type: file
---
[**Terraform**](https://www.terraform.io/) is an open-source infrastructure as code (IaC) tool created by Hashicorp. You can write Terraform files to manage a number of cloud resources, including Azure, AWS, GCP, Oracle Cloud, and Alibaba Cloud.<!--more--> You can also use it to manage public [SaaS]({% post_url /learn/basics/cloud_intro/explainers/2024-01-02-as-a-service %}#software-as-a-service-saas) products, like Salesforce and Google Workspace or private clouds like VMware vSphere. Or even internal services, like Kubernetes, Helm, or TLS certificates. Shit man, you can even use it to manage Terraform itself!

I'll be using Terraform as the IaC solution in this blog. Here's why:

- Terraform can manage more than just Azure resources. It can also manage Entra ID, which Azure's native IaC tools can't fully manage since it's technically a different product from the rest of Azure.
- Terraform can manage more cloud providers than just Azure. We'll dip into a few multi-cloud scenarios, so Terraform will be helpful there.
- Terraform has a product called Terraform Cloud that will give us a detailed view of our deployments.
- Terraform is a little easier to read and understand than ARM templates or Bicep (IMHO).

This is not a knock against Azure's IaC tools. In fact, if you read my post about [ARM templates and Bicep]({% post_url /learn/basics/iac/explainers/2024-02-04-arm-bicep %}) you'll see that I gush over how great they are. If you think those tools would be better for your environment, I enjoin you to use them. Or use a combination of Terraform and Bicep if you want.

Please note that the examples in this post won't really work and are more for a conceptual overview. I mean, they'll work, but there's a lot of important information missing that you'll need to know before you can just start pounding out these commands on your keyboard. For a tutorial, go [here]({% post_url /learn/basics/iac/procedures/2024-02-06-azure-terraform-tutorial %}).
{: .notice--info}

## Terraform Overview

There are two important things to know about how Terraform works. First, it is a [declarative]({% post_url /learn/basics/iac/explainers/2024-01-31-iac-principles %}#declarative-code) language that is used to define your resources. However, Terraform doesn't intrinsically know about any resources, so secondly, it uses **providers** that tell Terraform how to manage the cloud resources. When you write your Terraform files, the first thing you'll do is specify the providers you'll be using. Since we'll be using Azure, we'll be using a lot of the **azurerm** provider. In that case, the azurerm provider will tell Terraform how to do things like create a resource group or deploy a virtual machine which Terraform doesn't know by itself.

Here's an example of a Terraform file.

``` terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}
```

If you deploy this code, literally nothing will happen to Azure. You're just telling Terraform to import the `azurerm` provider because you plan to do something in Azure. If you wanted to create a resource group named **{{ site.data.fake.company_code }}-monitr-inf**, you could add the `azurerm_resource_group` resource definition.

``` terraform
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "{{ site.data.fake.company_code }}-monitr-inf"
  location = "westus2"
}
```

## How Terraform Works

The file above is known as a Terraform **configuration**. Terraform configuration files end with the *.tf* extension. Each configuration has an associated **backend** where it stores metadata related to that configuration, most importantly the provider files and the **state**.

Let's go through that more slowly. When you author your configuration on your laptop and you're ready to test it out, the first thing you'll need to do is initialize everything using the `terraform init` command. This will download all the binaries for the providers (the files that make the providers work) to a hidden folder named *.terraform*.

All of these files (hidden or not) are located in a folder known as the Terraform **working directory**. Before you initialize the working directory, the only file in your working directory will be the configuration file. You will type your Terraform commands while in the working directory. For the examples below, let's assume our Terraform configuration will be for the infrastructure related to a web API we're building.

{% include filesystem.html id="folder_tf" %}

Typically, each Terraform configuration will map to a single Azure [resource group]({% post_url /learn/basics/azure_intro/explainer/2024-01-12-azure-hierarchy %}#resource-groups).
{: .notice--info}

The first time you deploy your configuration, Terraform will create a file named *terraform.tfstate*. This is called the **state file** and contains all the information about the resources you've deployed. As you make changes to your configuration and deploy them, the state file will be updated with those changes.

{% include filesystem.html id="folder_tfstate" %}

The purpose of the state file is so Terraform can check which properties of the resources need to be modified at each deployment. So if you deploy a VM and then later change the VM size (CPU/memory combination), Terraform will check the state file and see that it only needs to update the VM size when you deploy the configuration next time.

You can have multiple state files which some people do for testing different environments (e.g., development, test, production). You do this by creating multiple **workspaces** for your configuration. When you first initialize your working directory, a default workspace named *default* is created using the aforementioned *terraform.tfstate* file whereas other workspaces will be in the *terraform.tfstate.d* directory.

{% include filesystem.html id="folder_tf_workspaces" %}

Unless you specified differently, your backend location will be `local` which is your working directory and is why all the state files will be created locally. This isn't very shareable and doesn't fly when you're working on a team, so you can change your backend to be a remote location or use the Terraform Cloud service.

The state file is a plain text JSON file. As you'll see, you often need to pass secrets (passwords) to Terraform in your deployments, which are going to be stored in your state file. That's a concern when you're using an unsecure location for your state files.
{: .notice--info}

Even though they are all technically different, when you first initialize your configuration there is a 1:1 relationship between your working directory, backend, state file, and workspace.

One kinda cool thing about Terraform is that you can split up your configuration into as many files as you want and all the files will be aggregated together to make the configuration. So the in the example above, you could split the configuration into two files as shown below. Since you won't edit your provider data very often, you can mostly ignore the *base.tf* file after it's created and stick to editing your *main.tf* file.

**base.tf**

``` terraform
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}
```

**main.tf**

``` terraform
resource "azurerm_resource_group" "rg" {
  name     = "{{ site.data.fake.company_code }}-monitr-inf"
  location = "westus2"
}
```

## Modules

A lot of times you find that you're deploying the same resources in different configurations. This is especially true when you're deploying the same set of resources to different environments. For instance, if you're deploying a 3-tier service (database, API, and front-end web service), you *could* copy that configuration to a new folder for each environment, like this:

{% include filesystem.html id="folder_tf_env" %}

The problem you'll run into is that when it comes time to make changes, you might forget to change all the Terraform configurations exactly the same way in each environment. To make it easier, you can create a module that does most of the IaC settings and call that module from each configuration.

{% include filesystem.html id="folder_tf_env_with_module" %}

For example, let's say you decided to add a Redis Cache to your architecture. Instead of having to paste all that into each configuration, you just add it to the module and since each configuration is already calling the module, the Redis will be deployed as expected in each environment.

## Terraform Cloud

When you first start screwing around with Terraform, you'll probably save your files locally and then deploy from your laptop, which is the process described in the previous section. Deploying from the command line in this way uses the **Terraform CLI**. This works pretty well for learning or if you're a solo engineer, but you'll quickly discover that you'll want a better way to manage your Terraform deployments.

That's where **Terraform Cloud** comes in. You can use Terraform Cloud to manage all your configurations in a Terraform Cloud **workspace**. This has a nice web-based dashboard, secure storage of your state, ways to securely pass secrets, a history of deployments, and much more.

Confusingly, a Terraform Cloud workspace is not the same as a Terraform CLI workspace. You probably won't use Terraform CLI workspaces much in real life, so you can associate the term "workspace" with Terraform Cloud. In short, a Terraform CLI configuration is roughly equivalent to a Terraform Cloud workspace.
{: .notice--info}

Typically, each Terraform Cloud Workspace will map to a single Azure [resource group]({% post_url /learn/basics/azure_intro/explainer/2024-01-12-azure-hierarchy %}#resource-groups). You can use Terraform Cloud to automatically update your Azure resources as you update your Terraform files.

{% include svg.html path="svg/terraform-cloud-deployment-overview.svg" caption="Use Terraform Cloud to automatically deploy infrastructure changes as you update them in your Git repository." %}

However! Terraform Cloud is not a free service. You can manage your first 500 resources for free, but after that you get charged based on how much you use it. If this is a problem, consider using Azure DevOps which has a more generous free tier.