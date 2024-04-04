---
title: Routing a Public IP Over a VPN Connection
category: thoughts
tags: vpn vpn-gateway virtual-network
toc: true
---
Each industry has its weird little standards. When I worked in the pharmacy space, that weird little standard was how you had to route certain public IP addresses over a private VPN.<!--more--> When I first came across this, I scratched my head as to why they did it this way. Then I had to figure out how to do this in a virtual cloud environment. Then I balled up my fists and screamed. Then I figured it out and went and got a beer. It was a tumultuous, exhilarating time!

## The Problem

Since this was required to process pharmacy payments, let me first offer the briefest background on how retail pharmacies process claims. When it's time to pick up your pills (none of my business what it's for), the pharmacy tech sends your prescription and insurance information to your insurance company. The insurance company responds back immediately with how much they will reimburse the pharmacy and how much the patient owes. It's actually a pretty well-oiled machine.

But just like every other part of the medical industry, there is a middleman in this process. Each pharmacy doesn't make a direct connection to each of the roughly [66 pharmacy insurers](https://content.naic.org/cipr-topics/pharmacy-benefit-managers) in the US. Instead, a pharmacy makes a connection to something known as a **clearinghouse** that relays the connection to the correct insurance company. The clearinghouse is like a hub in the middle of a wagon wheel. It connects to all the pharmacies and all the insurance companies.

My experience with this is only in the pharmacy space, but my understanding is that this model is the same for medical claims processing.
{: .notice--info}

Here's a rapid fire set of concepts to know for the rest of this article.

- The insurance company is known as the **payer**. Payers can be any entity that processes a claims (e.g., pharmacy discount cards).
- When the payer processes claims, it's known as **adjudication**.
- The adjudication process has been around since before web services were popular, so this connection is made over TCP sockets (which is why we need the VPN connection in the first place). Some clearinghouses are developing REST services, so hopefully this whole networking model will be a thing of the past in a few years.
- For stupid historical reasons, the pharmacy coverage part of your medical insurance is technically known as a **pharmacy benefit manager** or **PBM**. If you find yourself at a dinner party sitting next to someone in the retail pharmacy space, use the term "PBM" and watch their face light up.

### Public IP Addresses to the Rescue

On to the technical problem. Each payer that wants to communicate with the clearinghouse will need some type of network connection. This often will be a site-to-site VPN connection. But when you traditionally think about a corporate site-to-site VPN, you're usually connecting two or more separate private networks that are controlled by the organization. This means you can ensure that each site has a separate private address space that don't overlap. For instance, your small satellite office in San Francisco, CA may have the 192.168.0.0/24 address space whereas your gigantic headquarters in Boerne, TX has the 10.0.0.0/12 address space.

If you're not a network person, there's two types of IPv4 addresses: public and private. Private addresses can be assigned however you want in your private network but cannot be used on the public internet. Since private addresses can be assigned however you want, there's no guarantee that the private address space that the clearinghouse has available will be available on your network. In a perfect world, the clearinghouse would have the same unused private subnet as your organization does. Also, in a perfect world, there would be no disease and we wouldn't need pharmaceutical companies at all, but that's not our reality.

Since public IP addresses are guaranteed to be unique, the clearinghouses have chosen to use that as their solution. So you assign a public IP address to your adjudication endpoint where the clearinghouse will establish a TCP connection. The whole thing looks something like this:



Using public IPs ensures that there are no IP address collisions like you potentially would have if you were only connecting private networks. There is nothing in the IPSec VPN specifications that say you can't use public IP addresses, but it's a departure from how you regularly do things so it takes some noodling to get it right.

### Challenges in Azure

This can be done with native Azure services, but there are some challenges.

