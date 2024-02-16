---
title: Push Static Web App Project to GitHub
categories: web static-web-app procedure
sort_order: 3
description: Now that we have our code, let's push it to our own GitHub repo.
excerpt: Now that we got our site working locally, we should probably create a Git repository for our source code and push it up to GitHub. We're going to start screwing around with our app and if we mess it all up, we'll want to revert back.
---
{% assign fake_company_name_lower = site.fake_company_name | downcase %}
{% assign infrastructure_repo = '-infrastucture' | prepend: fake_company_name_lower %}
{% assign web_public_repo = '-web-public' | prepend: fake_company_name_lower %}

If you've been following along with the procedures in this service so far, you've created a new [Static Web App resource with Terraform]({% post_url /learn/web/static-web-app/procedures/2024-02-28-swa-terraform %}) and run the static website on your [local computer]({% post_url /learn/web/static-web-app/procedures/2024-02-28-static-web-app-local-dev %}). Now that we got our site working locally, we should probably create a Git repository for our source code and push it up to GitHub. We're going to start screwing around with our app and if we mess it all up, we'll want to revert back.

Here's how this is going to work overall.

- Create the repository locally
- Create a new repository in GitHub
- Make a change to our code and push those changes up to GitHub

We actually have two repos that we'll be doing this with. If you recall, there are two things we're doing here: deploying the Static Web App resource to azure (infrastructure) and deploying the website code that our designer created (application). And since we have two repositories, I can demonstrate two different ways to do this. The hard way with the `git` command and the easy way using VS Code.

## Create a GitHub Repository

The first we're going to do is create a new repository in GitHub. If you've been following the [guided tour]({% link _pages/guided.md %}), you've already created your [infrastructure repository]({% post_url /learn/basics/iac/procedures/2024-02-07-github %}), but if you haven't do that now.

We also need a repo for the static website. Follow the same steps to [create a GitHub repository] as you did for the infrastructure repository, but name it **{{ web_public_repo }}** and leave the **Add .gitignore** option set to `None`.

## Create Local Git Repository

In order to push our local changes up to GitHub, we need to "git-erize" our local repositories. We'll also want to add a *.gitignore* file to exclude some files from being tracked and pushed up to GitHub.

### Initialize Repositories

The first step is to initialize Git on our local project so that we can start tracking changes. In a console or the VS Code terminal, run the following command for both the **{{ infrastructure_repo }}** and **{{ web_public_repo }}** repos.

Run this to initialize your local repository:

``` shell
git init
```

You should see output similar to this:

{% highlight output %}
Initialized empty Git repository in /Users/{{ site.fake_username }}/Projects/{{ fake_company_name_lower }}-web-public/.git
{% endhighlight %}

### Create .gitignore Files

We want to make sure we have [*.gitignore*]({% post_url /learn/web/static-web-app/explainers/2024-02-28-developing-app %}#{{ '.gitignore' | slugify }}) files for each of repos.

For our {{ infrastructure_repo }} folder

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