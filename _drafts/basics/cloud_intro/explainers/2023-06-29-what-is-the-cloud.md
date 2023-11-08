---
title: What is the Cloud?
categories: basics cloud_intro explainer
toc: true
sort_order: 0
description: A quick history and answering the question you were afraid to ask
---
If you don't really know what "the cloud" means, don't feel bad. You're not alone. There are a lot of different ways to think of what the cloud is. Kind of like "blockchain" or "AI," it can both be used as a meaningless word by marketing dummies or refer to a very real thing.
<!--more-->

## Brief History

This is the history of the cloud according to Blaine, pulled from my head. Leave a fiery comment if you have any disputes with my version.

### Virtualization

The cloud has its origins in something called **virtualization**. In the old days, companies would build data centers in their office basements with many physical servers running. The best practice was (and still is) for each single server to have a single purpose. So if have a physical server that is a database server, all that server would be is a database server.

If that seems wasteful, well it kind of is, but there are at least two good reasons to only install one workload on a server. You can count on the performance to be a little more consistent. If you have a database and web server installed on the same server and you suddenly get a lot of unexpected web traffic, the CPU might get hit hard serving web content and now your database is getting slow. There is also a security concern. If your web server gets hacked, that hacker probably has access to your database. Separating your workloads on different servers makes it less likely that a hacker can get to all your services.
{: .notice--info}

In the past we'd buy a beefed up physical server that's only doing about 25% of what it's capable of doing. Wouldn't it be great if we could use another 25% for something else? Like that web server that we don't want to put on the database server?

That's where virtualization comes in. Some smart people thought, wouldn't it be great if we could put, like, two servers on that one server? The two servers would be, like "virtual," man (puff, puff, cough, cough :herb:). To achieve this wild idea, the physical server hardware would be virtually broken up for each server.

- **Compute**: The CPU would be shared between each virtual server. In the same way that the processor rapidly switches among each application running on your computer to make it appear that each application is running simultaneously, the processor switches among virtual servers so that they appear to be running at the same time.
- **Memory**: The physical server carves out a section of the physical memory that is exclusive for each virtual server.
- **Storage**: Like memory, the physical server carves out disk space that is exclusive for each virtual server. In its simplest form, the physical server creates a single file on its local disk for each virtual server's hard drive.

From the point of view of each virtual server, it thinks it's getting 100% of everything that's been allocated. So it gets 100% of a virtual processor, 100% of some virtual memory, and 100% of its disk drive. The virtual server doesn't know it's actually just a piece of the physical server. In fact, it doesn't know that it's virtual. It just thinks it's a server.

Yes, this is all grossly oversimplified. Storage is usually located on separate hardware known as a storage area network (SAN). Processors can be allocated directly to virtual servers. The virtual server can be aware that it's virtual. There's also tons of other things, like keyboard/mouse input, network cards, displays, etc. For a little more in-depth on virtualization, see [this video](https://www.youtube.com/watch?v=FZR0rG3HKIk).
{: .notice--info}

Here are all the terms you should use when chatting with technologists so you don't sound like a newbie.

- **Host**: This is the physical server that runs all the virtual servers. If you want to be even more academic, you can call this the **hypervisor**.
- **VM**: I've been using the term "virtual server," but we usually call it a **virtual machine**, or **VM** for short. You may also hear this referred to as the **guest** operating system.

### Infrastructure-as-a-Service

So what does virtualization have to do with the cloud? Well, when people first started experimenting with virtualization in their IT shops, they quickly realized it made their lives much easier. You have to maintain fewer physical servers and can create a new VM with an operating system in a matter of minutes. Before that, you'd need to determine what kind of physical server you needed, get budget approval, and then order a new server. That may take several months, and then you still had to unpack the server and install it in your server room, assuming you even had physical space for the server in the first place.

This changed the game for IT teams, specifically that your IT infrastructure teams were now shifting away from managing hardware to managing software that's pretending to be hardware. We started using the term "hardware" less and the more broad term "**infrastructure**" more. The whole procurement process wasn't as big of a bottleneck and now system administrators could provision servers in more of a service-oriented way. You could say that they now offered **infrastructure as a service**. "Oh the web team needs another web server? Give me a couple of hours."

It's a logical leap that companies would start to exclusively offer infrastructure-as-a-service to the general public. A lot of companies were doing this but there was a big player about to shake things up in the mid-2000s.

### The Big Players

Here's a very brief history of the three biggest public cloud providers.

#### Amazon Web Services

Amazon Web Services (AWS) launches publicly in March 2006 with a storage service called S3. This wasn't exactly virtualization as explained above, but was infrastructure-as-a-service. Anyone could now put any digital objects (aka, "files") in the AWS cloud for a small cost. In August of that same year, AWS released EC2 which was their virtualization product. Now IT teams could ditch their server hardware altogether and create VMs in a remote datacenter.

#### Microsoft Azure

Microsoft copied AWS in 2010.

#### Google Cloud Platform

Google copied AWS in 2008 (although arguably didn't get started in earnest until 2011).

## Where is the Cloud?

Each big cloud provider has multiple datacenters located throughout the world. Each datacenter is one or more buildings that house a *crapload* of physical servers. I'm talking about a *full crapload*! To ensure things keep running, each datacenter usually has multiple power sources, backup cooling systems, redundant internet connections, and is located away from things that are the source of natural disasters like oceans and rivers. In fact, each location is usually made up of multiple datacenters so that if one datacenter happens to go down another one can take over. These cloud providers make their money by making sure your services are running, so they do everything they can to make sure it's always working.

You might be wondering, why a remote datacenter? Don't I want my servers to be close to my business? The answer is: usually no. You generally want all your servers to be close to *each other* but not necessarily close to you. Around the beginning of AWS, businesses started moving more toward web apps (if you were born after 2000, you'd be shocked to know how many things were not web-based). Accessing websites is usually pretty fast, as long as the the services that the website depends on are quickly accessible by the website, such as databases.

## Yeah, But What is the Cloud???

For the purposes of this blog, the cloud is just a company that maintains a bunch of servers where you can run your IT operations. Those IT operations could be VMs that run your custom software, or a place to store your files, a database to keep your HR records, or a combination of any of these things. Basically, almost anything that you've done in a traditional physical IT setting, you can do in a remote cloud datacenter.

The above description is what us geeks think of as the cloud. Now here's the annoying thing. "The cloud" can mean just about anything that involves computers. If you store your iPhone photos in the iCloud, you're using a cloud service. If you use Gmail, you are using Google's cloud email service. Pretty much everything electronic uses the cloud these days. So in a way, you've wasted a lot of time reading this post. But if you look at it another way, you've only wasted a small amount of time reading this post.