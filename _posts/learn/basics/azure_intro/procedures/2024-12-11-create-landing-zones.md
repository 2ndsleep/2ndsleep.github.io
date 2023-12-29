---
title: Create Landing Zones
categories: basics azure_intro procedure
sort_order: 2
description: Optionally create a landing zone
---
You can manually make a [landing zone]({% post_url /learn/basics/azure_intro/explainers/2024-12-08-landing-zones %}) if you want. Create all your subscriptions and, optionally, management groups, and then assign RBAC and policies on those subscriptions and management groups. You can even do it using infrastructure as code.

But there's a much easier way to do this, which is by using one of Microsoft's [automated landing zone implementations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/implementation-options).<!--more--> There are a couple of different flavors for automatically deploying landing zones that are for different use cases and can be broken down into two broad categories: [**enterprise scale**](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/) and [**start small and expand**](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/migrate-landing-zone). If you're a small organization, you'd think that the **start small and expand** option would be for you, but that's not necessarily the case, as this box :point_down: explains.

Whether you're a large or small organization, consider using one of the **enterprise scale** landing zone accelerators and don't deploy the costly resources if you don't need them, like Azure Firewall and Azure Sentinel. The enterprise scale has a better design and will set you up to more easily meet regulatory compliance requirements. Other than the aforementioned big-ticket resources, it will add a negligible cost to your bill.
{: .notice--info}

I'm going to strongly suggest you use one of the landing zone accelerators. Once again, Microsoft's documentation doesn't come out and just say what the hell the landing zone accelerators do, so I'll help you out. The landing zone accelerator is a GUI-based wizard in the Azure portal that will step your through some of the landing zone configuration options and then deploy the management groups, RBAC roles, and policies to create the landing zones for you. It will also deploy some resources to get your started, like a Log Analytics workspace for capturing resource diagnostic information, which you can choose to forgo if you want.

Under the covers, the "enterprise scale" option uses something called Azure ARM templates, whereas the "start small and expand" uses [Azure Blueprints](https://learn.microsoft.com/en-us/azure/governance/blueprints/overview). Blueprints will be retired on July 11, 2026, so I would suggest you avoid the "start small and expand" option.
{: .notice--info}

Enough talk. Here's how you deploy a landing zone.

## Elevate Permissions

Implementing a landing zone requires quite a bit of access to your Azure tenant. If you're the person who is going to be deploying the landing zone accelerator or blueprint, you'll need to elevate your access to Owner on the tenant. Follow the steps outlined in the [Required access](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-tenant?tabs=azure-cli#required-access) section of the [Tenant deployments with ARM templates](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-tenant?tabs=azure-cli) page to elevate your access.

Only do this if you need to and remove your access after you no longer need it. If your account gets hacked while it has this elevated access, you're in big trouble, sister.
{: .notice--danger}

## Landing Zone Accelerator

To deploy an enterprise scale landing zone accelerator go to the [Implement Cloud Adoption Framework enterprise-scale landing zones in Azure](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/implementation#reference-implementation) page and click the ![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true) button next to the implementation that works best for your organization. Microsoft is skimpy on the descriptions, so here's a little more detail for each implementation. But first, a bunch of notices and warnings.

<div class="notice--danger">When running the landing zone accelerator, be on the lookout for costly :money_with_wings: resources and disable the ones that you do not need. In particular, determine if you need these:
    <ul>
        <li>Microsoft Sentinel</li>
        <li>Azure Firewall</li>
        <li>All Cloud Defender stuff</li>
        <li>Azure SQL Threat Detection</li>
    </ul>
</div>

You can probably disable all of the **Deploy X solution** options under the **Platform management, security, and governance** section since those solutions are all deprecated. I'm not sure why they still have them there.
{: .notice--info}

At the time of this posting, it looks like all the deployment links go to the **Enterprise scale foundation** option, except for the **Enterprise scale for small enterprise** option. It's not that big of a deal - just choose the correct networking topology on the **Network topology and connectivity** page.
{: .notice--info}

|Implementation|Network Topology|Description|
|--------------|----------------|-----------|
|Enterprise-scale foundation|No connectivity into your existing private network|This option is the same as the two below, but assumes that your entire network will live in Azure and not connect to your existing corporate network. If you're a fully remote organization, this is what you'll probably want.|
|Enterprise-scale hub and spoke|VPN into your existing private network|This option assumes that you will use a VPN to connect to your existing corporate network.|
|Enterprise-scale Virtual WAN|Microsoft-managed network connectivity into your existing private network|Use this option if you want more robust network connectivity into your existing corporate network, like [ExpressRoute](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-introduction).|
|Enterprise-scale for small enterprise|VPN into your existing private network|The three options above will create separate management groups for network, identity, and monitoring. This option has separate subscriptions for each of those duties, but includes those subscriptions under the same management group. Use this option if you will never have separate teams for network, identity, and monitoring. Other than that, this option is the same as the **Enterprise-scale hub and spoke**.|
|Enterprise-scale for Azure Government|Configurable|Special option for government organizations.|

The deployment will start after you complete the wizard, and the portal will redirect you to the status of the deployment. If you close the browser and want to return to the deployment, the portal doesn't list the previous deployments that happen at the tenant level. To get back to that status page, you need to do a little bit of command line work.

First, install the {% include reference.html item='azure_cli' %}. Then run these commands.

``` bash
az login
az deployment tenant list --output table
```

This will output something like this:

```
Name                                                         State     Timestamp                        Mode
------------------------------------------------------------ --------- -------------------------------- -----------
pid-385d2eb9-a5c0-48c9-8173-786b38175e8a-nfnqfstl1asw2       Succeeded 2023-12-11T17:21:28.232495+00:00 Incremental
alz-Mgs-eastus2-385d2eb9-a5c0-48c9-8173-786b38175e8a         Succeeded 2023-12-11T17:22:43.312285+00:00 Incremental
NoMarketplace-20231211130200                                 Succeeded 2023-12-11T17:19:34.240367+00:00 Incremental
```

Find the name that begins with `NoMarketplace` with the timestamp that you started the deployment, and use that value to construct the URL by putting the name between these two values:

```
Prefix:
https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/%2Fproviders%2FMicrosoft.Resources%2Fdeployments%2F

Suffix:
/packageId//primaryResourceId//createBlade~
```

So in the above example, the URL would be:

```
https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/%2Fproviders%2FMicrosoft.Resources%2Fdeployments%2FNoMarketplace-20231211130200/packageId//primaryResourceId//createBlade~
```

That URL will take you to the deployment in the portal. If you're new to Azure, you may not be able to dig too far, but you'll at least be able to see if it succeeded.

## Start Small and Expand

I'm including this since Microsoft seems to think it's a viable option, but I'm going to strongly steer you away from this for the reasons explained at the top of this page.
{: .notice--danger}

Follow the steps in the [Deploy the Microsoft Cloud Adoption Framework for Azure Foundation blueprint sample](https://learn.microsoft.com/en-us/azure/governance/blueprints/samples/caf-foundation/deploy) page to deploy the "start small and expand" blueprint.
