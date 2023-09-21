---
title: Create Landing Zones
categories: basics azure_intro procedure
toc: true
sort_order: 1
---
## TODO
- [ ] link to {% post_url /basics/azure_intro/explainers/2023-09-21-landing-zones %}
- [ ] explain permissions

You can make a landing zone by just doing all the things in the previous sections yourself. Create all your subscriptions and, optionally, management groups, and then assign RBAC and policies on those subscriptions and management groups. You can even do it using infrastructure as code.

But there's a much easier way to do this, which is by using Microsoft's [landing zone accelerators](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/implementation-options). Once again, Microsoft's documentation doesn't come out and just say what the hell the landing zone accelerators do, so I'll help you out. The landing zone accelerator is a GUI-based wizard in the Azure portal that will step your through some of the landing zone configuration options and then deploy the management groups, RBAC roles, and policies to create the landing zones for you. It will also deploy some resources to get your started, like a Log Analytics workspace for capturing resource diagnostic information, which you can choose to forgo if you want.

There are a few different flavors of landing zone accelerators that are for different use cases that can be broken down into two broad categories: [**enterprise scale**](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/) and [**start small and expand**](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/migrate-landing-zone). If you're a small organization, you'd think that the **start small and expand** option would be for you, but that's not necessarily the case, as this box :point_down: explains.

Whether you're a large or small organization, consider using one of the **enterprise scale** landing zone accelerators and don't deploy the costly resources if you don't need them, like Azure Firewall and Azure Bastion. The enterprise scale has a better design and will set you up to more easily meet regulatory compliance requirements. Other than the aforementioned big-ticket resources, it will add a negligible cost to your bill.
{: .notice--success}

### Deploy Landing Zone with an Accelerator

Enough talk. Here's how you deploy a landing zone with a landing zone accelerator.

#### Enterprise scale

To deploy an enterprise scale go to the [Implement enterprise-scale landing zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/implementation#reference-implementation) page and click the ![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true) button next to the implementation that works best for your organization. Microsoft is skimpy on the descriptions, so here's a little more detail for each implementation.

At the time of this posting, it looks like all the deployment links go to the **Enterprise-scale foundation** option, except for the **Enterprise-scale for small enterprise** option. It's not that big of a deal - just choose the correct networking topology on the **Network topology and connectivity** page.
{: .notice--warning}

|Implementation|Network Topology|Description|
|--------------|----------------|-----------|
|Enterprise-scale foundation|No connectivity into your existing private network|This option is the same as the two below, but assumes that your entire network will live in Azure and not connect to your existing corporate network. If you're a fully remote organization, this is what you'll probably want.|
|Enterprise-scale hub and spoke|VPN into your existing private network|This option assumes that you will use a VPN to connect to your existing corporate network.|
|Enterprise-scale Virtual WAN|Microsoft-managed network connectivity into your existing private network|Use this option if you want more robust network connectivity into your existing corporate network, like [ExpressRoute](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-introduction).|
|Enterprise-scale for small enterprise|VPN into your existing private network|This option is the same as the **Enterprise-scale hub and spoke** but does not segregate the platform management duties. The three options above have separate management groups for network, identity, and monitoring. This option has separate subscriptions for each of those duties, but includes those subscriptions under the same management group. Use this option if you do not have separate teams for network, identity, and monitoring.|
|Enterprise-scale for Azure Government|Configurable|Special option for government organizations.|

#### Start small and expand

Click the **Deploy the blueprint sample** button on the [Deploy a CAF Foundation blueprint in Azure](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/foundation-blueprint#deploy-the-blueprint) page to deploy the **Start small and expand** landing zone.

