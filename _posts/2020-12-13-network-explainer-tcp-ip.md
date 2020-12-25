---
title: TCP/IP Explainer
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
|Transport|This is where applications are associated with data. Like, how your computer knows wheter data it receives should go to your web browser or to your Spotify app.|port, TCP, UDP|
|Application|This is where the application figures out what to do with the data. You generally have the least control over this layer, so we're going to completely ignore it in this post.|layer-7 firewall|

## Link Layer (Ethernet)

If you've heard about IP and TCP and you know a little bit about that, get that out of your mind right now. It's only going to be confusing. You'll understand this better if you clear your head and forget that IP exists for the moment.

Ethernet is a way for computers to communicate with each other on a network. Ethernet doesn't really have a clear definition. It's like pornography: you'll know it when you see it. (Unlike pornography, you can Google the word "Ethernet" at work.) All I can say for sure is that it operates on the Link layer.

Here's the story with Ethernet. Each physical network device has something called a MAC address associated with it. MAC stands for *media access control* and does not refer to Apple Macintosh computers (this is actually a common misconception for people learning this stuff). In the old days, this MAC address was burned-in to the network card and couldn't be changed. Also, it was guaranteed to be unique. This isn't really the case anymore, but let's pretend that's the situation because it makes understanding this much easier and it's more or less how it still works.

A MAC address is a hexadecimal value that looks something like this: `90-02-00-A3-58-B7`. As I said, each network adapter has has one MAC address assigned to it. If we made the world's smallest network and connected two computers together with an Ethernet cable, these two computers could talk to each other directly by sending data to each other's MAC addresses. They wouldn't even need to use IP addresses!

<div class="mermaid">
graph LR;
  subgraph Computer 1;
    NIC1[90-02-00-A3-58-B7];
  end;
  subgraph Computer 2;
    NIC1-->NIC2[91-02-55-92-FC-36];
  end;
</div>

### Data Frames

Okay, first of all, let's settle on some terms. I'm going to mix up the language used in different models, so sorry about that. We're going to call the units of data transmitted on the Link Layer to be known as Ethernet *frames*.

An Ethernet frame is a chunk of data that's sent from one network adapter, transmitted over a cable, and then received by another network adapter. This data is a bunch of 1's & 0's but it is ordered in a way that each network adapter can understand it. The sequence of the data on a frame is thusly:

|Preamble & SFD|MAC Destination|MAC Source|Ethernet Type|Payload|CRC|
|--------------|---------------|----------|-------------|-------|---|
|Indicates new frame|**Where this frame came from**|**Where this frame is going**|Metadata about frame|**Actual data**|Verification data|

Most of this isn't that imporant (unless you're dealing with VLANs, which I'm totally ignoring in this post), so let's focus on the three things that are worth talking about.

- **MAC Destination**: This is the MAC address of the network adapter that this frame is going to. When a network adapter wants to send a frame to another network adapter, it puts the MAC address of that other network adapter here.
- **MAC Source**: This is the MAC address of the network adapter that sent this frame. If this is the network adapter that's sending this frame, it's going to put its own MAC address here.
- **Payload**: This is the actual data we're sending. So if one computer is sending a video of a cat to another computer, this video data will be sent in the payload. This deserves a little more nuanced explanation here.
  - Well, not the entire cat video will be sent. As you can probably guess, data is broken up into smaller chunks and sent in pieces. So the payload of this frame will be one part of the cat video.
  - The payload won't just contain the cat video data, it will contain information about the Internet Layer, i.e., IP addresses. But don't get too hung up on that. The point is, each layer will contain a payload that may or may not have information inside it for the next layer, but the current layer doesn't care. The network adapter just knows that it's going to unpack the payload from the frame and send it on to the next layer. This concept is known as *encapsulation* if you're reading a textbook.

How does a network adapter know the MAC address of another network adapter? We'll get to that later in this section, but for now, let's just assume that the computers already know the MAC addresses of all the other computers it wants to talk to. In fact, you may be wondering, why do we need IP addresses if we have MAC addresses? Well, the truth is, we don't. If we had just a few computers networked together, MAC addresses would be sufficient and we could conceivably skip IP addresses altogether. But once we get outside of our little network, we're going to need more than just MAC addresses, as we'll see.

### Switching

The end of the last section gave you a preview of what IP addresses do, but let's go back to pretending they don't exist. We're going to keep our network small but make it bigger than two computers. If we want to have three or more computers talk to each other, we'll need to put some kind of network device to connect them all. We'll need to use something called a *switch*. (If you're old like me, you'll be familiar with something called a *hub*. They look like switches, but they are very anitquated, and slow as dick for reasons that will make sense if you prepare for the Network+ exam. I don't even know where you'd buy a hub anymore. If you're still using a hub in a professional environment, then may God have mercy on your soul.)

<div class="mermaid">
graph LR;
  S(Switch);
  subgraph Computer 1;
    NIC1[90-02-00-A3-58-B7];
  end;
  subgraph Computer 2;
    NIC2[91-02-55-92-FC-36];
  end;
  subgraph Computer 3;
    NIC3[92-02-67-45-7E-8D];
  end;
  NIC1[90-02-00-A3-58-B7]---S;
  NIC2[91-02-55-92-FC-36]---S;
  NIC3[92-02-67-45-7E-8D]---S;
</div>

A switch is a device that has multiple physical ports. For the sake of argument, let's say this is the rare 3-port switch and it looks like this.

<div class="mermaid">
graph LR;
  subgraph Switch;
    P1[Port1];
    P2[Port2];
    P3[Port3];
  end;
</div>

So let's show the switch ports that each computer is plugged into.

<div class="mermaid">
graph LR;
  subgraph Switch;
    P1[Port1];
    P2[Port2];
    P3[Port3];
  end;
  subgraph Computer 1;
    NIC1[90-02-00-A3-58-B7];
  end;
  subgraph Computer 2;
    NIC2[91-02-55-92-FC-36];
  end;
  subgraph Computer 3;
    NIC3[92-02-67-45-7E-8D];
  end;
  NIC1[90-02-00-A3-58-B7]---P1;
  NIC2[91-02-55-92-FC-36]---P2;
  NIC3[92-02-67-45-7E-8D]---P3;
</div>


## IP

## TCP