---
title: Routing a Public IP Over a VPN Connection
category: thoughts
tags: vpn vpn-gateway virtual-network
toc: true
---
{% assign ip_clearinghouse_peer = 'c.c.p.p' %}
{% assign ip_org_peer = 'o.o.p.p' %}
{% assign ip_org_app_public = 'o.o.a.a' %}
{% assign net_org_app_public = 'o.o.a.0/29' %}
{% assign ip_org_app_public_azure_gateway = 'o.o.a.1' %}
{% assign net_clearinghouse_app_public = 'c.c.a.a/x' %}
{% assign net_org_app = '10.0.20.0' %}
{% assign ip_org_app_router_azure_gateway = '10.0.16.1' %}
{% assign ip_org_app = '10.0.20.32' %}
{% assign ip_org_app_router = '10.0.20.8' %}
{% assign netmask_org_app = 24 %}
{% assign net_org_routing = '10.0.16.0' %}
{% assign netmask_org_routing = 24 %}
{% assign ip_org_routing_router = '10.0.16.8' %}
{% assign ip_org_routing_router_azure_gateway = '10.0.16.1' %}

Each industry has its weird little standards. When I worked in the pharmacy space, that weird little standard was how you had to route certain public IP addresses over a private VPN.<!--more--> When I first came across this, I scratched my head as to why they did it this way. Then I had to figure out how to do this in a virtual cloud environment. Then I balled up my fists and screamed. Then I figured it out and went and got a beer. It was a tumultuous, exhilarating time!

## The Problem

Since this was required to process pharmacy payments, let me first offer the briefest background on how retail pharmacies process claims. When it's time to pick up your pills (none of my business what it's for), the pharmacy tech sends your prescription and insurance information to your insurance company. The insurance company responds back immediately with how much they will reimburse the pharmacy and how much the patient owes. It's actually a pretty well-oiled machine.

But just like every other part of the medical industry, there is a middleman in this process. Each pharmacy doesn't make a direct connection to each of the roughly [66 pharmacy insurers](https://content.naic.org/cipr-topics/pharmacy-benefit-managers) in the US. Instead, a pharmacy makes a connection to something known as a **clearinghouse** that relays the claim to the correct insurance company. The clearinghouse is like a hub in the middle of a wagon wheel. It connects to all the pharmacies and all the insurance companies.

{% capture pharmacy_attribution %}
{% include attribution.html title='house' image_link='https://commons.wikimedia.org/wiki/File:House.svg' author='barretr (Open Clip Art Library)' author_link='http://openclipart.org/media/people/barretr' license='CC0' license_link='https://creativecommons.org/publicdomain/zero/1.0/deed.en' %}<br />
{% include attribution.html title='office building' image_link='https://commons.wikimedia.org/wiki/File:587-office-building.svg' author='Vincent Le Moign' author_link='https://twitter.com/webalys' license='CC BY 4.0' license_link='https://creativecommons.org/licenses/by/4.0' %}
{% endcapture %}

{% include svg.html path="svg/pharmacy-clearinghouse.svg" caption="Who would have guessed that any part of the American healthcare system is actually efficient?" attribution=pharmacy_attribution %}

<p class="notice--info">My experience with this is only in the pharmacy space, but my understanding is that this model is the same for medical claims processing.<br /><br />For stupid historical reasons, the pharmacy coverage part of your medical insurance is technically known as a pharmacy benefit manager or PBM. If you find yourself at a dinner party sitting next to someone in the retail pharmacy space, use the term "PBM" and watch their face light up and buckle in for a really boring conversation.</p>

Here's a rapid fire set of concepts to know for the rest of this article.

- The insurance company is known as the **payer**. Payers can be any entity that processes a claims (e.g., pharmacy discount cards).
- When the payer processes claims, it's known as **adjudication**.
- The adjudication process has been around since before web services were popular, so this connection is made over TCP sockets (which is why we need the VPN connection in the first place). Some clearinghouses are developing REST services, so hopefully this whole networking model will be a thing of the past in a few years.

### Public IP Addresses to the Rescue

On to the technical problem. Each payer that wants to communicate with the clearinghouse will need some type of network connection. This often will be a site-to-site VPN connection. But when you traditionally think about a corporate site-to-site VPN, you're usually connecting two or more separate private networks that are controlled by the organization. This means you can ensure that each site has a separate private address space that doesn't overlap. For instance, your small satellite office in San Francisco, CA may have the 192.168.0.0/24 address space whereas your gigantic headquarters in Boerne, TX has the 10.0.0.0/12 address space.

If you're not a network person, there's two types of IPv4 addresses: public and private. Private addresses can be assigned however you want in your private network but cannot be used on the public internet. Since private addresses can be assigned however you want, there's no guarantee that the private address space that the clearinghouse has available will be available on your network. In a perfect world, the clearinghouse would have the same unused private subnet as your organization does. Also, in a perfect world, there would be no disease and we wouldn't need pharmaceutical companies at all, but that's not our reality.

