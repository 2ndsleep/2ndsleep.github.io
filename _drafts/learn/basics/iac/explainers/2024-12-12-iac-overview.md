---
title: Infrastructure as Code Introduction
categories: basics iac explainer
sort_order: 1
description: Introduction to the infrastructure as code concept
---
**Infrastructure as code (IaC)** is a way to define your infrastructure using code. It's what this blog is all about and is a reliable way to automate the deployment of your cloud resources.<!--more-->

Let's back up and make sure we understand what we mean by **infrastructure**. In the past, infrastructure has often referred to your physical hardware, such as servers, laptops, networking equipment, and really anything electronic. The main audience for this blog is cloud platform engineers, so assume that we're always talking about **cloud infrastructure**. Since you do not have direct access to the physical hardware in the cloud, the infrastructure you will maintain are the virtual cloud resources. This may be virtual networks, virtual machines, or other services offered by Azure.

## Defining Infrastructure with Code

Infrastructure as code is exactly how it sounds. You write code that is saved to a text file that defines what you want your infrastructure to look like. You can think of this like an architect's blueprint that say exactly what your resource should look like.

Here's an example of a fake infrastructure as code file.

```
Virtual Machine:
    Hostname: jumpbox
    Processors: 4
    Memory: 16 GB
    OS: Windows Server 2022
    Disk:
        1: 254 GB
        2: 1024 GB        
```

This is saying that you want a VM named `jumpbox` running Windows Server with 4 virtual processors, 16 GB of memory, and two virtual disks of two different sizes. This file would be used as input to some type of cloud provisioning service that would create a VM with those properties in your cloud provider.

This type of code is called [**declarative**]({% post_url /learn/basics/iac/explainers/2024-07-04-iac-principles %}#declarative-code) code because you are declaring what you what your resource should look like. You're not saying how it should be created, you're simply saying you want a VM with all those properties. You don't know how it gets created and you don't care.

The above example is fake using some half-ass YAML structure that I made up, so it won't work in real life. Most IaC will use JSON or a JSON-like format.
{: .notice--info}

## Benefits of IaC

If you're at this page, you probably don't need a lot of convincing as to why you need to use IaC. But in case you're scratching your head asking, "why should I write text files when I could just create all of this using the Azure web portal?" let me try to convince you.

### Scale

The Azure portal is a great product, and I use it almost every day. It is particularly excellent for deploying resources when you are initially working with them. The very first time I created a VM in Azure, I did it in the portal. However, it takes a long time to create a VM in the portal. There's lots of clicking and lots of little boxes to fill in. When it's time to deploy 20 identical VMs, that's going to take a while.

The portal is not designed for deploying resources at scale. IaC let's you define your resources one time and then deploy them all at once.

### Fewer Errors

In the example above about creating 20 identical VMs, you're probably going to make a mistake filling out all those boxes in the portal. With IaC, there are fewer errors because you're not re-typing everything again; you're only specifying the things that are different per resource. So if you're deploying 20 identical VMs, the code will be the same for each VM, except for the hostname.

### Known State & Repeatability

IaC enforces the idea that your resources should have a default, known state. For instance, if you declare all your VMs to have Git installed, you don't have to worry about remembering to install Git when you log on. It will always be there.

This means that you can run your IaC over and over again and always expect the same result. So if you have an [App Service](https://learn.microsoft.com/en-us/azure/app-service/overview) and want to have a backup App Service in another region, you can run the same IaC in a different region and know that those Web Apps will be configured exactly the same way. At least until some cowboy goes in and starts changing the settings on your web app. But if they do, you can *re-run* the IaC and restore everything to a known state.

This approach has a mantra of "treating your resources like cattle not pets," and can require a shift in thinking, depending on how you've worked in the past. The idea is that no single resource is precious. If you've designed things correctly and have proper backups of your data, then your infrastructure can get wiped out and you simply re-run your IaC and restore your data, and you'll be back in operation. By the way, this idea of running a task over and over and getting the same result is known as [**idempotency**]({% post_url /learn/basics/iac/explainers/2024-07-04-iac-principles %}#idempotency).

### Self-Documenting

A lot of times you create resources in the cloud and forget how you did it or even why you did it. Since IaC is code, it inherently documents how the resources are created and in which order. And since it's stored in a repository, you can add README files where you can document weird little nuances of why things work a certain way instead of stashing in random Google docs or OneNote notebooks.

## IaC Tools

There are tons of IaC tools you can use to manage your environment, but I'll highlight two major ones for Azure. The first is **ARM templates** and its sister tool **Bicep**. These are IaC tools created by Microsoft specifically for managing Azure. The second is **Terraform**. This is a product created by Hashicorp that can manage multiple cloud providers, including Azure, AWS, and Google Cloud Platform (GCP).

Behind the scenes, these tools simply convert the IaC definitions to REST API calls to the [Azure orchestrator]({% post_url /thoughts/2023-12-29-azure-cloud-os %}#cloud-operating-system) which makes the changes to the resources.

Both of these products are IaC tools and they are both fantastic. I like both of them a lot and wrestled with which one I'd use for {% include reference.html item='fake_company' %} but eventually settled on using Terraform for reasons I'll explain in a future post. I even considered using examples of both, but I thought that would be way too much work. I'll still do a quick explainer of ARM templates and Bicep.

## Authoring

You'll also want some type of application to write your IaC files. As I mentioned, these are text files, so you can use something as simple as Windows Notepad. But opening a ton of Notepad windows is a dumb way to work and you'd be dumb to do that, dummy. Instead, you should use something that will help you keep your files organized and highlight the text with pretty colors so it's easier to navigate.

There are lots of options for text editors with syntax highlighting, such as Notepad++ or Sublime Text. But we'll be using an editor that has quickly risen to fame, {% include reference.html item='vscode' %}.

Some people, including me, refer to VS Code as an IDE which stands for integrated development environment. The consensus is that this is incorrect because VS Code doesn't have all the tooling that an IDE has. Rather, VS Code is just a very fancy text editor. You're forgiven if you call VS Code an IDE.
{: .notice--info}

At this point, we should introduce another term, which is **authoring**. Some people say that when you are writing IaC files, you're not really coding. I don't fully agree with this (after all, it's called infrastructure as *code*), and I'm not at all interested in the argument. However, to avoid any confusion and to make sure the pedants don't blow a gasket, I'll use the term "authoring" from this point forward since it does accurately represent the work of editing IaC files.