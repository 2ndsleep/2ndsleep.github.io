---
title: Static Web App
categories: web static-web-app explainer
sort_order: 1
description: What is a Static Web App and why are we using it and why other things?
---
Azure has several options for hosting your **web application**. We're going to use an [Azure Static Web App](https://learn.microsoft.com/en-us/azure/static-web-apps/overview) because we just need a simple website without a lot of bells and whistles right now.<!--more--> This post will go over Static Web Apps but also do a quick explainer of why we're picking this one and what other options we'll use down the line.

## What Is a Static Web App?

An Azure Static Web App is a web hosting service designed for hosting your static web applications. For our example, we'll be deploying the most literal understanding of a static website, which is just a plain old HTML file.

One cool thing about a Static Web App is that it comes with a free API backend using {% include reference.html item='functions' %}. We won't be using the Azure Function part in this deployment, but I want you to know it's there.

If you're not a web developer, terms like "static" and "API" can be confusing, so I tried to untangle it [here]({% post_url /learn/web/static-web-app/explainers/2024-02-01-html-rendering %}).

## Why Use a Static Web App?

Good question. Azure has [several options](#{{ 'What Other Web Solutions Does Azure Have?' | slugify }}) when it comes to hosting web services. We're using a Static Web App for the following reasons.

- It's free as hell!
- It supports HTTPS and we want to look professional here, folks.
- We're not deploying a container, so we need an solution that supports containerless.
- We don't need (that is, we're not willing to pay for) high-availability at this time.
- We're deploying a static website and don't need the complexity of the other offerings (I mean, this one *does* have "static" in the name).

## How Do I Upload My Web Content to This Site?

It doesn't work that way, buddy. This is the year {{ "now" | date: "%Y" }} and we don't upload things anymore. We're going to deploy our code directly from GitHub. It's going to be so much fun!

This is what I like about this workload as the first project in our [guided tour]({% link _pages/guided.md %}): it hits all the highlights of DevOps. We'll be deploying the infrastructure and then deploying our application to it. We'll even make a change to our app and deploy that. Most of our future projects will be infrastructure-only (meaning no applications), so this one is pretty meaty to start out with.

Here's a high-level overview of what we'll be doing:

1. Deploy an Azure Static Web App resource (infrastructure)
1. Push our website code to a new GitHub repository (application)
1. Deploy our application code from GitHub to the Static Web App (CI/CD)
1. Update our application code and redeploy (general DevOps)
1. Add a custom domain for the Static Web App (infrastructure)

You'll notice that we'll deploy the website code after we create the Static Web App resource. So you may be wondering what is on that website before we deploy our app to it. Azure puts up a temporary website that looks something like this:

{% include figure image_path="/assets/images/posts/static-web-app-temp-page.png" caption="This is the default Static Web App site as of 2024. If you're customers see this, they'll know you're an amateur." alt="initial temporary Azure Static Web App website" %}

You may also be wondering what the URL is for this site is. Well, Microsoft makes one up for you as a subdomain of the **azurestaticapps.net**. That's why this example has the silly URL of **witty-pond-0f141550f.4.azurestaticapps.net**. You can't change that, but you can add your own custom domain that you own, which we'll do in step 5. That way we won't have to put "Visit us at witty-pond-0f141550f.4.azurestaticapps.net!" in our email signature.

## What Other Web Solutions Does Azure Have?

Here are the other web services that Azure offers, in case you're interested.

{% include service_comparison_web.html compare=true %}
