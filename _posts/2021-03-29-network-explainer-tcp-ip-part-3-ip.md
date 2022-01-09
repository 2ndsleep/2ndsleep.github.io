---
title: TCP/IP Explainer Part 3 (IP)
category: explainer
service: Networking
toc: true
---
IP is how computers talk to each other over long distances. Computers are assigned IP addresses which can be routed across multiple networks.

{% comment %}
Change these values to update the IP or MAC addresses used thoughout this post.
Monospace-formatted IPv4 text and binary values will be automatically calculated. 
{% endcomment %}
{% assign ip1 = '192.168.1.10' %}
{% assign subnet1mask = '255.255.255.0' %}
{% assign subnet1 = '192.168.1.0' %}

{% assign mac1 = 'A2-63-00-A3-58-B7' %}
{% assign mac2 = 'C2-8E-55-92-FC-36' %}
{% assign mac3 = '12-DD-67-45-7E-8D' %}

{% comment %}
These Liquid statements render the monospace-formatted IPv4 text and binary values.
Do not change these unless the output needs to be changed.
{% endcomment %}
{% assign space = ' ' %}

{% comment %}IP address octets{% endcomment %}
{% assign ip1octets = ip1 | split: "." %}
{% comment %}IP address monospace-formatted text{% endcomment %}
{% capture ip1monospace %}{% for i in (0..3) %}{% assign osize = ip1octets[i] | size %}{% if osize == 1 %}{{ space }}{{ space }}{% endif %}{% if osize == 2 %}{{ space }}{% endif %}{{ ip1octets[i] }}{% if i < 3 %}{{ space }}.{{ space }}{% endif %}{% endfor %}{% endcapture %}
{% comment %}IP address binary value{% endcomment %}
{% capture ip1binary %}{% for octet in ip1octets %}{% assign o = octet %}{% assign d = 128 %}{% for i in (0..7) %}{% assign bit = o | divided_by: d %}{% assign o = o | modulo: d %}{% assign d = d | divided_by: 2 %}{{ bit }}{% endfor %}{% endfor %}{% endcapture %}

{% comment %}Subnet mask octets{% endcomment %}
{% assign subnet1maskoctets = subnet1mask | split: "." %}
{% comment %}Subnet mask monospace-formatted text{% endcomment %}
{% capture subnet1maskmonospace %}{% for i in (0..3) %}{% assign osize = subnet1maskoctets[i] | size %}{% if osize == 1 %}{{ space }}{{ space }}{% endif %}{% if osize == 2 %}{{ space }}{% endif %}{{ subnet1maskoctets[i] }}{% if i < 3 %}{{ space }}.{{ space }}{% endif %}{% endfor %}{% endcapture %}
{% comment %}Subnet mask binary value{% endcomment %}
{% capture subnet1maskbinary %}{% for octet in subnet1maskoctets %}{% assign o = octet %}{% assign d = 128 %}{% for i in (0..7) %}{% assign bit = o | divided_by: d %}{% assign o = o | modulo: d %}{% assign d = d | divided_by: 2 %}{{ bit }}{% endfor %}{% endfor %}{% endcapture %}

{% comment %}Subnet ID octets{% endcomment %}
{% assign subnet1octets = subnet1 | split: "." %}
{% comment %}Subnet ID monospace-formatted text{% endcomment %}
{% capture subnet1monospace %}{% for i in (0..3) %}{% assign osize = subnet1octets[i] | size %}{% if osize == 1 %}{{ space }}{{ space }}{% endif %}{% if osize == 2 %}{{ space }}{% endif %}{{ subnet1octets[i] }}{% if i < 3 %}{{ space }}.{{ space }}{% endif %}{% endfor %}{% endcapture %}
{% comment %}Subnet ID binary value{% endcomment %}
{% capture subnet1binary %}{% for octet in subnet1octets %}{% assign o = octet %}{% assign d = 128 %}{% for i in (0..7) %}{% assign bit = o | divided_by: d %}{% assign o = o | modulo: d %}{% assign d = d | divided_by: 2 %}{{ bit }}{% endfor %}{% endfor %}{% endcapture %}

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

Wouldn't it be better if we broke up our networks into discrete chunks and then only let the individual computers in each chunk to talk to other individual computers in another chunk whenever they have to? That's a rhetorical question, and the answer is yes.

