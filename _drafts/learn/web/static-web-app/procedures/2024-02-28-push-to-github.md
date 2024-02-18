---
title: Push Static Web App Project to GitHub
categories: web static-web-app procedure
sort_order: 4
description: Now that we have our starter code, let's push it to our own GitHub repo.
excerpt: Now that we've made some changes, we should push those changes up to GitHub in case our laptop craps out. We're also going to start screwing around with our app and if we mess it all up, we'll want to revert back.
---
{% assign fake_company_name_lower = site.fake_company_name | downcase %}
{% assign infrastructure_repo = '-infrastucture' | prepend: fake_company_name_lower %}
{% assign web_public_repo = '-web-public' | prepend: fake_company_name_lower %}

If you've been following along with the procedures in this service so far, you've done the following:

- [Created your GitHub repositories]({% post_url /learn/web/static-web-app/procedures/2024-02-28-configure-dev-environment %}) and cloned them to your local computer
- Created a new [Static Web App resource with Terraform]({% post_url /learn/web/static-web-app/procedures/2024-02-28-swa-terraform %})
- Run the static website on your [local computer]({% post_url /learn/web/static-web-app/procedures/2024-02-28-static-web-app-local-dev %}).

Now that we've made some changes, we should push those changes up to GitHub in case our laptop craps out. We're also going to start screwing around with our app and if we mess it all up, we'll want to revert back.

## Push Changes to GitHub

Just like when we [configured our repositories]({% post_url /learn/web/static-web-app/procedures/2024-02-28-configure-dev-environment %}), there are two ways to push our changes back up to GitHub: the `git` command or using the VS Code interface. We'll push our changes with the command line for the {{ infrastructure_repo }} repo and do it the VS Code way for our {{ web_public_repo }} repo.

There's actually a couple of steps before we can push changes into GitHub. Git doesn't actually know about our changes so we need to **stage** the files we want to add to our repository. After a file has been staged, it can be **committed** where we officially add it to the repository with a message about what the file is about (or what changes were made if the file already exists).

### Command Line ({{ infrastructure_repo }})

Before you start this, you should see that the source control icon in VS Code will show that some files have not been committed. Even though we're using the command line, click on the source control icon so you can see how our changes will be detected by VS Code.

Start VS Code, open any file from the {{ infrastructure_repo }} folder, and then open the terminal. This should put you in the *{{ infrastructure_repo }}* folder, but if not, `cd` into that folder.

Type the following command to see what Git says the current status is.

``` shell
git status
```

You should see something like this:

{% highlight output %}
On branch main
Your branch is up to date with 'origin/main'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        terraform/

nothing added to commit but untracked files present (use "git add" to track)
{% endhighlight %}

Git is saying that we have some new files that it sees, but haven't been staged. Run the following command to stage the all these files.

``` shell
git add *
```

You won't see any output, but you'll notice that the source control extension in VS Code now shows these files as staged. Let's check the status again and see what Git says.

``` shell
git status
```

Git will tell us that it's now "aware" of these files and they can be committed.

{% highlight output %}
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   terraform/public-web-site-swa/.terraform.lock.hcl
        new file:   terraform/public-web-site-swa/base.tf
        new file:   terraform/public-web-site-swa/main.tf
{% endhighlight %}

Now let's commit these files to our repository with a message.

``` shell
git commit * -m "Add Static Web App resource"
```

There's a chance you get this output:

{% highlight output %}
Author identity unknown

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.
{% endhighlight %}

If you get this and it's your first time using Git, this is expected. Git wants to know who you are so that your team knows who did what. If you did get this, run the commands just like it said.

``` shell
git config --global user.email "{{ site.fake_username }}@{{ site.fake_company_domain }}"
git config --global user.name "{{ site.fake_username | capitalize }}"
```

Now that we're past that, run the same commit message again. If you didn't have that problem, skip to the output.

``` shell
git commit * -m "Add Static Web App resource"
```

Git tells us that we successfully committed our changes.

{% highlight output %}
[main 7477bd6] Add Static Web App resource
 3 files changed, 46 insertions(+)
 create mode 100644 terraform/public-web-site-swa/.terraform.lock.hcl
 create mode 100644 terraform/public-web-site-swa/base.tf
 create mode 100644 terraform/public-web-site-swa/main.tf
{% endhighlight %}

Now the source control extension in VS Code shows that everything is good and that you commits that need to pushed to GitHub, that should also be confirmed when we check the status.

``` shell
git status
```

{% highlight output %}
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
{% endhighlight %}

Yup, `git status` is telling us that our local repository has newer commits than the repository on GitHub and suggest we run `git push`. Great idea! Let's push our changes up to GitHub.

``` shell
git push
```

{% highlight output %}
Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
Delta compression using up to 2 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (7/7), 1.41 KiB | 1.41 MiB/s, done.
Total 7 (delta 1), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To https://github.com/2ndsleep/{{ infrastructure_repo }}.git
   f3d9098..7477bd6  main -> main
{% endhighlight %}

We did it! The source control extension in VS Code should also show that there's nothing to push. Let's run one more `git status` to see what it says.

``` shell
git status
```

{% highlight output %}
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
{% endhighlight %}

That's what I like to see!

### VS Code ({{ web_public_repo }})

Now let's do it the easy way with our {{ web_public_repo }} repository. Open VS Code and click on the Source Control icon. You should see 5 files under the **Changes** header that need to be added to our repo. Each file should have a green letter **U** next to it (this stands for **untracked** in Git parlance).

If you move your mouse slightly to the left of one of those U letters, you'll see a **+** sign. You can click on that for all of the files or to make it easier, click on the + sign in the **Changes** header to add all 5 files. The status should change from **Changes** to **Staged Changes**. This is the same as typing `git add *`.

Now we want to commit our changes, so type the following message into the message bar above the files: `Add initial web content`. Click the **Commit** button. This is the same as typing `git commit * -m "Add initial web content"`.

Okay, you've committed everything locally. Now you should see a button that says **Sync Changes 1 ⬆**. Click that button to push your changes to GitHub.

Yeah, that's a lot easier. Despite that, I find myself frequently using the command lines just to stay sharp. I like to know what I'm doing and if you do it a lot it's almost as fast as using the visual interface.

## Update App

If you recall, we hired a very inexpensive web designer who through something together as quickly as they could, and possibly while drunk. What they gave us had a ton of typos, so we need to fix that.

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