Since public IP addresses are guaranteed to be unique, the clearinghouses have chosen to use that as their solution. So you assign a public IP address to your adjudication endpoint where the clearinghouse will establish a TCP connection. The whole thing looks something like this:

{% capture vpn_overview_attribution %}
{% include attribution.html title='house' image_link='https://commons.wikimedia.org/wiki/File:House.svg' author='barretr (Open Clip Art Library)' author_link='http://openclipart.org/media/people/barretr' license='CC0' license_link='https://creativecommons.org/publicdomain/zero/1.0/deed.en' %}<br />
{% include attribution.html title='firewall' image_link='https://commons.wikimedia.org/wiki/File:Breezeicons-apps-48-firewall-config.svg' author='Uri Herrera and others, KDE Visual Design Group' author_link='https://github.com/KDE/breeze-icons/blob/master/COPYING-ICONS' license='LGPL' license_link='https://www.gnu.org/copyleft/lgpl.html' %}
{% endcapture %}

{% include svg.html path="svg/public-ip-over-vpn-overview.svg" caption="Public IP over VPN high-level network design" attribution=vpn_overview_attribution %}

Using public IPs ensures that there are no IP address collisions like you potentially would have if you were only connecting private networks. There is nothing in the IPSec VPN specifications that say you can't use public IP addresses, but it's a departure from how you regularly do things so it takes some noodling to get it right.

If you've dealt with IP conflicts in the past, you may be thinking that VPN SNAT would be a solution that the clearinghouses could have used. I don't know why they don't offer that, but my guess is that their customers may find that managing SNAT introduces more complexities for both parties than the public IP solution.
{: .notice--info}

### Challenges in Azure

This can be done with native Azure services, but there are some challenges.

If you're like me, the first thought you had was that this requires some NAT magic, like this:

{% include svg.html path="svg/public-ip-over-vpn-overview-nat.svg" caption="This seems like the NATural solution" attribution=vpn_overview_attribution %}