There's a lot of ways this can be and are done, but since this is a crash course, here's how it works in practical terms.

- Each computer in a broadcast domain is assigned an IP address that is in the same IP network.
- Any computer that needs to talk to a computer in its same IP network can just chat directly through switches.
- Any computer that needs to talk to a computer outside is IP network needs to go through a router.

I like to think of this whole situation like a bunch of rooms in a building. Each room has a bunch of people in it. People inside a room can pass messages to people in the same room, but they must go through a doorman (door person? how about we say "doorkeeper"?) to pass messages to people in other rooms.

Why are all these people trapped in various rooms, you ask? I don't know. Maybe they're in a prison in one of those Nordic countries where even the criminals are better than people in other countries. I'll let you shoe-horn your own logic for the example. Anyhow, it looks something like this.

{% include svg.html path="svg/network-ip-layer3-rooms.svg" %}

All the people in room 1 can pass messages directly to each other, and all the people in room 2 can pass messages directly to each other, but a person in room 1 can only pass a message to a person in room 2 by giving it to the doorkeeper in the middle (the red one) who then passes it to the person in room 2.

You may have figured out by now that the rooms are broadcast domains and the doorkeeper is a router. In short, all the devices that are connected to the same set of switches are in the same broadcast domain. So in the diagram below there are four broadcast domains - each room is its own broadcast domain. If any computer in a room wants to talk to a computer in another room, it must go through the router in the middle.

{% include svg.html path="svg/network-ip-layer3-rooms-computers.svg" %}

If we drop the whole room analogy, our diagram looks like this, with each broadcast domain circled.

{% include svg.html path="svg/network-ip-layer3-computers-broadcast-domains.svg" %}

# Some Ground Rules

If you were taking a real networking class, you'd learn a lot more than this little blog page, so let me state what what we're *not* going to talk about.

- **How to actually assign an IP address on a computer.** You can Google that.
- **Detailed IP math.** You absolutely should learn how to do that if you will be managing networks in any way, but we're going to keep it simple here.
- **IPv6.** That is a tutorial all on its own. And to be honest, I don't understand it well enough to teach it. We're sticking with IPv4 only. IPv4 addresses are the ones that look like `10.248.85.17`.
- **The concept of classful networking, because it's antiquated.** If you don't know what that means, great! The less you know about it, the better.

# IP Addresses

An IP address is a numeric value that is used to assign an identity to a computer. Behind the scenes, it is really just one long 32-bit binary number but we write in a way that is easier for mere humans to understand, which looks like this.

```
{{ ip1 }}
```

This is often called *dot-decimal notation*. The IP address is broken up into four *octets* separated by dots. Or "decimals," if you prefer. Or "dot-decimal." The English language can be really dumb sometimes. Each octet is an 8-bit number which means that it can be a value of 0 through 255.

## Assigning an IP Address

I'm going to breeze through this very quickly. There are two ways to assign an IP address to a computer.

The first is that an administrator logs into the computer and then types the IP address into the place where you configure an IP address. This is different for each operating system, and as I already warned you, I'm not going to explain that. But these links may help for [Windows](https://support.microsoft.com/en-us/windows/change-tcp-ip-settings-bd0a07af-15f5-cd6a-363f-ca2b6f391ace), [macOS](https://support.apple.com/sq-al/guide/mac-help/mchlp2718/mac), or [Linux](https://danielmiessler.com/study/manually-set-ip-linux/).

### Manual Assignment

Walking over to each computer and assigning an IP address is a lot of management, and more worrisome, it involves exercise. This is nearly impossible if you're managing hundreds or thousands of computers. What we do instead is let the computer request an IP address automatically from a DHCP server. When the computer starts up, it sends a broadcast frame with a payload that is requesting an IP address from a DHCP server. The first DHCP server to respond will return an IP address that the computer will assign itself.

### DHCP Assignment

People rarely manually assign IP addresses. Even in small networks like your home network, your home router has a DHCP server built into it to assign your laptop an IP address.

## DNS

Your next question may be how do computer discover the IP address of another computer? That's kind of off-topic and I wish you'd stay focused, but I'll go ahead and answer that. DNS handles the trick of resolving names to IP addresses. People remember words much better than numbers so when you type google.com into your web browser, your computer contacts a DNS server to ask what the IP address is for google.com.

# Internet Protocol

