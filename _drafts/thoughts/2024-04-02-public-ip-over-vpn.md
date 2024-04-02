---
title: Routing a Public IP Over a VPN Connection
category: thoughts
tags: vpn vpn-gateway virtual-network
toc: true
---
Each industry has its weird little standards. When I worked in the pharmacy space, that weird little standard was how you had to route certain public IP addresses over a private VPN.<!--more--> When I first came across this, I scratched my head as to why they did it this way. Then I had to figure out how to do this in a virtual cloud environment. Then I balled up my fists and screamed. Then I figured it out and went and got a beer. It was a tumultuous, exhilarating time!

## The Problem

Since this was required to process pharmacy payments, let me first offer the briefest background on how retail pharmacies process claims. When it's time to pick up your pills (it's none of my business what it's for), the pharmacy tech sends your prescription and insurance information to your insurance company. The insurance company responds back immediately with how much they will reimburse the pharmacy and how much the patient owes. It's actually a pretty well-oiled machine.

But just like every other part of the medical industry, there is a middleman in this process. Each pharmacy doesn't make a direction connection to each conceivable insurance company. Considering there are roughly [66 pharmacy insurers](https://content.naic.org/cipr-topics/pharmacy-benefit-managers) in the US, that would be a lot of work. Instead, a pharmacy makes a connection to something known as a clearinghouse that relays the connection to the correct insurance company. The clearinghouse is like a hub in the middle of a wagon wheel. It connects to all the pharmacies and all the insurance companies.

This process has evolved from the old days of TCP socket connections, which is why we need the VPN connection in the first place. Some clearinghouses are developing REST services, so hopefully this whole networking model will be a thing of the past in a few years.

As I understand it, this process works roughly the same for medical claims, but I only have experience with the pharmacy side. Also, it's not just insurance companies that connect to the clearinghouse; any entity known as a **payer** (e.g., discount cards) can play the same role as an insurance company in this model. Oh and for the record, pharmacy insurance companies are technically called plan benefit managers (PBMs). For the rest of this article, I'm going to be looking at this from the point of view of a payer. This assumes that there is an application on our end that will process claims, known as claims **adjudication**.
{: .notice--info}

### Public IP Addresses to the Rescue

On to the technical problem. Each payer that wants to communicate with the clearinghouse will need some type of network connection. This often will be a site-to-site VPN connection. But when you traditionally think about a corporate site-to-site VPN, you're usually connecting two or more separate private networks that are controlled by the organization. This means you can ensure that each site has a separate private address space that don't overlap. For instance, your small satellite office in San Francisco, CA my have the 192.168.0.0/24 address space whereas your gigantic headquarters in Boerne, TX has the 10.0.0.0/12 address space.

If you're not a network person, there's two types of IPv4 addresses: public and private. Private addresses can be assigned however you want in your private network but cannot be used on the public internet. Since private addresses can be assigned however you want, there's no guarantee that the private address space that the clearinghouse has available will be available on your network. In a perfect world, the clearinghouse would have the same unused private subnet as your organization does. Also, in a perfect world, there would be no disease and we wouldn't need pharmaceutical companies at all, but that's not our reality.

Since public IP addresses are guaranteed to be unique, the clearinghouses have chosen to use that as their solution. So you assign a public IP address to your adjudication endpoint where the clearinghouse will establish a TCP connection. The whole thing looks something like this:


Using public IPs ensures that there are no IP address collisions like you potentially would have if you were only connecting private networks. There is nothing in the IPSec VPN specifications that say you can't use public IP addresses, but it's a departure from how you regularly do things so it takes some noodling to get it right.

### Challenges in Azure

