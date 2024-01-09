---
title: 'About'
permalink: '/about'
layout: 'single'
header:
  overlay_image: /assets/images/pages/second-sleep-banner.png
---
This is a blog to learn Microsoft Azure, cloud infrastructure, and automation. Azure has a ton of documentation, which is wonderful, but sometimes it feels like it was written for either braindead executives or super-geeks and nothing in between.

For example, here's the expository line describing a feature called [Azure landing zones](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/):

> An Azure landing zone is an environment that follows key design principles across eight design areas. These design principles accommodate all application portfolios and enable application migration, modernization, and innovation at scale.

What the filthy hell does that mean?? Well don't worry, just a few paragraphs into the documentation you get this:

{% include figure image_path="https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/media/ns-arch-expanded.png" alt="landing zone architecture" caption="What is this???" %}

Ah, that clears it up. Okay, so what do I do if I'm not some idiot manager who's looking to impress other idiot managers by repeating words like "application portfolios" and "innovation," but I'm not a hyper-nerd who spends their evenings reading RFCs? Where do I go? Just a regular nerd who wants to spend their weekends doing normal people things, like bird-watching or filling their bathtub with butter and rolling around so they can feel the butter between their toes and in their armpits. You know, normal things.

## What Is This?

This is a training site for **Microsoft Azure** and related cloud technologies. This blog has two main goals:

- Explain how things actually work
- Show you how to automate your Azure environment

I'm not trying to rewrite the existing documentation, so you'll see a lot of links to the orginal documentation. But sometimes it needs a little assist, especially if you're coming into it new, and that's what this blog is for.

## Who Am I?

Oh, I'm flattered you asked. My name is Blaine Perry, and I'm just a humble cloud engineer. I've worked for large companies, small companies, startups, non-profits, for-profits, not-for-profits, and sometimes-for-profits. I've used Azure since 2014 and want you to learn the things I've learned and avoid the problems I've encountered. But this site isn't about me, it's about *you* (unless you want to [hire me](/contact), in which case it's definitely about me).

## {{ site.fake_company_name }}

![{{ site.fake_company_name }} logo](/assets/images/logos/scramoose/scramoose_banner.png)

To make this feel somewhat realistic, all the training content on here is part of creating a fictional company called {{ site.fake_company_name }}. {{ site.fake_company_name }} is a hot new startup that will recommend the ideal place you should live based on your preferences. I'll be building the platform infrastructure from scratch to support this fake company.

The blog entries progress with the development of {{ site.fake_company_name }}, so depending on which procedure you choose, you'll see an example for a different point in time in the web development. I have this idea half-baked at the moment, so this project is a bit of an experiment. The goal is to demonstrate the various cloud services which will evolve as {{ site.fake_company_name }} progresses, and you'll see me make mistakes and correct them just like in real life. To see what I'm planning for the evolution of {{ site.fake_company_name }}, see my [roadmap](https://github.com/orgs/2ndsleep/projects/2).

## Blog Organization

Okay, here's how this all works. This site is really just a blog with a posts organized a certain way. If you drop into any training post, you'll see the breadcrumbs structured like this:

```
Learn / Service Category / Service / Post
```

### Services

The main unit of organization is a cloud **service**. This is usually a distinct cloud "thing" that I think is worth learning, like virtual machines. It will usually be a single product but may be a combination of products that work together. Since there will be a lot of services, they will be grouped into broader categories, that I'm rationally calling **service categories**, which you'll see when you drop into the [Learn](/learn) page.

### Posts

Each service's page will have two different types of posts: **explainers** and **procedures**. Explainers tell you how the service works in plain English. You can skip the explainers if you already know the topic pretty well. The procedures show you how to actually deploy the service using a DevOps approach. There's a third type of post that aren't necessarily related to any service, but are just my [lunatic ramblings](/thoughts).

### Guided Tour

The [Learn](/learn) page lists all the service categories, but since I'm building out the fake {{ site.fake_company_name }} infrastructure from scratch, you can follow along in the [Guided Tour](/guided). This will present the services in the order that they would be performed in real life. This is great if you're starting out and want to try to do the same thing at home.

## Jump In!

Ready to get started? [Start learning](/learn) now!