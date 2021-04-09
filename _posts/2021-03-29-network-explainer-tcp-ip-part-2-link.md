---
title: TCP/IP Explainer Part 2 (Ethernet)
category: explainer
service: Networking
toc: true
---
The most basic part of TCP/IP networking is the Link Layer (AKA, Ethernet). This is how two network devices talk directly to each other.

{% assign mac1 = 'A2-63-00-A3-58-B7' %}
{% assign mac2 = 'C2-8E-55-92-FC-36' %}
{% assign mac3 = '12-DD-67-45-7E-8D' %}

# Link Layer (Ethernet)

If you've heard about IP and TCP and you know a little bit about that, get that out of your mind right now. It's only going to be confusing. You'll understand this better if you clear your head and forget that IP exists for the moment.

Ethernet is a way for computers to communicate with each other on a network. Ethernet doesn't really have a clear definition. It's like pornography: you'll know it when you see it. (Unlike pornography, you can Google the word "Ethernet" at work. And depending on where you work, you can Google pornography at work.) All I can say for sure is that it operates on the Link layer.

## An Irresponsibly Simple Analogy

Before we move forward, I'm going to offer an absurdly over-simplified analgoy for how Ethernet works. It gets more confusing later on so hopefully this will help you picture it easily.

Let's pretend that it's 1987, the internet doesn't exist, and you're just hooking a bunch of computers together in your living room for shits and giggles. And let's pretend that each computer is assigned a unique identifying number. So in our scenario, we've got four computers. The ID number for the first one is `1` and the ID number for the fourth one is `4`. (At this point, if you don't understand my numbering system, then yes, you *are* kind of dumb and maybe you should think about pursuing a management career path instead.)

{% include svg.html path="svg/network-simple-link-layer.svg" %}

> **Once again, pretend IP doesn't exist. This will make less sense if you know a bit about IP and you're trying to shoehorn that knowledge into this made-up scenario.**

Okay to recap, we've got four computers each numbered 1 through 4. Ethernet basically works by sending chunks of data from one computer to another computer and putting the "to" and "from" ID numbers at the beginning of the chunk. If computer 1 wants to send something a chunk of data to computer 4, it will send a chunk of data that looks something like this.

{% include svg.html path="svg/network-simple-link-layer-to-from.svg" %}

The switch in the middle will know which physical port computer 4 is connected to and send the data to computer 4. Easy, right? Wrong, it's much more complicated than that! But hopefully this helps you get into the correct headspace. By the way, the computer IDs aren't really computer IDs. They are NIC identifiers called MAC addresses...


## MAC Addresses

Each physical network device has something called a MAC address associated with it. MAC stands for *media access control* and does not refer to Apple Macintosh computers (this is actually a common misconception for people learning this stuff). In the old days, this MAC address was burned-in to the network card and couldn't be changed. Also, it was guaranteed to be unique. This isn't really the case anymore, but let's pretend that's the situation because it makes understanding this much easier, and it's more or less how it still works these days.

A MAC address is a hexadecimal value that looks something like this: `{{ mac1 }}`. As I said, each network adapter has one MAC address assigned to it. If we made the world's smallest network and connected two computers together with an Ethernet cable, these two computers could talk to each other directly by sending data to each other's MAC addresses. They wouldn't even need to use IP addresses!

{% include svg.html path="svg/network-link-layer-2-computer.svg" %}

## Data Frames

Okay, first of all, let's settle on some terms. I'm going to mix up the language used in different models, so sorry about that. We're going to call the units of data transmitted on the Link Layer to be known as Ethernet *frames*.

An Ethernet frame is a chunk of data that's sent from one network adapter, transmitted over a cable, and then received by another network adapter. This data is a bunch of 1's & 0's but it is ordered in a way that each network adapter can understand it. The sequence of the data on a frame is thusly:

{% include svg.html path="svg/network-link-layer-frame.svg" %}

The diagram above means that when one computer transit a frame of data, it will transfer a bunch of 1's & 0's representing the preamble first, then 1's & 0's respresenting the MAC destination, etc. The receiving computer will receive the data in the same order, beginning with the preamble. Most of this isn't that imporant (unless you're dealing with VLANs, which I'm totally ignoring in this post), so let's focus on the three things that are worth talking about.

- **MAC Destination**: This is the MAC address of the network adapter that this frame is going to. When a network adapter wants to send a frame to another network adapter, it puts the MAC address of that other network adapter here.
- **MAC Source**: This is the MAC address of the network adapter that sent this frame. If this is the network adapter that's sending this frame, it's going to put its own MAC address here.
- **Payload**: This is the actual data we're sending. So if one computer is sending a video of a cat to another computer, this video data will be sent in the payload. This deserves a little more nuanced explanation here.
  - Not the entire cat video will be sent. As you can probably guess, data is broken up into smaller chunks and sent in pieces. So the payload of this frame will be one part of the cat video, like a whisker.
  - The payload won't just contain the cat video data, it will contain information about the Internet Layer, i.e., IP addresses. But don't get too hung up on that. The point is, each layer will contain a payload that may or may not have information inside it for the next layer, but the current layer doesn't care. The network adapter just knows that it's going to unpack the payload from the frame and send it on to the next layer. This concept is known as *encapsulation* if you're reading a textbook.

How does a network adapter know the MAC address of another network adapter? We'll get to that later in this section, but for now, let's just assume that the computers already know the MAC addresses of all the other computers it wants to talk to. In fact, you may be wondering, why do we need IP addresses if we have MAC addresses? Well, the truth is, we don't. If we had just a few computers networked together, MAC addresses would be sufficient and we could conceivably skip IP addresses altogether. But once we get outside of our little network, we're going to need more than just MAC addresses, as we'll see.

# Switching

The end of the last section gave you a preview of what IP addresses do, but let's go back to pretending they don't exist. We're going to keep our network small but make it bigger than two computers. If we want to have three or more computers talk to each other, we'll need to put some kind of network device to connect them all. We'll need to use something called a *switch*. (If you're old like me, you'll be familiar with something called a *hub*. They look like switches, but they are very anitquated, and slow as dick for reasons that will make sense if you study for the Network+ exam. I don't even know where you'd buy a hub anymore. If you're still using a hub in a professional environment, then may God have mercy on your soul.)