We got this far without explaining what IP stands for. *Internet protocol*. IP stands for internet protocol. Just like Ethernet is on the link layer, IP is on the internet layer and has a different job than Ethernet. And just like how Ethernet has its frames, IP has something known as *packets*. IP packets live inside Ethernet frames.

You may wondering why we need another identifying number when you just read a whole post about MAC addresses (you did read it, right??). You're right in that they have a similar purpose but they have a few very important differences.

## Routability

IP addresses are *routable* and MAC addresses are not. This is the most important distinction. IP addresses allow a chunk of data to get from one IP network to another IP network which may be located on the other side of the world.

MAC addresses only allow you to send to another computer on the same broadcast domain. To leave the broadcast domain, you need to send it to the MAC address of the router.

## Mutability

I'm not sure if this is the official word, but *mutability* is one of those words that makes you sound smart to computer geeks. (Related: look up the word *idempotent* and then drop that casually into conversations and you might get a raise.)

The point is, MAC addresses are effectively burned into the physical network card and are not changeable. In other words, they are immutable. IP addresses are assigned by a person or by a server to the computer and can be changed at any time. Or perhaps you could say they are mutable.

## Link Layer vs. Internet Layer

MAC addresses operate on the link layer. IP addresses operate on the internet layer. MAC addresses are how two devices talk directly to each other. A network device will send an Ethernet frame from its MAC address to the MAC address of another device. The destination MAC address could be another computer or a router.

When the destination MAC address is a router, the router opens up the Ethernet frame and examines the IP information inside and decides where to send it from there. That's because the IP packet is the payload of the Ethernet frame.

{% include svg.html path="svg/network-link-layer2-layer3-encapsulation.svg" %}

I'm going to say it again: Ethernet and MAC addresses are in a different layer than IP and IP addresses. In fact, even though computers are assigned IP addresses, they are only partially useful when computers are talking to other computers in the same broadcast domain. The IP layer is embedded inside the link layer payload. The link layer devices don't know that there is IP stuff inside the payload because they only worry about MAC-related business.

# IP Networks

An IP address by itself is not enough information for a computer to determine where to send packets. A computer needs to know if the destination IP address is on the same network or some other network before it decides where to send its packet.

Let's go back to our room example. If a computer wants to talk to a computer in the same room (or broadcast domain) it will need to figure out if it's in the same room (or broadcast domain) by looking at the IP address of the destination computer. If IP address indicates the computer is in the same room (or broadcast domain), it will talk directly to the computer via the switch. If thie IP address indicates the computer is not in the same room (or broadcast domain), it will need to go through the router.

We do all this by grouping IP addresses into separate networks called *subnets*. An IP address is defined to be part of a subnet according to its *subnet mask*.

## Subnet Masks

Whenever a computer is assigned an IP address, it also needs to be assigned a subnet mask in order to know which subnet it is part of. The subnet mask combined with an IP address is used to calculate the subnet that an IP address is on.

Assume a computer is assigned an IP address of `{{ ip1 }}`. If it were assigned a subnet mask of `{{ subnet1mask }}` then it would be on the `{{ subnet1 }}` subnet.

<img src="/assets/images/posts/no-math.jpeg" width="290" height="293">

Yeah, sorry about that. I'm going to make this unmathy as possible. **But let me stress that you very much should figure out subnetting math if you want to do this for real.** The following explanation is fairly shitty and won't be that helpful if you want to work on different sized subnets, but it will hopefully help you understand it a tad.

The subnet mask in this case says to keep all the octets in the IP address the same where the subnet mask octet is 255 and to zero-out the octets in the IP address where the subnet mask is 0.

So...

```
IP Address:  {{ ip1monospace }}
Subnet Mask: {{ subnet1maskmonospace }}
=======================================
             keep  keep  keep  zero
Subnet ID:   {{ subnet1monospace }}
```

Very quick, here's what's really happening. As far as your network card is concerned, the IP address and the subnet mask are binary values and it performs a binary AND operation on them. Anywhere the subnet mask is 1, we use the value from the IP address. Anywhere the subnet mask is 0, we ignore the IP address and use 0.

```
IP Address:  {{ ip1binary }}
Subnet Mask: {{ subnet1maskbinary }}
=============================================
Subnet ID:   {{ subnet1binary }}
```

If you need help converting to binary, you can use an online tool like Code Beautify's [IP to Binary Converter](https://codebeautify.org/ip-to-binary-converter).