---
title: Landing Zones
categories: basics azure_intro explainer
toc: true
sort_order: 4
description: Configure your entire Azure environment automatically
---
First, I'm going to make fun of landing zones, because I didn't understand what in god's name they were even after carefully reading the documentation. Try it yourself. Go to [What is an Azure landing zone?](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/), take five minutes to read the page, and then turn to the person or animal closest to you and see if you can faithfully describe it to them. You can't do it! Especially if you're talking to an animal because they don't speak human languages... [yet](https://www.popularmechanics.com/science/animals/a42689511/humans-could-decode-animal-language/).

After reading it, you know that a landing zone is "scalable" and "modular." You know that it's a "conceptual architecture." You kind of know what it can *do*. But what the hell is it?? This bothered me so much when I started exploring landing zones that I'm going waste my time and yours ranting about it.
<!--more-->

Here's what a landing zone is: it's an Azure subscription. You can find that answer in the fourth question of the [Azure landing zones FAQ](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/faq#what-does-a-landing-zone-map-to-in-azure-in-the-context-of-azure-landing-zone-architecture). Wouldn't it be nice if they mentioned that at the beginning?

Out of fairness, [Google](https://cloud.google.com/architecture/landing-zones) isn't any better at explaining landing zones. [AWS](https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-migration/aws-landing-zone.html) gets you slightly closer to understanding it, but still sucks hard.
{: .notice--info}

## What Is an Azure Landing Zone (but like, for real)?

A cloud landing zone is some kind of location where you put your cloud resources that will ensure your resources will be configured the way you want them. It differs for each cloud provider, but in Azure a landing zone is a subscription. This subscription has configurations applied to it so that your resources will automatically have the settings, features, or restrictions that you want. Each landing zone is a different subscription that may have different configurations applied to it.

The goal here is to ensure that your resources are configured the way you want without having to remember to configure them or to make sure that someone doesn't make a change that you don't want. Here are some examples of what your landing zone may do.

- Always add a shutdown schedule to your VMs. Perhaps you would apply this to a development subscription where there's no need to run the VMs overnight. You can enforce a shutdown schedule to be applied to the VMs so you don't have to remind your developers to shut them down each night, therefore saving :moneybag:.
- Apply a delete lock to all your production resources to make sure someone doesn't accidentally delete them.
- Make sure VM diagnostics are always being sent to a Log Analytics workspace to help with troubleshooting.

Sure, you could do these manually, but that's a lot of work when you're managing a lot resources. And are you going to remember to do this every time you deploy a new resource? Also, what if a developer makes a change temporarily and forgets to set it back? The landing zone will make sure that these items can't be changed or reset it back to a default state if a change is made.

Since this blog is all about automating deployments, you may also be thinking, can't I configure these things as part of my deployment process? For example, can't I just include a shutdown schedule when I deploy my VM? You absolutely can, but the drawback is that you only set the shutdown schedule at deploy time. If you decide later to change the shutdown schedule, you have to write a script to update everything. Managing the landing zone configuration will make the change automatically. And a benefit is that you don't have to include all that shutdown schedule nonsense as part of your deployment. Just deploy it into the correct landing zone (AKA, subscription) and you're good to go.

I had a hard time wrapping my head around landing zones at first because I just didn't understand what it *was*. A landing zone is technically the subscription where you put your resources. But a subscription that doesn't have configurations applied to it isn't a useful landing zone. So then is a subscription without any configurations a landing zone? I think technically yes. So then are all the configurations part of the landing zone? I think technically no. Honestly, I still don't know what the hell a landing zone technically is, and I think all the big cloud providers' documentation dances around giving a solid definition. In the end it doesn't really matter as long as you get the concept.
{: .notice--info}

## How Does a Landing Zone Work?

The reason I said the subscription has "configurations applied" rather than "is configured" is that there's not a lot of configuration that can be done to a subscription itself. The way you configure a landing zone is to assign certain things at a subscription level or above the subscription at the management group level. Here are the "things" you can configure to make the landing zone work the way you want it to.

- Management Groups
- Policies
- Role-based access (RBAC)

This section will make more sense if you're familiar with my posts about the [Azure Cloud Structure]({% post_url /basics/azure_intro/explainers/2023-12-11-azure-hierarchy %}).
{: .notice--info}

### Management Groups

Management groups are ways to group your subscriptions together. This can be useful if you want to apply configurations to a bunch of landing zones (AKA, subscriptions) at once. You can then apply additional configurations to each subscription that are more specific to that subscription.

{% include figure image_path="https://learn.microsoft.com/en-us/azure/governance/media/mg-org.png" alt="landing zone management groups" caption="This is the recommended management group structure for Microsoft's enterprise scale landing zone." %}

The image above is Microsoft's recommended landing zone organization. There's a lot going on, but zero in on the **Landing zones** management group. If you decide to implement this structure, you're going to mostly be working with subscriptions that are part of that management group. This is where your application resources, like VMs, App Services, and databases are going to live. You can see that the **Landing zones** management group has three management groups below it. Let's ignore **SAP** and focus on **Corp** and **Online**. These two management groups would contain subscriptions that contain the following types of resources.

- **Online**: Resources that will be exposed to the Internet.
- **Corp**: Resources that are not available from the Internet, but may be accessed by resources in the **Online** subscriptions.

Each subscription that is a member of the **Online** or **Corp** management group will be an actual landing zone. You can apply configurations at each level to ensure the each landing zone is configured the way you want it. When you configure something at a management group level, all management groups or subscriptions below that will inherit the configurations. Here's a simple example of what you may want to do at each level.

|Management Level|Type|Configuration|
|----------------|----|-------------|
|Landing zones|management group|Enforce VMs are backed up|
|Online|management group|Prevent IP forwarding (VMs can't act like a router)|
|Corp|management group|Prevent inbound network access from the internet|
|Landing zone A1|subscription|Add delete lock to all resources|
|Landing zone A2|subscription|Shutdown VMs after 7 pm|

### Configurations

Up until now, I've used this vague term of "configurations" to describe how you configure your landing zone. These "configurations" are achieved by a combination of Azure Policy and RBAC.

#### Policies

The main way these configurations are made are through [Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview). Policies allow you to enforce settings that you want on your landing zones. Policies can be assigned to management groups, subscriptions, resource groups, or resources, but for the purposes of landing zones you'll only be interested in assigning them to management groups or subscriptions.

This post has had a bunch of policy examples so far masquerading as "configurations," and these have been focused on configuring resources. But you can do other things, like limiting what resources can be deployed, restricting which regions you can deploy resources, and enforcing your resource [tag](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources) management.

It's worth noting that policies aren't squarely in the security realm, but are often used to achieve security purposes. For example, a policy to ensure that every resource has a `CostCenter` tag isn't much of a security concern, but a policy to prevent RDP access form the internet to your Windows VMs sure is. So it depends on the individual policy as to whether it's a security measure.

#### RBAC

I'm going to talk about role-based access control (RBAC) in a future post, but in short, RBAC is the permission you assign to your subscriptions that specify who can do what to each subscription. RBAC can and should be part of your landing zone. Some landing zones will need to be more locked down, like your production environment. Your sandbox environment might be more of a free-for-all where developers can spin up resources without going through the platform engineering team.

## How Do I Create a Landing Zone?

Landing zones can be created manually by configuring Azure policies, RBAC, and management groups yourself. But Microsoft offers a couple of ways to deploy their recommended landing zone configurations [automatically]({% post_url /basics/azure_intro/procedures/2023-09-21-landing-zones %}).

## Should You Use a Landing Zone?

Yes. Landing zones are simply a smart way to work. Plus it automatically creates the more mundane operational things that you should have anyway, like a Log Analytics workspace to collect monitor data from your resources, a Network Watcher to inspect network traffic, and a Key Vault to store passwords used for various operational resources.

I think landing zones are a no-brainer if you have a greenfield deployment, meaning you're starting brand new with Azure and have no resources or only a few resources. You might as well get your Azure landscape set up before you start.

So you may be thinking that if you're already using Azure, then landing zones are going to be a headache. Nope. You can and should still use landing zones! Take another look at Microsoft's recommended management group organization:

{% include figure image_path="https://learn.microsoft.com/en-us/azure/governance/media/mg-org.png" alt="landing zone management groups" caption="Can you find your current subscription in this diagram? (The answer is no.)" %}

Notice how the subscriptions that you currently have aren't in there. Any subscriptions that you already have are going to be branched directly from the tenant root group at the top. Policies and RBAC are not applied to the root, which means you could run the landing zone accelerator right now and it will create a management group organization similar to the image above, but your existing subscriptions will be completely unaffected by the landing zone organization.

You can then start migrating resources to landing zones one-by-one. Or if you think you're ready to take the leap, you can move your existing subscriptions to either the **Corp** or **Online** management group (which takes only a few seconds). The landing zone accelerator will also give you the option to move your existing subscriptions under these management groups, but you'll want to make sure that you're ready for that. For example, if the landing zone will prevent IP forwarding and you have a virtual router (AKA network virtual appliance, AKA NVA) in your subscription, then that router won't work anymore. You'll either have to disable that IP forwarding policy or rethink your architecture.

Oh, and if you're not using landing zones or choose not to, no shame. I don't have hard numbers, but I'm going to assume that most organizations only use landing zones when they bring in consultants. When you sign up for Azure, you'll start getting a bunch of "getting started" emails about creating various resources. One of those emails will be encouraging you to use landing zones, but it will send you to Microsoft's inscrutable documentation at which point you'll probably close the browser in anguish. I think Microsoft could do a much better job of explaining this very valuable tool, so I hope this post helps in that effort.

## Microsoft's Secret Documentation

As I mentioned, Microsoft's official [landing zone documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/) is piss-poor. But if you poke around there, it will lead you to Microsoft's [secret documentation](https://github.com/Azure/Enterprise-Scale) on GitHub. Well, not really secret. It's more like the "user guide" and source code for Microsoft's recommended landing zone deployments. It's under active development and is in fact a community project that you can contribute to and give feedback! The Learn documentation is more abstract whereas the GitHub documentation gets into the nitty gritty of what happens if you deploy the landing zone accelerator.

## Making This All About Me

Here's my personal beef with the Microsoft landing zone accelerators. They make a lot of the rest of this blog pointless. If you create a landing zone and never need to come back to this blog, great! The point of this blog is to show how to use Azure for specific solutions, so you should deploy a landing zone if that makes sense for your organization.

But! I think Microsoft's enterprise scale landing zone is a very sensible way to construct your cloud environment so I'm going to borrow heavily from it. If you follow along, we're going to do the same thing bit-by-bit (byte-by-byte?) that the landing zone accelerator does in minutes, and I'll refer to the enterprise scale landing zone accelerator source code where possible.

Landing zones don't have to be deployed with the Azure landing accelerator. They can be created manually. In fact, that's what we'll be doing slowly throughout this blog.