---
title: Push Static Web App Project to GitHub
categories: web static-web-app procedure
sort_order: 3
description: Now that we have our code, let's push it to our own GitHub repo.
---
{% assign fake_company_name_lower = site.fake_company_name | downcase %}

## Set Up Version Control

Now that we got this working, we should probably create a Git repository for our source code and push it up to GitHub. We're going to start messing around with our app and if we mess it all up, we'll want to revert back.

### Create Local Git Repository

The first step is to initialize Git on our local project so that we can start tracking changes.

If you cloned this from my GitHub repo, then it will have all my commit history in it and will point to my repo as a remote. There are two ways handle this. The easiest way is to delete the hidden *.git* folder before you initialize your repo which will blow away anything related to my repo on your local computer. The second option is to run `git remote rm origin`, which will stop pointing to my remote but retain all my commit history.
{: .notice--info}

Run this to initialize your local repository:

``` bash
git init
```

You should see output similar to this:

```
Initialized empty Git repository in /Users/{{ site.fake_username | downcase }}/Projects/{{ fake_company_name_lower }}-web-public/.git
```

### Push to GitHub

## Update App

The point of all this is make changes locally before you push out your changes to GitHub and, subsequently, your Azure Static Web App instance. So let's make some changes to our site and see if we like it.

If you closed VS Code or stopped the local emulator, you can start it up by running the SWA start command again: `./node_modules/.bin/swa start`
{: .notice--info}

Now open the *src/index.html* file in VS Code and change the content as you see fit. For example, maybe you want to solicit investors to our new site, so you add the following on line 12.

``` html
<p>Interested in investing? Email us at bad-decisions@{{ fake_company_name_lower }}.dev.</p>
```

The whole *index.html* file would look like this:

{% highlight html linenos %}
<html>
    <head>
        <title>{{ site.fake_company_name }}</title>
        <link rel="stylesheet" href="/css/main.css" />
    </head>

    <body>
        <img src="/images/{{ fake_company_name_lower }}_banner.png" id="banner" />

        <div id="main-content">
            <p>{{ site.fake_company_name }} is just getting started. Check back later when this becomes the best site on the internet!</p>
            <p>Interested in investing? Email us at bad-decisions@{{ fake_company_name_lower }}.dev.</p>
        </div>

        <footer>This is a demo site inspired by the <a href="https://www.secondsleep.io">Second Sleep</a> project.</footer>
    </body>
</html>
{% endhighlight %}

Now refresh your web browser (or go to `http://localhost:4280` if you closed it), and you'll see your changes! You don't need restart SWA; changes are reflected upon refresh.

{% include figure image_path="/assets/images/posts/static-web-app-update-1.png" caption="Ah, that's better." alt="updated public website" %}

Keep updating until you're satisfied with the site. When you're finished, hit `Ctrl+C` on the terminal to stop the SWA app.