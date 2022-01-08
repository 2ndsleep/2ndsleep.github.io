---
title: TCP/IP Explainer Part 3 (IP)
category: explainer
service: Networking
toc: true
---
IP is how computers talk to each other over long distances. Computers are assigned IP addresses which can be routed across multiple networks.

{% assign mac1 = 'A2-63-00-A3-58-B7' %}
{% assign mac2 = 'C2-8E-55-92-FC-36' %}
{% assign mac3 = '12-DD-67-45-7E-8D' %}

# The Problem

I promise we'll get to IP, but let's take a quick step back and talk about why we even need it.

## You Did Read My Last Post, Right??

If you read my previous post (you did read it, right??) then you'll remember that it's technically possible to allow computers to talk to each other without IP addresses. Also, if you read my previous post (you did read it, right??) you'll remember this irresponsibly simple analogy where we assign each computer a unique ID and connect all the computers to a switch.

{% include svg.html path="svg/network-simple-link-layer2-to-from.svg" %}

If you didn't read my last post like an asshole, here's the short story. In the above example, the switch knows which port each computer is plugged into and therefore knows where to send *Ethernet frames*. So like the little box says, if computer 1 wants to send to computer 4, it puts the **to** and **from** information in the frame and the switch knows which port computer 4 is on and sends it that way.

Now in real life, these computers aren't numbered 1 through 4, they have IDs called *MAC addresses* that look something like `{{ mac1 }}`.

## Broadcast Domain

In the last post, we also talked about *broadcast domains*. In short, everything that can talk to each other without going through a router (we'll talk about routers later) is in a broadcast domain. You can expand a broadcast domain by connecting switches to each other. In the image below, all the computers are on the same broadcast domain.

{% include svg.html path="svg/network-link-layer2-computers-broadcast-domain.svg" %}

## A World Without IP

It would be totally possible to put the entire internet on a single broadcast domain, but that would be a fucking terrible idea. Remember all that flooding we talked about in the last post (you did read it, right??)? That's fine if that happens occassionally on our little private network, but if that happened constantly on the whole internet, all the bandwidth would be consumed with flooding, and we need that bandwidth for watching ASMR videos.

More importantly, that would be a huge security problem if we were flooding frames all over the place. Even though devices are not *supposed* to process frames that are not addressed to them, that's only a standard. And as my great-aunt used to say, "if I'm a-gettin' an Ethernet frame, I'm a-gonna read it no matter if it's a-addressed to me or not, dadgonnit." So there could be a lot of people out there like my voyeuristic great-aunt who would read your Ethernet frames.

# The Solution

Wouldn't it be better if we broke up our networks into discrete chunks and then only let the individuals in each chunk to talk to other individual computers in another chunk whenever they have to? That's a rhetorical question, and the answer is yes.

There's a lot of ways this can be and are done, but since this is a crash course, here's how it works in practical terms.

- Each computer in a broadcast domain is assigned an IP address that is in the same network.
- Any computer that needs to talk to a computer in its same network can just chat directly through switches.
- Any computer that needs to talk to a computer outside is network needs to go through a router.

I like to think of this whole situation like a bunch of rooms in a building. Each room has a bunch of people in it. People inside a room can pass messages to people in the same room, but they must go through a doorman (door person? how about we say "doorkeeper"?) to pass messages to people in other rooms.

Why are all these people trapped in various rooms, you ask? I don't know. Maybe they're in a prison in one of those Nordic countries where even the criminals are better than people in other countries. I'll let you shoehorn in the logic of the example. For now, it looks something like this.

{% include svg.html path="svg/network-ip-layer3-rooms.svg" %}

All the people in room 1 can pass messages directly to each other, and all the people in room 2 can pass messages directly to each other, but a person in room 1 can only pass a message to a person in room 2 by giving it to the doorkeeper in the middle (the red one) who then passes it to the person in room 2.

You may have figured out by now that the rooms are broadcast domains and the doorkeeper is a router. In short, all the devices that are connected to the same set of switches are in the same broadcast domain. So in the diagram below there are four broadcast domains - each room is its own broadcast domain. If any computer in a room wants to talk to a computer in another room, it must go through the router in the middle.

{% include svg.html path="svg/network-ip-layer3-rooms-computers.svg" %}