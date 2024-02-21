---
title: HTML Rendering
categories: web static-web-app explainer
sort_order: 2
description: HTML can be generated by your web browser or a web server and knowing the difference will affect your infrastructure decisions
---
If you're not a web developer, the concepts of web applications, web services, and websites can be a little squishy. You may have also heard about web APIs and wondered what those are exactly and how they're different from a website.<!--more--> Let's try to make sense of all this.

## Static vs Dynamic Web Content

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

When you go to a website, the web server sends that HTML to your web browser. In the very beginning of the world wide web, each web page you visited was just an *.html* file on a web server and that HTML was rendered as a pretty web page in your browser. This type of web content is known as **static** because the HTML that your browser gets is the same as the file that's on the web server.

As you might guess, the opposite of static web content is **dynamic** web content. With dynamic content, the HTML is generated on the fly by the web server. This is useful when the web page needs to display content that won't be known until you visit the site. A great example is your bank. Your bank balance changes every day, so a static web page won't work in that case. When you log into your bank's portal, it the web server is going to find your current balance and then dynamically generate HTML that will display that balance.

{% include svg.html path="svg/web-static-vs-dynamic.svg" caption="Static vs. dynamic HTML" %}

PHP is a language that can generate dynamic web content. Let's say the *my-balance.html* page of your bank is generated by the following PHP.

``` php
<?php
include 'customer-data.php';
?>

<html>
    <head><title>Your Balance</title></head>
    <body>
        <p>Hello <?php echo get_customer_name(); ?>!</p>
        <p>Your balance is <?php echo get_current_balance(); ?>.</p>
    </body>
</html>
```

In this example, the *customer-data.php* file contains the `get_customer_name` and `get_current_balance` functions that will insert that information into the HTML. All of this happens on the web server when the visitor requests the page, and the final HTML that is generated and sent to the visitor's browser would be:

``` html
<html>
    <head><title>Your Balance</title></head>
    <body>
        <p>Hello {{ site.fake_username | capitalize }}!</p>
        <p>Your balance is $4.85.</p>
    </body>
</html>
```

## Client-Side vs. Server-Side Rendering

Okay, static versus dynamic is fairly straightforward. Static means it's just an HTML file. Dynamic means the HTML is generated by the web server each time the visitor goes to the web page. You may be thinking that a static web page has to be the exact same content every time you visit it. Welp, that's not true because of a little something called JavaScript.

JavaScript is code that is included in the HTML and runs *in the web browser* while or after the HTML is loaded.

``` html
<html>
    <head>
        <title>Current Time</title>
        </head>
    <body>
        <p>Today is <strong id="currentTime" />.</p>
    </body>
    <script>
        document.getElementById('currentTime').innerHTML = Date();
    </script>
</html>
```

The HTML contains the `script` tag at the bottom which writes the current time in the body of the HTML when the page is loaded. Running code in the browser is known as **client-side rendering**. Your web browser is known as the **client**.

{% include svg.html path="svg/web-client-rendering.svg" caption="Client-side rendering within the web browser" %}

On the other hand, **server-side rendering** is conceptually the same as dynamic web content so you can think of them as synonymous.