The main challenge is that Azure VPN Gateway does not support DNAT. As you recall, the clearinghouse will be sending packets over the VPN to a public IP address. We need to translate that destination public IP address to the private IP address associated with our application, but the VPN Gateway lacks any DNAT feature. If you Google it you may discover that all but the cheapest SKUs support [NAT](https://learn.microsoft.com/en-us/azure/vpn-gateway/nat-overview). But this is only source NAT. Even if the source is translated, the destination will still go to our public IP address.

But hmmm, you think. Maybe you could still route to that public IP through Azure's software-defined networking, you think. (This is more of a thought experiment, so go with me on this one.) Lets say you're trying to game the system and decide that since the packets to our application's public IP can route over the VPN but we can't NAT it to our private IP, what if we assign the public IP to a VM and let it just route that last little bit over the public internet? After all, since this will be going from one Azure resource (VPN Gateway) to another Azure resource (VM), it will probably stay within the edge of the Microsoft global network ([cold potato routing](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/routing-preference-overview#routing-via-microsoft-global-network)).

Shame on you for thinking such a thing! That network is still untrusted! But even if your CSO approved such a hairbrained scheme, the Azure VPN Gateway [does not allow internet access](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-p2s-advertise-custom-routes#forced-tunneling), so you can give up on the idea.

This is more of a thought experiment, so go with me on this one. Lets say you're trying to game the system and decide that once the packet to your public IP arrives over the VPN, you'll let the packet route to the application endpoint over Azure's public network. Here's the scheme you've cooked up.

:office: :arrow_right: :zap: :arrow_right: :cloud: :arrow_right: :desktop_computer:

In case you didn't follow that diagram, here's the heist.

1. You assign your application's public IP to the NIC of your applicaton's VM or public load balancer.
1. You block traffic 
1. Traffic leaves the clearinghouse (:office:) bound for your application's public IP.
1. Traffic routed over the VPN (:zap:).
1. Traffic leaves the VPN and goes over the public network (:cloud:) to your application (:desktop_computer:).

You figure that since this is going from one Azure resource (:zap:) to another (:desktop_computer:), it's going to stay within the Microsoft global network ([cold potato routing](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/routing-preference-overview#routing-via-microsoft-global-network)). You're thinking is that since this is all in the Microsoft family, it's trusted. Well, that's making a ton of assumptions. The Azure VPN Gateway [does not allow internet access](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-p2s-advertise-custom-routes#forced-tunneling).

- VPN Gateway will not route to the Internet
- VPN Gateway does not support DNAT (SNAT supported with NAT Gateway)
- Got to make sure firewall and routing is all correct

## Solutions

There's a handful of ways to tackle this in Azure, including some bad ideas that I'll show you! In general, this is what you'll need to do in all circumstances.

1. Provision a public IP address that you will use for your application's endpoint. This is the public address that the clearinghouse will be connecting to. You'll need to purchase an IP address from some source, like your ISP or from Azure. You won't actually expose this public IP address to the internet; you just need to make sure that you own the IP. If you purchase it from Azure, you simply buy a static public IP resource without associating it with any other Azure resource.
1. Configure a NAT rule on your network solution to translate the public IP you provisioned to the private IP of your application endpoint. This private endpoint could also be a load balancer if your application is highly available.
1. Configure routing from your VPN to the public IP address of your application.
1. Configure routing from your application to the public IP address of the clearinghouse.

All of the examples below except for the NVA require you to create an Azure VPN Gateway to establish the VPN connection to the clearinghouse. I can't provide a step-by-step for this since it will depend on the clearinghouse, but Microsoft has a [tutorial](https://learn.microsoft.com/en-us/azure/vpn-gateway/tutorial-site-to-site-portal) for a site-to-site VPN Gateway connection. This is always the tricky part and will probably involve some back and forth with the clearinghouse technician. You probably won't get it right the first time, so be prepared for this to potentially take a few days to get squared away.

The frustrating thing is that the Azure VPN Gateway lacks real-time [logging](https://learn.microsoft.com/en-us/azure/vpn-gateway/troubleshoot-vpn-with-azure-diagnostics) that makes troubleshooting a slog. Here's my suggestions for items to check. The Azure VPN Gateway resource itself doesn't have a lot of configuration. Most of the settings for the configuration are found on the connection listed in the **Connections** blade of the VPN Gateway resource in the portal. The connection resource will have a link to the associate local network gateway resource that defines certain properties for the clearinghouse's side of the connection.

- Check Microsoft's recommended [site-to-site VPN troubleshooting](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-troubleshoot-site-to-site-cannot-connect) list.
- Ensure that the basic configuration items are correct, like the pre-shared key (PSK) and IPSec peer addresses (yours and the clearinghouse's side).
- Check that the [default cryptographic policies](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices#ipsec) will work for your clearinghouse. If not, you can use a [custom configuration](https://learn.microsoft.com/en-us/azure/vpn-gateway/ipsec-ike-policy-howto) for your connection.
- Check if the clearinghouse uses policy- or route-based selectors. If policy-based, enable the policy-based traffic selector option and define the custom traffic selectors.
- On the local network gateway resource, ensure that the address space for the clearinghouse's public IP address range is correct.

### Network Virtual Appliance

The best way to do this is to use a network virtual appliance (NVA). An NVA is virtual router from a non-Microsoft vendor of your choosing (Cisco, Palo Alto, Fortinet, etc.) that you can purchase from the Azure marketplace. This is like plopping a physical router that you're already familiar with in Azure (but it's like, virtual, man) and grants you complete control over your networking infrastructure, including the VPN connection, routing, and NAT. If you already have experience using, say, a Cisco device, you can apply all of existing knowledge to the NVA without having to learn a new Azure networking service. The downside is that this can be a bit costly since you'll be paying for the underlying Azure VM that the NVA runs on plus a premium for the vendor's product license.

Since this can be any type of device, I'm not going to show you how to do it, but you'll want to do the following in general on the NVA.

1. Create your NVA resource in Azure and assign it a public IP address that will be used for the VPN peer. This is *not* the same as the public IP address for your application endpoint.
1. Establish a VPN connection to the clearinghouse.
1. Create a route to your application's public IP (clearinghouse => application).
1. Create a NAT rule to translate your application's public IP address to its private address.
1. Create a route to the clearinghouse's public IP over the VPN (application => clearinghouse).

### Azure VPN Gateway + Azure Firewall

### Azure VPN Gateway + Custom VM Router (Bad Idea)

If your company is bordering on bankruptcy and needs to do this on the cheap, you can build your own router using a Linux or Windows VM. If that's your situation, well it's concerning that you're in the healthcare space. But on the other hand, this solution works just fine and I don't see any obvious security risks. It just doesn't feel right. In any case, here's how you do it.

The first step is to create a VM. The Linux example will use Debian, so choose that option unless you're comfortable configuring networking on other distributions.

1. Create your Debian Linux or Windows Server VM.
1. Go to the **Networking** blade of your VM, select the NIC, go to the **IP configurations** blade, and select **Enable IP forwarding**.

#### Linux Router

#### Windows Server Router

## Bonus: Simulating the Clearinghouse

