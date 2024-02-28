---
title: Accessing Azure
categories: basics azure_intro explainer
sort_order: 2
description: How the hell do I get to Azure?
tags: portal azure-cli powershell
---
If you're brand new to the cloud and are still having trouble wrapping your head around how you "get to it" so you can use it, let my try to clear that up.<!--more--> Since Azure is a cloud service and everything you use in Azure is virtual, you don't have direct access to the Azure datacenter or servers. Instead you access everything through either the web-based Azure portal, a command line, or both.

## The Portal

The [Azure portal](https://learn.microsoft.com/en-us/azure/azure-portal/azure-portal-overview) is the way you'll start using Azure when you're starting out. It is a web-based administrative interface for managing your Azure resources. It is great for learning how to use Azure resources for the first time or making individual emergency changes to your resources. It also has a very memorable URL: `portal.azure.com`.

{% include figure image_path="https://learn.microsoft.com/en-us/azure/azure-portal/media/azure-portal-overview/azure-portal-overview-portal-callouts.png" caption="Viewing a VM resource in the Azure portal" alt="Azure portal" %}

The goal of this blog is to learn how to automate your infrastructure so hopefully you'll get to the point where you're using the portal for viewing resources more than managing resources. But when you're learning Azure you absolutely will be inside the portal a ton!

## Command Lines

There are three main command line interfaces for managing Azure. This blog will favor using commands over the portal with a preference of the Azure CLI because it will work the same on Windows, macOS, and Linux. (For what it's worth, I personally like PowerShell better.) See [this post]({% post_url /learn/basics/azure_intro/procedures/2024-01-14-azure-command-line-tools %}) on how to install these tools.

I'm going to editorialize here and say that knowing how to use command line tools is the mark of a serious platform engineer. If you are only interested in using the portal, you may not find this blog worthwhile.
{: .notice--info}

Behind the scenes, these command line tools just convert the commands to REST API calls and hit up the [Azure orchestrator API]({% post_url /thoughts/2023-12-29-azure-cloud-os %}#cloud-operating-system), so they're all more or less doing the same thing. In fact, the portal is doing the same thing, just with a colorful interface.

### Azure CLI

The [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/what-is-azure-cli) is a cross-platform (meaning it can run on Windows, macOS, and Linux) command line tool to manage Azure. Almost anything you can do with the portal you can do with the Azure CLI.

For example, to start a VM named **jumpbox** in the resource group called **{{ site.data.fake.company_code }}-sysadm-inf-1**, you would run this command on your preferred command prompt:

``` bash
az vm start -g {{ site.data.fake.company_code }}-sysadm-inf-1 -n jumpbox
```

### Azure PowerShell

[Azure PowerShell](https://learn.microsoft.com/en-us/powershell/azure/get-started-azureps?view=azps-11.1.0) is a PowerShell module that you install which will allows you to manage Azure. It pretty much provides the same functionality as the Azure CLI, but wrapped with PowerShell. If you're comfortable managing objects with PowerShell, then you can do things like start/stop resources by filtering and piping results from one command into another.

For example, to start all VMs that are tagged with the Finance cost center, you could run this:

``` powershell
Get-AzVM | ? {$_.Tags.CostCenter -eq 'Finance'} | Start-AzVM
```

To use Azure PowerShell, you must first have PowerShell installed on your operating system, and then you install the Azure module. In the old days, PowerShell was only available on Windows, but it's been open-sourced and is now also available on macOS and Linux. If you're using macOS or Linux, you'll be using a newer version of PowerShell. If you're on Windows and using a PowerShell version prior to 7, you may consider using the newer version of PowerShell because you'll find the documentation out there is starting to coalesce around the cross-platform version of PowerShell.

### Azure Cloud Shell

[Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/overview) is a command line in the cloud that is available to you for free as part of your Azure tenant. When you use it, it starts a command line shell that comes in two flavors:

- Bash: This starts a cloud shell using a Linux-style Bash shell. Use this if you're planning on only using the Azure CLI commands.
- PowerShell: This starts a cloud shell using PowerShell.

What's cool about the Azure Cloud Shell is that it comes pre-installed with a bunch of commands like `git` and `terraform`. So if you have some old piece of shit laptop or are blocked by your administrator from installing applications, you can just use the Cloud Shell. Or if you're at your grandma's house and get a call from your boss, you can just open a browser on her computer and be a work hero.

## Mobile App

There's also an Azure mobile app that is worth installing if you are responsible for Azure in your environment, although the functionality is limited. You can use it to receive alerts, view the status of resources, and do some light management, but you'll find that you can't do much with it.