The problem is that Azure VPN Gateway does not support DNAT. As you recall, the clearinghouse will be sending packets over the VPN to a public IP address. We need to translate that destination public IP address to the private IP address associated with our application, but the VPN Gateway lacks any DNAT feature. If you Google it you may discover that all but the cheapest SKUs support [NAT](https://learn.microsoft.com/en-us/azure/vpn-gateway/nat-overview). But this is only source NAT. Even if the source is translated, the destination will still go to our public IP address.

But hmmm, you think. Maybe you could game the system and route to that public IP through Azure's software-defined networking, you think. Since the packets to our application's public IP can route over the VPN we could assign the public IP to a VM and let it just route that last little bit over the public internet, is your thought. After all, since this will be going from one Azure resource (VPN Gateway) to another Azure resource (VM), it will probably stay within the edge of the Microsoft global network ([cold potato routing](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/routing-preference-overview#routing-via-microsoft-global-network)), such is your thinking.

Shame on you for such sinful thoughts! That network is still untrusted! But even if your CSO approved such a hairbrained scheme, the Azure VPN Gateway [does not allow internet access](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-p2s-advertise-custom-routes#forced-tunneling), so you can give up on the idea.

## The Easy Solution

Holy shit, there's actually a super easy way to do this! Did you know that you can assign public IP addresses to your virtual network address space?! (If you did know that, shut up.)

The solutions looks something like this:

{% capture public_subnet_attribution %}
{% include attribution.html title='house' image_link='https://commons.wikimedia.org/wiki/File:House.svg' author='barretr (Open Clip Art Library)' author_link='http://openclipart.org/media/people/barretr' license='CC0' license_link='https://creativecommons.org/publicdomain/zero/1.0/deed.en' %}
{% endcapture %}

{% include svg.html path="svg/public-ip-over-vpn-public-subnet.svg" caption="Public IP over VPN using VNet with public subnet" attribution=public_subnet_attribution %}

And can be done like this:

- Create an [Azure VPN Gateway](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways) connection to your clearinghouse (easier said than done, I know).
- Create your own [public IP prefix](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-address-prefix) or [bring your own](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/custom-ip-address-prefix). Either way, the prefix must be a /29 or larger.
- Create an [address space](https://learn.microsoft.com/en-us/azure/virtual-network/manage-virtual-network#add-or-remove-an-address-range-using-the-azure-portal) on your virtual network using the public IP prefix from above and then [create a new subnet](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet?tabs=azure-portal#add-a-subnet) using the same prefix, which we'll call **adjudication**.
- [Assign the adjudication subnet](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface?tabs=azure-portal#change-subnet-assignment) to the NIC for your adjudication application's VM or load balancer and optionally assign a static IP to the NIC.
- [Create a route table](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table#create-a-route-table) with a route to the clearinghouse public subnet specifying the **Virtual network gateway** as the next hop and assign it to the adjudication subnet.

The route for your route table associated with the adjudication subnet has these properties.

|**Destination type**|IP Addresses|
|**Destination IP addresses**|{{ net_clearinghouse_app_public }}|
|**Next hop type**|Virtual network gateway|
|**Next hop address**|n/a|


Easy, peasy, lemon squeezey, as we say in the cloud architecture world. Your virtual network will know to route traffic to your public IP prefix to your internal Azure resources and will know to route traffic to your clearinghouse back through the VPN Gateway. Even though these IPs are public, they won't be [available from the internet](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#can-i-have-public-ip-addresses-in-my-virtual-networks) by default.

The only sorta, kinda downside is that if you only need a single IP address, you'll still need to provision a /29, which equates to 8 IP addresses that you'll be paying for. And actually, since you're creating a subnet from the address space, you lose 3 IP addresses to [networking infrastructure](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets). That leaves 4 IP addresses left over which you probably don't need.

## Network Virtual Appliance

The way I've done this in the past, before I knew about the easy way, was with a network virtual appliance (NVA). An NVA is virtual router from a non-Microsoft vendor of your choosing (Cisco, Palo Alto, Fortinet, etc.) that you can purchase from the Azure marketplace. This is like plopping a physical router that you're already familiar with in Azure (but it's like, virtual, man) and grants you complete control over your networking infrastructure, including the VPN connection, routing, and NAT. If you already have experience using, say, a Cisco device, you can apply all of your existing knowledge to the NVA without having to learn all this Azure networking horseshit.

This can be done any number of ways depending on your network topology, but here's one example:

{% capture nva_attribution %}
{% include attribution.html title='house' image_link='https://commons.wikimedia.org/wiki/File:House.svg' author='barretr (Open Clip Art Library)' author_link='http://openclipart.org/media/people/barretr' license='CC0' license_link='https://creativecommons.org/publicdomain/zero/1.0/deed.en' %}<br />
{% include attribution.html title='physical router image' image_link='https://commons.wikimedia.org/wiki/File:Router.svg' author='George Shuklin' author_link='https://commons.wikimedia.org/wiki/User:George_Shuklin' license='Creative Commons Attribution-Share Alike 3.0 Unported' license_link='https://creativecommons.org/licenses/by-sa/3.0/deed.en' %}
{% endcapture %}

{% include svg.html path="svg/public-ip-over-vpn-nva.svg" caption="Public IP over VPN NVA network design" attribution=nva_attribution %}

Since this can be any type of device, I'm not going to show you how to do it, but you'll want to do the following in general on the NVA.

1. Create your NVA resource in Azure and with at least two NICs.
  - Assign a private static IP (`{{ ip_org_routing_router }}`) to the first NIC on the **routing** subnet.
  - Assign a static public IP address (`{{ ip_org_peer }}`) to the first NIC that will be used for the VPN peer. This is *not* the same as the public IP address for your application endpoint. (This public IP may also be used as your management access point, depending on the vendor.)
  - Assign a private static IP (`{{ ip_org_app_router }}`) to the second NIC on the **adjudication** subnet.
1. Establish a VPN connection to the clearinghouse's IPSec peer IP (`{{ ip_clearinghouse_peer }}`).
1. Create a NAT rule to translate your application's public IP address to its private address (`{{ ip_org_app_public }}` :arrow_right: `{{ ip_org_app }}`).
1. If necessary, create a NAT rule to translate your application's private IP address to its public address (`{{ ip_org_app }}` :arrow_right: `{{ ip_org_app_public }}`). For some routers, this may have been done as part the previous step.
1. If necessary, create a route to the clearinghouse's public IP over the VPN (`{{ net_clearinghouse_app_public }}` :arrow_right: VPN). For some routers, this route is inferred from the VPN.

You will also need to create an [Azure Route Table](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table#create-a-route-table) with a route to the NVA and associate it with the **adjudication** subnet and any other subnet that needs to access the clearinghouse network. Without this, our adjudication app will assume that traffic to `{{ net_clearinghouse_app_public }}` should go through the internet. In our example, the route table would contain a route with these properties.

|**Destination type**|IP Addresses|
|**Destination IP addresses**|{{ net_clearinghouse_app_public }}|
|**Next hop type**|Virtual appliance|
|**Next hop address**|{{ ip_org_app_router }}|

## Other Considerations

I didn't talk about firewalls, but always make sure you're restricting traffic through NSGs, Azure Firewall, or your NVA. Whenever I'm troubleshooting my network configuration I always remember two things: **routing** and **firewalls**. It almost comes down to one or both of those things at each hop.

Another consideration obviously is cost. The easy option is the lightest on the wallet. In 2024 dollars, the least expensive VPN Gateway costs $138.70 per month plus $10.80 for the site-to-site tunnel. The public IP prefix will cost you $4.32 per month. That comes to **$153.82** per month at the cheapest before your traffic ingress/egress charges. Not too shabby.

As an example for the NVA, the lowest tier option for a Fortinet FortiGate firewall is $262.80 per month before the costs of the underlying VM. For that, they recommend an F4 VM which comes to $889.87. That totals **$1,152.67** per month. That's not terrible but your CFO may not understand why you need this purchase.