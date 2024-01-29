---
title: Static Web App
categories: web static-web-app explainer
sort_order: 1
description: What is a Static Web App and why are we using it?
---
Azure has several options for hosting your **web application**. We're going to use an [Azure Static Web App](https://learn.microsoft.com/en-us/azure/static-web-apps/overview) because we just need a simple website without a lot of bells and whistles right now.<!--more--> This post will go over Static Web Apps but also do a quick explainer of why we're picking this one and what other options we'll use down the line.

## What Is a Static Web App?

If you're not an web developer, the concepts of web applications, web services, and websites can be a little squishy. You may have also heard about web APIs and wondered what those are exactly and how they're different from a website.

### HTML Rendering

Even if you're starting out in your IT career, you probably are at least aware that websites are rendered using a language called HTML that looks something like this:

``` html
<html>
    <head>
        <title>{{ site.fake_company_name }}</title>
    </head>
    <body>
        <p>Welcome to {{ site.fake_company_name }}!</p>
    </body>
</html>
```

#### Static vs Dynamic Web Content

When you go to a website, the web server sends that HTML to your web browser. In the very beginning of the world wide web, each web page you visited was just an `.html` file on a web server and that HTML was rendered as a pretty web page in your browser. This type of web content is known as **static** because the HTML that your browser gets is the same as the file that's on the web server.

As you might guess, the opposite of static web content is **dynamic** web content. With dynamic content, the HTML is generated on the fly by the web server. This is common when you 

What is SWA
VS other offerings
Client vs Server side apps
