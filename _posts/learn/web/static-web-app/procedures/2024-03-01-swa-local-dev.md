---
title: Static Web App Local Development
categories: web static-web-app procedure
sort_order: 3
description: Before you deploy your website, make sure it looks right by editing it on your local computer.
---
Before we deploy our website to Azure, we want to make sure it looks right. We can do this by developing the app locally on our laptop. As you might guess, this part won't involve Azure at all.<!--more-->

If you're purely a platform infrastructure engineer then this won't be something you do much, if ever, but it's still nice to know what your front-end developer friends are up to. Those little pip-squeaks.
{: .notice--info}

## Get Static Website Content

We were desperate so we paid $15 to the first web designer we could find to make a landing page for {% include reference.html item='fake_company' %}. They spent four minutes on it and then emailed a .zip of it to us. You can download a .zip of the web content by clicking on the button below.

[Download {{ site.data.fake.company_name }} Website](https://github.com/2ndsleep/{{ site.data.fake.web_public_repo }}/archive/refs/tags/web/static-web-app/designer.zip){: .btn .btn--info}

Extract this .zip file to a temporary location and then copy the files to the *{{ site.data.fake.web_public_repo }}* repository on your local computer that you cloned in the [first post]({% post_url /learn/web/static-web-app/procedures/2024-02-28-swa-terraform %}) of this project.

Now open VS Code and check the *{{ site.data.fake.web_public_repo }}* folder. Start digging around that folder and you'll find the *src* folder contains the actual website. This will be rendered in our local testing and eventually deployed to our Static Web App in Azure.

{% include figure image_path="/assets/images/posts/vscode-web-public-contents.png" caption="VS Code Explorer view after adding website contents" alt="VS Code Explorer view after adding website contents" %}

## Run App Locally

Now that you have the website project added to VS Code, we can run it locally. Microsoft has a page that explains exactly how to [set up your local development environment](https://learn.microsoft.com/en-us/azure/static-web-apps/local-development) so make sure you check it out, but I'm going to streamline the instructions for our purposes.

Here are the basics steps we'll be doing.

1. Install **Node.js** on your computer.
1. Install **static-web-apps-cli (SWA)**, which is a Node.js-based command that will run an Azure Static Web App on your local computer.
1. Configure SWA.
1. Run our website locally using SWA.

### Install Node.js

Node.js is a runtime environment for JavaScript. You probably think of JavaScript as something that runs on a web browser, but what Node.js does is allow you to use the JavaScript language to create applications that run on a server instead of a browser.

There are two ways to install Node.js. The most official way is to download the installer from the Node.js site. You can also use a package manager which I think is more fun (I stay in most Saturday nights).

[Download Node.js Installer](https://nodejs.org/en){: .btn .btn--info}
[Install Node.js with Package Manager](https://nodejs.org/en/download/package-manager){: .btn .btn--info}

### Create .gitignore File

We're about to add a bunch of files to our repository that will be used for running the app locally. However, we don't need these files for production, so we don't want to add them to our repo. We just want them to stay on our local computer, so we need to create a [*.gitignore*]({% post_url /learn/web/static-web-app/explainers/2024-02-28-developing-app %}#{{ '.gitignore' | slugify }}) to exclude all these files.

Right-click on the root of the **{{ site.data.fake.web_public_repo }}** folder in VS Code and select **New File**, name it *.gitignore* (yes, the file starts with a `.`), add the following text, and then save the file.

```
node_modules
package-lock.json
package.json
swa-cli.config.json
```

### Open Terminal in {{ site.data.fake.web_public_repo }} Folder

If you were following along in the [last post]({% post_url /learn/web/static-web-app/procedures/2024-02-28-swa-terraform %}), you had the VS Code terminal open in the {{ site.data.fake.infrastructure_repo }}. We need to switch over to the *{{ site.data.fake.web_public_repo }}* folder now since we're working on the actual web content. You have a few options to do that.

- Type `cd ~/Projects/{{ site.data.fake.web_public_repo }}` in the terminal.
- Delete the current terminal by clicking the teeny, tiny trash can icon at the top of your terminal and opening a new terminal in the *{{ site.data.fake.web_public_repo }}* folder by right-clicking on the **{{ site.data.fake.web_public_repo }}** root folder in the VS Code Explorer view and then clicking **Open in Integrated Terminal**.
- Starting a second terminal by...
  - right-clicking on the **{{ site.data.fake.web_public_repo }}** root folder in the VS Code Explorer view and then clicking **Open in Integrated Terminal**.
  - clicking on the teeny, tiny plus sign at the top of your current terminal and selecting **{{ site.data.fake.web_public_repo }}** from the dropdown which will create a new terminal starting in the *{{ site.data.fake.web_public_repo }}* folder.

Our engineer {% include reference.html item='fake_company' anchor_text=site.data.fake.engineer_name %} likes the last option because she can then switch back to the {{ site.data.fake.infrastructure_repo }} terminal if she needs to.

{% include figure image_path="/assets/images/posts/vscode-new-terminal.png" caption="Wow, two terminals!" alt="second terminal in VS Code" %}

### Install SWA

Double-check that your terminal is in the *{{ site.data.fake.web_public_repo }}* folder and run the following command to install the static-web-app-cli Node.js app.

``` bash
npm install -D @azure/static-web-apps-cli
```

Since SWA is installed as a [development dependency]({% post_url /learn/web/static-web-app/explainers/2024-02-28-developing-app %}#{{ 'Node Dependencies' | slugify }}), you must run the `swa` command from the *node_modules* folder in the steps below, which is different from what is shown in Microsoft's [examples](https://learn.microsoft.com/en-us/azure/static-web-apps/local-development#get-started).
{: .notice--info}

{% include figure image_path="/assets/images/posts/vscode-install-swa-cli.png" caption="Your VS Code instance should look like this after installing the SWA CLI. Notice that all of the files related to our NPM packages have been added to *.gitignore* and are therefore greyed out." alt="VS Code after install the SWA CLI" %}

### Configure SWA

SWA must be configured before you can run your app. Luckily, configuration is pretty easy.

Run the following command:

``` bash
./node_modules/.bin/swa init
```

The SWA app will step you through the configuration process.

```
Welcome to Azure Static Web Apps CLI (1.1.6)

? Choose a configuration name: › {{ site.data.fake.web_public_repo }}
```

Press `Enter` to accept the default configuration name.

```
Welcome to Azure Static Web Apps CLI (1.1.6)

✔ Choose a configuration name: … {{ site.data.fake.web_public_repo }}

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

Using configuration "{{ site.data.fake.web_public_repo }}" from file:
  /Users/{{ site.data.fake.engineer_username }}/Projects/{{ site.data.fake.web_public_repo }}/swa-cli.config.json

***********************************************************************
* WARNING: This emulator may not match the cloud environment exactly. *
* Always deploy and test your app in Azure.                           *
***********************************************************************

[swa] 
[swa] Serving static content:
[swa]   /Users/{{ site.data.fake.engineer_username }}/Projects/{{ site.data.fake.web_public_repo }}/src
[swa] 
[swa] Azure Static Web Apps emulator started at http://localhost:4280. Press CTRL+C to exit.
[swa] 
[swa] 
```

Type `http://localhost:4280` in your web browser and behold our crappy site!

{% include figure image_path="/assets/images/posts/swa-local-test.png" caption="Ah jeez, this is embarrassing." alt="basic public site" %}

## Fix Typos

As you recall, we hired a very inexpensive web designer who threw something together as quickly as they could, and possibly while drunk. What they gave us had a ton of typos, so we need to fix that.

If you closed VS Code or stopped the local emulator, you can start it up by running the SWA start command again: `./node_modules/.bin/swa start`
{: .notice--info}

Make the following changes to line 11 of *index.html* and save the file.

{% highlight html linenos %}
            <p>{{ site.data.fake.company_name }} is just getting started. Check back later when this becomes the best site on the internet!</p>
{% endhighlight %}

The whole *index.html* file should look like this:

{% highlight html linenos %}
<html>
    <head>
        <title>{{ site.data.fake.company_name }}</title>
        <link rel="stylesheet" href="/css/main.css" />
    </head>

    <body>
        <img src="/images/{{ site.data.fake.company_name | downcase }}_banner.png" id="banner" />

        <div id="main-content">
            <p>{{ site.data.fake.company_name }} is just getting started. Check back later when this becomes the best site on the internet!</p>
        </div>

        <footer>This is a demo site inspired by the <a href="https://www.secondsleep.io">Second Sleep</a> project.</footer>
    </body>
</html>
{% endhighlight %}

Now refresh the page (or navigate to `http://localhost:4280` if you closed the browser) and see your changes!

Notice how you don't need to rebuild anything or restart the SWA CLI. Since this is static HTML, the changes are immediately reflected.
{: .notice--info}

{% include figure image_path="/assets/images/posts/swa-local-changes.png" caption="Still embarrassing, but less so." alt="basic public site with typos fixed" %}

## Next Steps

As discussed, we'll be deploying this to code to our Static Web App from GitHub, so in the [next post]({% post_url /learn/web/static-web-app/procedures/2024-03-01-push-to-github %}) we'll push our code to GitHub.