{% include svg.html path="svg/network-link-layer-computers-switch.svg" %}

A switch is a device that has multiple physical ports. For the sake of argument, let's say this is the rare 3-port switch and it looks like this.

{% include svg.html path="svg/network-link-layer-switch.svg" %}

So let's show the switch ports that each computer is plugged into.

{% include svg.html path="svg/network-link-layer-computers-switch-numbered.svg" %}

To be clear, the ports on the right are the physical ports of the switch. Like, the jacks on the port that you'd plug an Ethernet cable into so that it makes a click sound. Since each switch port is plugged into a network adapter on a computer, you've got that computer's netwok adapter MAC address associated with each switch port. The switch keeps track of which MAC address is associated with each port in its MAC address table.

Let's say this switch has been running for a while and computer 1 and computer 2 have been chatting with each other. The switch has figured out the MAC addresses of these computers by now and has recorded it into the MAC address table.

|Port|MAC Address|
|----|-----------|
|1|{{ mac1 }}|
|2|{{ mac2 }}|
|3|dunno|

So when computer 1 sends a packet to computer 2, it generates an Ethernet frame with a source MAC address of `{{ mac1 }}` and destintion MAC address of `{{ mac2 }}`. Computer 1 puts the frame on the Ethernet cable and then, bleep, bloop, bleep, the signal travels down the wire and arrives at port 1 of the switch. The switch reads the frame, inspects the destination MAC address, and looks up the destination MAC address from the table. It sees that `{{ mac2 }}` is connected to port 2 and then bloop, bleep, bloop, it sends the signal over the Ethernet cable plugged into port 2 and onto computer 2.

Great, pretty easy, right? The switch simply checks the destination MAC address of all incoming frames, looks up that MAC address from its MAC address table, and then sends it to the associated port. But how does the switch know which MAC address is associated with which port? Pretty simple, actually. Everytime the switch receives a frame, it records in its MAC address table the source MAC address of the incoming frame.

So let's say computer 3 wants to send a cat video to computer 2. First, let's just assume that computer 3 already knows the MAC address of computer 2 (don't worry how it knows yet). Computer 3 generates an Ethernet frame with a source MAC address of `{{ mac3 }}` and a destination MAC address of `{{ mac2 }}` and sends it over the wire. The switch receives the frame on port 3 and says, "hey, I don't know balls about port 3 - I should remember this!" So it inspects the source MAC address and records it in its MAC address table, like this:

|Port|MAC Address|
|----|-----------|
|1|{{ mac1 }}|
|2|{{ mac2 }}|
|3|{{ mac3 }}|

Now the next time either of the other computers wants to send something to computer 3, the switch knows to send it via port 3.

One more little thing to button up here. What if the switch receives a frame and doesn't know the destination MAC address? How will it know which port to send it? Easy, it *floods* all the ports of the switch with a copy of the frame. The way Ethernet works is that each network adapter checks to see if the destination MAC address of the frame it receives matches its own MAC address. If it's a match, it accepts the frame. If not, it discards the frame.

Now that you know everything you need to know (that is, you have the absolute least functional knowledge about Ethernet), let's demo what happens when you plug these three computers into that switch and turn it on. Before any computer sends any frames, the MAC address table looks like this:

|Port|MAC Address|
|----|-----------|
|1|dunno|
|2|dunno|
|3|dunno|

**Computer 1 Sends to Computer 2**
