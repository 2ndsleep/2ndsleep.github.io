---
title: Static Web App Local Development
categories: web static-web-app procedure
sort_order: 1
description: Before you deploy your website, make sure it looks right by editing it on your local computer.
---
Before we deploy our website to Azure, we want to make sure it looks right. We can do this by developing the app locally on our laptop. As you might guess, this part won't involve Azure at all.<!--more-->

If you're purely a platform infrastructure engineer then this won't be something you do much, if ever, but it's still nice to know what your front-end colleagues are up to, those little pip-squeaks.
{: .notice--info}

## Get Static Website Content

We were desperate so we paid $15 to the first web designer we could find to make a landing page for {% include reference.html item='fake_company' %}. They spent four minutes on it and pushed the content to our [scramoose-web-public](https://github.com/2ndsleep/scramoose-web-public) repository. The version we want was tagged as [web/static-web-app/initial-public-site](https://github.com/2ndsleep/scramoose-web-public/releases/tag/web%2Fstatic-web-app%2Finitial-public-site), and you can download a .zip of the web content by clicking on the button below.

[Download Scramoose Website](https://github.com/2ndsleep/scramoose-web-public/archive/refs/tags/web/static-web-app/initial-public-site.zip){: .btn .btn--info}

Extract this .zip file to a folder where you prefer to do your work. The extracted contents will be a single folder named *scramoose-web-public-web-static-web-app*. Rename that folder to *scramoose-web-public* just to make the name less dumb.

If you're already comfortable with Git, you can also clone this tag by using the following command: `git clone https://github.com/2ndsleep/scramoose-web-public.git --branch web/static-web-app/initial-public-site --single-branch`
{: .notice--info}

## Open Repository in VS Code

Let's look at what we downloaded. I mean, you're about to run this on your local computer so you should take a look to make sure you didn't just download something nasty. And this is the perfect excuse to get your comfortable with VS Code!

1. Launch VS Code.
1. Click **File > Close Workspace**. If you don't see the Close Workspace option, it means you don't have a workspace open and you can move on to the next step.
1. Click **File > Add Folder to Workspace** and navigate to the *scramoose-web-public* folder you downloaded in the previous section. Click on the *scramoose-web-public* folder without going into the folder itself and then click the **Add** button.
1. Click **Yes** if it asks you if you trust this folder. Unless you don't trust it, in which case I'm sorry I haven't gained your trust, although I commend your vigilance!
1. Click **File > Save Workspace As** and then save this workspace as *scramoose-web-public* in a folder of your choosing (I like to create a *workspaces* folder below my home folder).

Now you have a workspace named **scramoose-web-public** that contains the *scramoose-web-public* folder. Start digging around that folder. You find two items worth pointing out:

- The *src* folder contains the actual website. This will be rendered in our testing and eventually deployed to our Static Web App in Azure.
- The *.gitignore* file tells Git that we don't want to check in certain files because they won't be part of our production site.

## Run App Locally

Now that you have the website project added to VS Code, we can run it locally! Microsoft has a page that explains exactly how to [set up your local development environment](https://learn.microsoft.com/en-us/azure/static-web-apps/local-development) so make sure you check it out, but I'm going to streamline the instructions for our purposes.

Here are the basics steps we'll be doing.

1. Install **Node.js** on your computer.
1. Install **static-web-apps-cli (SWA)**, which is a Node.js-based command that will run an Azure Static Web App on your local computer.
1. Configure SWA.
1. Run our website locally using SWA.

All these commands are assumed to be run from a command console (aka, terminal) from within the *scramoose-web-public* folder. One cool thing about VS Code is that it includes a terminal and will drop you automatically into the *scramoose-web-public* folder. If you don't see the terminal when you start VS Code, you can start it by clicking **View > Terminal** or by typing `Ctrl+`` (backtick).

### Install Node.js

Node.js is a runtime environment for JavaScript. You probably think of JavaScript as something that runs on a web browser, but what Node.js does is allow you to use the JavaScript language to create applications that run on a server instead of a browser.

There are two ways to install Node.js. The most official way is to download the installer from the Node.js site. You can also use a package manager which I think is more fun (I stay in most Saturday nights).

[Download Node.js Installer](https://nodejs.org/en){: .btn .btn--info}
[Install Node.js with Package Manager](https://nodejs.org/en/download/package-manager){: .btn .btn--info}

### Install SWA

Run the following command to install the static-web-app-cli Node.js app.

``` bash
npm install -D @azure/static-web-apps-cli
```

Since SWA is installed as a development dependency, you must run the `swa` command from the *node_modules* folder in the steps below, which is different from what is shown in Microsoft's [examples](https://learn.microsoft.com/en-us/azure/static-web-apps/local-development#get-started).
{: .notice--info}

### Configure SWA

SWA must be configured before you can run your app. Luckily, configuration is pretty easy.

Run the following command:

``` bash
./node_modules/.bin/swa init
```

The SWA app will step you through the configuration process.

```
Welcome to Azure Static Web Apps CLI (1.1.6)

? Choose a configuration name: › scramoose-web-public
```

Press `Enter` to accept the default configuration name.

```
Welcome to Azure Static Web Apps CLI (1.1.6)

✔ Choose a configuration name: … scramoose-web-public

Detected configuration for your app:
- Framework(s): Static HTML
- App location: src
- Output location: .
- API location: 
- API language: 
- API version: 
- Data API location: 
- App build command: 
- API build command: 
- App dev server command: 
- App dev server URL: 

- API dev server URL: 

? Are these settings correct? › (Y/n)
```

Press `Enter` again to accept the settings and you're all set! If you're wondering about that output location, this website consists entirely of static content so no build is required. Therefore, there will be no output so the output location will be ignored.

### Run App

Execute the following command to start your app locally.

``` bash
./node_modules/.bin/swa start
```

You'll see the following output warning you that you're running locally and your site may not look exactly like it does in Azure, and that you can access the site at `http://localhost:4280`.

```
Welcome to Azure Static Web Apps CLI (1.1.6)

Using configuration "scramoose-web-public" from file:
  /Users/scramoose/Projects/scramoose-web-public/swa-cli.config.json

***********************************************************************
* WARNING: This emulator may not match the cloud environment exactly. *
* Always deploy and test your app in Azure.                           *
***********************************************************************

[swa] 
[swa] Serving static content:
[swa]   /Users/scramoose/Projects/scramoose-web-public/src
[swa] 
[swa] Azure Static Web Apps emulator started at http://localhost:4280. Press CTRL+C to exit.
[swa] 
[swa] 
```

Type `http://localhost:4280` in your web browser and behold our crappy site!

{% include figure image_path="/assets/images/posts/static-web-app-initial.png" caption="Ah jeez, this is embarrassing." alt="basic public Scramoose site" %}

## Create Git Repository

Now that we got this working, we should probably create a Git repository for our source code. We're going to start messing around with our app and if we mess it all up, we'll want to revert back.

If you cloned this from my GitHub repo, then it will have all my commit history in it and will point to my repo as a remote. There are two ways handle this. The easiest way is to delete the hidden *.git* folder before you initialize your repo which will blow away anything related to my repo on your local computer. The second option is to run `git remote rm origin`, which will stop pointing to my remote but retain all my commit history.
{: .notice--info}

Run this to initialize your local repository:

``` bash
git init
```

You should see output similar to this:

```
Initialized empty Git repository in /Users/scramoose/Projects/scramoose-web-public/.git
```

## Update App

The point of all this is make changes locally before you push out your changes to GitHub and, subsequently, your Azure Static Web App instance. So let's make some changes to our site and see if we like it.

If you closed VS Code or stopped the local emulator, you can start it up by running the SWA start command again: `./node_modules/.bin/swa start`
{: .notice--info}

Now open the *src/index.html* file in VS Code and change the content as you see fit. For example, maybe you want to solicit investors to our new site, so you add the following on line 12.

``` html
<p>Interested in investing? Email us at bad-decisions@scramoose.dev.</p>
```

The whole *index.html* file would look like this:

{% highlight html linenos %}
<html>
    <head>
        <title>Scramoose</title>
        <link rel="stylesheet" href="/css/main.css" />
    </head>

    <body>
        <img src="/images/scramoose_banner.png" id="banner" />

        <div id="main-content">
            <p>Scramoose is just getting started. Check back later when this becomes the best site on the internet!</p>
            <p>Interested in investing? Email us at bad-decisions@scramoose.dev.</p>
        </div>

        <footer>This is a demo site inspired by the <a href="https://www.secondsleep.io">Second Sleep</a> project.</footer>
    </body>
</html>
{% endhighlight %}

Now refresh your web browser (or go to `http://localhost:4280` if you closed it), and you'll see your changes! You don't need restart SWA; changes are reflected upon refresh.

{% include figure image_path="/assets/images/posts/static-web-app-update-1.png" caption="Ah, that's better." alt="updated public Scramoose site" %}

Keep updating until you're satisfied with the site. When you're finished, hit `Ctrl+C` on the terminal to stop the SWA app.