In this post, JavaScript has been a client-side language and PHP has been a server-side language. However, JavaScript can be run server-side with Node.js. Also, someone [hacked PHP](https://atymic.dev/blog/client-side-php/) to run client-side as a fun experiment (with poor results).
{: .notice--info}

## Static Content with Client-Side Rendering

Okay, here's where it gets tricky. Your website can have *static* content that uses *client-side rendering*. In the JavaScript example above, the JavaScript is just part of the HTML. So that means I can have a static file on my server named *current-time.html* that looks exactly like the HTML in the previous section that will run JavaScript code on the client. So you can have your web server serve up static content and make the user's web browser do all the dynamic rendering.

JavaScript can do magical things including creating HTML tags out of thin air.

``` html
<html>
    <head><title>JavaScript Rendered Content</title></head>
    <body>
        <p>This paragraph is part of the HTML.</p>
    </body>
    <script>
        var newParagraph = document.createElement('p');
        var newParagraphText = document.createTextNode('This was added by JavaScript.');
        newParagraph.appendChild(newParagraphText);
        document.body.appendChild(newParagraph);
    </script>
</html>
```

If you copied that HTML, pasted it into a text editor, saved it as *js-test.html* and double-clicked on the file, it would render something like this in your browser.

<div class="notice--primary" style="font-family: serif;">
    <p>This paragraph is part of the HTML.</p>
    <p>This was added by JavaScript.</p>
</div>

You can take client-side rendering to the extreme and have almost no initial HTML and instead have everything rendered by JavaScript.

{% highlight html linenos %}
<html>
    <head>
        <title>Client-Side Rendered Content</title>
        <script src="js/client-side-render.js"></script>
    </head>
    <body>
        <div id="main" />
    </body>
</html>
{% endhighlight %}

In the example above, we've linked to a JavaScript file on line 4 instead of writing the JavaScript code inline (meaning inside the HTML). That JavaScript file contains a lot of code that will append all the meaningful HTML to the `div` tag on line 7 after the page loads.

This type of client-side rendering is how languages like React, Vue, and Angular work. These are also considered static web content solutions. The point I'm trying to make is that even though we use the word *static* doesn't mean that the final content can't be dynamic.

## Static Site Generators

Static web content can be created by writing plain old HTML files by hand. But if you have a lot of HTML files, you may want something to help you create that content. For instance, if every page you write needs to have a footer with your company's name and contact info, that's going to be a pain in the ass to remember to add that to each file. Worse, if the contact info changes, you have to update each file.

Static site generators are programmatic ways to create all your static content. It's kind of like an assist to writing the HTML files by hand. You can add custom code to do things like add that footer to each file. The static site generator will take all your source code and spit out plain old HTML files.

{% capture jekyll_attribution %}
{% include attribution.html title="Jekyll test tube logo" image_link="https://github.com/jekyll/brand/blob/master/jekyll-test-tube.svg" author="Jekyll" license="Creative Commons Attribution 4.0 International" license_link="https://github.com/jekyll/brand/blob/master/LICENSE" %}
{% endcapture %}
{% include svg.html path="svg/web-static-site-generator.svg" caption="Static site generators can help you create your HTML pages." attribution=jekyll_attribution %}

I want to highlight that this is *not* the same as dynamic content or server-side rendering. The web server is not generating dynamic HTML on the fly. The static site generator creates static HTML and then the web server hosts those static files. The static site generator will create the HTML files either on a schedule, manually, or when you merge code into your main branch.

In fact, this very site is created using a static site generator called [Jekyll](https://jekyllrb.com/).
{: .notice--info}

## APIs

One of the advantages of server-side rendering is that the web server can access your organization's internal APIs. For the bank example, there probably already is an API that is used by the bank tellers' computers and ATMs to lookup customer information. Instead of coding all this same logic into the web server application, it would be much easier to allow the web server to access the existing APIs.

These APIs have traditionally needed to be private since they probably contain sensitive data. Since the web server has access to the private network, the APIs could trust the web server.

{% include svg.html path="svg/web-private-api.svg" caption="Web server calling an API" %}

This is all very critical when users are logging into the web application. In the early days of e-commerce, a user would provide a username and password and the web application running on the web server would authenticate those credentials. Once the user successfully logged on, the web server would query the API for whatever data it needed on behalf of the user. The web server and the APIs all trusted each other because they were controlled by the private organization.

Modern authentication methods like OAuth2 have allowed new patterns to emerge. OAuth2 is it's own conversation that I hope to get to another day, but here's the short and fast of it. When you authenticate with OAuth2, the client web browser receives a token that it can then use to access APIs. And if your application is available on the internet, that means the APIs also have to be available on the internet. And if your APIs are on the internet, that means the client web browser can access them directly, which means you no longer are required to use server-side rendering for that private data. What??!!

{% include svg.html path="svg/web-public-api.svg" caption="Client-side rendering accessing API" %}

This diagram looks so much more complicated than the first one, so why would this be preferred? Well, in larger organizations, you have front-end developers, back-end developers, and designers. When you're using server-side rendering, these roles are kind of all smooshed together. You can get smelly software engineers that create very ugly interfaces or hip designers that don't know how to effectively write code. These two roles will have to collaborate which can cause delays and arguments. This at least moves the back-end developers to their own role. It's easier to find a front-end developer who has design skills than it is to find a full-stack developer. The back-end team can focus on the APIs that provide data and the front-end team can make it look pretty.

Going back to our bank example, if we wanted to use the client-side rendering instead of server-side rendering to populate the data, it would look something like this. The script on line 4 will contain all the logic to call the web API and then populate the *user-name* and *current-balance* elements on lines 7 and 8. (This is a really crude example. React, Vue, Angular, etc., do it much better than this.)

{% highlight html linenos %}
<html>
    <head>
        <title>Your Balance</title>
        <script src="js/bank-stuff.js"></script>
    </head>
    <body>
        <p>Hello <span id="user-name" />!</p>
        <p>Your balance is <span id="current-balance" />.</p>
    </body>
</html>
{% endhighlight %}

Finally, I want to point out that this isn't a one way or the other type of thing. You can use server-side rendering along with client-side rendering, as your architecture may require that.

## What Is the Point of All This?

So why did I write this post? Just for the SEO rankings? Yeah, mainly. But less cynically, I wanted to relay this back to our {% include reference.html item='fake_company' %} project. This post is part of the [Static Web App]({% link _services/web/static-web-app.md %}) service. When I first started poking around Static Web Apps, I noticed that it included an API backend as part of the service. If you're like me, that's confusing because you assume that the "static" part of Static Web App implies that there's no server-side business.

But lo! Azure throws in a free API backend as part of its Static Web App product. That's because they know you might be using this as part of your modern web application architecture since you're a modern woman. Now, that free API backend uses {% include reference.html item='functions' %}, which you may or may not love. If you love not or perhaps even HATE Azure Functions, you can use whatever API you feel like paying for.