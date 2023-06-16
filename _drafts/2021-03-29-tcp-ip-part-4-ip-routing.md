---
title: TCP/IP Explainer Part 4 (IP Routing)
categories: networking virtual-network explainer
toc: true
---
The best thing about IP addresses is that they are routable. Routers get IP packets from one computer to a computer on a different network.

{% assign ip1 = '192.168.1.10' %}
{% assign subnet1mask = '255.255.255.0' %}
{% assign subnet1 = '192.168.1.0' %}

{% assign ip2 = '192.168.1.40' %}
{% assign ip3 = '192.168.92.88' %}

{% assign subnet2 = '192.168.92.0' %}

{% assign mac1 = 'A2-63-00-A3-58-B7' %}
{% assign mac2 = 'C2-8E-55-92-FC-36' %}
{% assign mac3 = '12-DD-67-45-7E-8D' %}

## Previously on "TCP/IP Networking"

In the last post, we talked about a computer with these properties.

- **IP Address**: {{ ip1 }}
- **Subnet Mask**: {{ subnet1mask }}
- **Subnet ID**: {{ subnet1 }}

The subnet ID was calculated from the IP address and the subnet mask.

That computer wanted to send to another computer with an IP address of `{{ ip2 }}`. We did the math and determined computer 2 was on the same subnnet ID and computer 1 could therefore communicate over the switch without using a router.

Then computer 1 want to send to a third computer with an IP address of `{{ ip3 }}`. We did the math and determined that computer was not on the same subnet and would therefore have to go through a router.

So what and where is this router?

## Router

A *router* is a network devicesthat sends (or, you guessed it, *routes*) IP packets to the appropriate destination. A router has at least two networks connected to it and when it receives IP packets from one network, it determines which network to forward the packet to. (Technically it could have only one network connected to it, but that would be pointless because the packets could never leave its source network.)