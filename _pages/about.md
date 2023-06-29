---
title: 'Why Am I Here?'
permalink: '/about'
layout: 'single'
toc: true
---
This blog is intended to be a repository for learning about Azure, cloud infrastructure, and automation. Azure has a ton of documentation, which is wonderful, but sometimes it feels like it was written for either braindead executives or super-geeks and nothing in between.

For example, here's the expository line describing a feature called [Azure landing zones](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/):

> An Azure landing zone is an environment that follows key design principles across eight design areas. These design principles accommodate all application portfolios and enable application migration, modernization, and innovation at scale.

What the filthy hell does that mean?? Well don't worry, just a few pages into the documentation you get this:

![Landing zone architecture](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/media/ns-arch-expanded.png)

Ah, that clears it up. Okay, so what do I do if I'm not some idiot manager who's looking to impress other idiot managers with more expensive neckties by repeating words like "application portfolios" and "innovation," but I'm not a hyper-nerd who spends their evenings reading RFCs? Where do I go? Just a regular nerd who wants to spend their weekends doing normal people things, like bird-watching or filling their bathtub with butter and rolling around so they can feel the butter between their toes and in their armpits. Normal things.

This blog has two main goals:

- Explain how things actually work
- Show you how to automate your Azure environment

## Blog Organization

Okay, here's how this all works. This site is really just a blog with a posts organized a certain way.

### Services

The main unit of organization is a cloud **service**. This is usually a distinct cloud "thing" that I think is worth learning, like virtual machines. It will usually be a single product but may be a combination of products that work together.

### Posts

Each service's page will have two different types of posts: **explainers** and **procedures**. Explainers tell you how the service works in plain English. You can skip the explainers if you already know the topic pretty well. The procedures show you how to actually deploy the service using a DevOps approach. There's a third type of post that aren't related to any service, but are just my lunatic ramblings.

### Scramoose

<img src="/assets/images/logos/scramoose/scramoose_logo.png" alt="Scramoose logo" />

Each service is part of a bigger fictional company called {{ site.fake_company_name }}. This company is building a website that helps you decide where you want to live. The blog entries progress with the development of this website, so depending on which procedure you choose, you'll see an example for a different point in time in the web development. The goal is to demonstrate the various cloud services which will evolve as {{ site.fake_company_name }} progresses, just like in real life.

## Jump In!

Here's where you can go from here.

### [Start Learning](/guided)

If you're new to the cloud, you'll want to start here. This is a guided tutorial that will step you through the development of {{ site.fake_company_name }}'s website. Each service will build on the previous service.

### [Browse Topics](/browse)

Services are grouped together by topics, so if you're interested in a specific service, you can jump right into that service.

### [Useless Thoughts](/thoughts)

These are vanity posts about whatever I think is important. But important to me, definitely not important to anyone else.

### [All Posts](/posts)

Finally, if you just want to see all the posts in reverse order for whatever freaky reason, you can do that here.
