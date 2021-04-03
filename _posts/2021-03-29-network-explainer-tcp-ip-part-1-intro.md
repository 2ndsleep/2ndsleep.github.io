---
title: TCP/IP Explainer Part 1 (The Boring Stuff)
category: explainer
service: Networking
toc: true
---
Why

OSI

Ethernet (Not all layers have to use Ethernet/IP/TCP, etc)

Virtual/physical

Network+

## Models

Networking can seem daunting at first, because it is. There's lots of moving parts interacting with each. To help organize things a little better, engineers came up with different models to try to describe how networking works. This may seem needlessly academic, but when you're troubleshooting network issues in the real world, it helps a ton if you think about which layer in the model the problem is occurring instead of losing your shit and biting your arms.

There are several competing models but the two most famous are the OSI (developed, confusingly, by the ISO) and the TCP/IP model. I like the TCP/IP model, so we'll stick with that one.

> This isn't to say that the OSI model is stinky poop. It's good poop and you'll often hear people talk about layer 1-7. We're keeping it short and simple here, but I recommend you read up on the OSI model so you can talk shop with other network engineers.

<div class="mermaid">
graph TD;
  A[Application]---T[Transport];
  T---I[Internet];
  I---L[Link];
</div>

I like to go in reverse order, starting with the Link layer which is the closest to the wires running from your Ethernet port. Here's the crude breakdown of each layer along with some words you may have heard about that are related to each layer.

|Layer|Description|Word Association|
|-----|-----------|----------------|
|Link|This is most basic stream of data coming and going between your computer and the wire.|NIC, Ethernet cable, MAC address, switch, datagrams|
|Internet|This is where computers are assigned IP addresses and how data gets routed to other computers.|IP, route, router, packets|
|Transport|This is where applications are associated with data. Like, how your computer knows whether data it receives should go to your web browser or to your Spotify app.|port, TCP, UDP|
|Application|This is where the application figures out what to do with the data. You generally have the least control over this layer, so we're going to completely ignore it in this post.|layer-7 firewall|