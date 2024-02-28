---
title: Update Static Web App
categories: web static-web-app procedure
sort_order: 6
description: We need to make some changes to our web app.
---
{{ site.data.fake.ceo_name }}, the CEO of {% include reference.html item='fake_company' %} and a real ideas guy (trust fund kid), had the brilliant notion of trying to solicit investors in the company, even though we don't have a product yet. But hey, why should the lack of a product [stop entrepreneurship](https://www.alexanderjarvis.com/25-startups-that-raised-without-a-product/)? He's asked that we add an email address where people can inquire about investing. So sure, let's do that.<!--more-->

## Make Changes Locally

First thing's first, let's make this change to our website locally and test it. Fire up VS Code and open the terminal into the *{{ site.data.fake.web_public_repo }}* folder.

### Create New Branch

When we [pushed our changes to our GitHub repos]({% post_url /learn/web/static-web-app/procedures/2024-03-01-push-to-github %}), we pushed directly to our main branch. Well, that's not exactly the best way to go about it. A more appropriate way would be to create a branch for all your changes, and then create a pull request for that branch when the changes are ready.

I'm going to show you how to do this on the command line. When we make changes to our Terraform configuration in our next project, I'll show you to do this in VS Code.

Run the following command in your terminal to create a new branch named **{{ site.data.web.static_web_app_basic.update_branch_name }}** and switch to that branch.

``` shell
git checkout -b {{ site.data.web.static_web_app_basic.update_branch_name }}
```

{% include figure image_path="/assets/images/posts/vscode-webpublicrepo-create-branch.png" caption="After a few seconds, you'll see that VS Code has detected you're on a new branch in the lower-left corner." alt="VS Code create new Git branch" %}

### Update Static Web Content

If you need a refresher on testing locally, see the [Static Web App Local Development]({% post_url /learn/web/static-web-app/procedures/2024-03-01-swa-local-dev %}) post.
{: .notice--info}

Run the following command to start up the Static Web App emulator on your local computer.

``` shell
./node_modules/.bin/swa start
```

Now open the *src/index.html* file in VS Code and add the following on line 12.

``` html
<p>Interested in investing? Email us at bad-decisions@{{ site.data.fake.company_domain }}.</p>
```

The whole *index.html* file would look like this:

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
            <p>Interested in investing? Email us at bad-decisions@{{ fake_company_domain }}.</p>
        </div>

        <footer>This is a demo site inspired by the <a href="https://www.secondsleep.io">Second Sleep</a> project.</footer>
    </body>
</html>
{% endhighlight %}

Now refresh your web browser (or go to `http://localhost:4280` if you closed it), and you'll see your changes.

{% include figure image_path="/assets/images/posts/static-web-app-update-1-solicit-investors.png" caption="Great idea, boss!" alt="updated public website" %}

## Create Pull Request

Once things are looking good locally, it's time to create a pull request.

### Commit & Push Changes

First, let's add and commit our changes. When I showed you this last time, we did it in two steps, but let's do it all at once using the `commit -a` command.

``` shell
git commit -a -m "Add investor solicitation"
```

Very good. Now push the changes up to GitHub.

``` shell
git push
```

Hmmm... you probably got an error message like this.

{% highlight output %}
fatal: The current branch {{ site.data.web.static_web_app_basic.update_branch_name }} has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin {{ site.data.web.static_web_app_basic.update_branch_name }}
{% endhighlight %}

Git is telling you that it doesn't know what you want to call the branch when you push it up to GitHub. You'd think it would just call it **{{ site.data.web.static_web_app_basic.update_branch_name }}**, but Git doesn't like to make assumptions. Run the command it's recommending.

``` shell
git push --set-upstream origin {{ site.data.web.static_web_app_basic.update_branch_name }}
```

If it worked, you'll see output like this:

{% highlight output %}
...
remote: Create a pull request for '{{ site.data.web.static_web_app_basic.update_branch_name }}' on GitHub by visiting:
remote:      https://github.com/{{ site.data.fake.engineer_github_account }}/{{ site.data.fake.web_public_repo }}/pull/new/{{ site.data.web.static_web_app_basic.update_branch_name }}
remote: 
To https://github.com/{{ site.data.fake.engineer_github_account }}/{{ site.data.fake.web_public_repo }}.git
 * [new branch]      {{ site.data.web.static_web_app_basic.update_branch_name }} -> {{ site.data.web.static_web_app_basic.update_branch_name }}
Branch '{{ site.data.web.static_web_app_basic.update_branch_name }}' set up to track remote branch '{{ site.data.web.static_web_app_basic.update_branch_name }}' from 'origin'.
{% endhighlight %}

By the way, now that you set the upstream remote branch, you only have to run `git push` for any further changes you want to push on this branch.
{: .notice--info}

### Create Pull Request in GitHub

Now on to the actual pull request (PR).

1. Go to your {{ site.data.fake.web_public_repo }} repo in GitHub. You should see a banner in your repo that looks kind of like the image below. ![GitHub "Compare & pull request" banner](https://docs.github.com/assets/cb-34106/mw-1440/images/help/pull_requests/pull-request-compare-pull-request.webp) If you see that banner, click on the button. If not, follow GitHub's instructions for [creating a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).
1. Type a title and description in the next page. The description supports [Markdown](https://www.markdownguide.org/). If you don't want to think about, you can use this:
  - **Title:** `Add Investor Solicitation`
  - **Description:** `Our stupid CEO wanted us to add this stupid text because he's stupid. Luckily he'll never read this because he's stupid.`
1. Click the **Create pull request** button.

This will take you to the PR page where you'll see the description at the top and some checks that should be running. **Don't click the Merge button yet!** You've just done something cool and I want you to appreciate it.

![GitHub PR running checks](/assets/images/posts/github-pr-checks.png)

One of the checks that ran was our GitHub Actions workflow. At the top of our workflow YAML we have these lines:

``` yaml
on:
  push:
    branches: [ "main" ]
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [ "main" ]
```

The `push:` part says to run the workflow when we merge with the main branch, which we already did once back when we initially [deployed our app]({% post_url /learn/web/static-web-app/procedures/2024-03-04-github-actions  %}) and which we'll do when we complete the PR later in this post. But the `pull_request:` part says to run the workflow when we create a PR, which is what we just did.

Note that the `branches: [ "main" ]` line means that this won't happen for just any PR but only PRs that will be merged into the main branch. As you start progressing more, you may create a branch from another branch and this workflow won't run for a branch that is merged into a non-main branch. 
{: .notice--info}

{% include figure image_path="/assets/images/posts/github-actions-pr-workflow.png" caption="You can navigate to the GitHub Actions workflow that ran for the PR from either the **Details** button on the PR page or by going to the **Actions** tab for your repo." alt="GitHub Actions PR workflow" %}

The workflow that kicked off when we created the PR will create a new preview environment in our Static Web App and deploy the code in the PR to the preview environment.

1. Go to the **{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1** resource in the [Azure portal](https://portal.azure.com).
1. Click on the **Environments** blade.
1. You'll see your PR listed under the **Preview environments** section. Click on the **Browse** button to open our changes in a browser. You can send this link to your stakeholders to make sure they approve of the changes that are about to be made.<br />![Static Web App environment preview](/assets/images/posts/portal-swa-environment-preview.png)

You'll also see this link on the PR page in GitHub if you wait long enough to let the workflow finish whereupon the github-actions bot will leave a comment with a link to the preview URL. ![GitHub PR preview link](/assets/images/posts/github-pr-swa-preview-link.png)
{: .notice--info}

### Complete Pull Request

In our scenario, {{ site.data.fake.engineer_name }} sent the link to {{ site.data.fake.ceo_name }} and he sent an email back while he was paragliding with the body of ":thumbsup:", so {{ site.data.fake.engineer_name }} moved on to the next step.

Back at the PR in GitHub, click on the **Merge pull request** button followed by the **Confirm merge** button.

![GitHub PR ready to merge](/assets/images/posts/github-pr-ready-to-merge.png)

![GitHub PR confirm merge](/assets/images/posts/github-pr-confirm-merge.png)

If you're quick enough to navigate over to the **Actions** tab in your {{ site.data.fake.web_public_repo }} repo you'll see two workflows in progress.

![GitHub Actions post PR workflows](/assets/images/posts/github-actions-workflows-in-progress.png)

The first workflow will have a name that begins with **Merge pull request** and is a new run of the workflow to deploy the website content from our main branch to the Static Web App. The main branch was updated with our new changes when we clicked that merge button for the PR. When that workflow finishes, the main URL of the Static Web App will have that text about investors.

The second workflow will have the same name as your PR (**Add Investory Solicitation** if you used my example) and is a new workflow that kicked off when you closed the PR by clicking the merge button. There is a second job in the workflow defined by `close_pull_request_job:` that is skipped when changes are made to the main branch by either merging or creating a PR. But that job is run when the PR is completed. The job deletes that preview environment from our Static Web App. If you view the **Environments** blade of the **{{ site.data.fake.company_code }}-{{ site.data.web.static_web_app_basic.workload }}-prd-1** resource in the Azure portal, you'll see that the environment has been deleted.

{% include figure image_path="/assets/images/posts/portal-swa-environment-no-preview.png" caption="The preview environment has been deleted from the Static Web App resource." alt="Preview deleted from Static Web App resource" %}

## Delete Your Branches

This step is optional but is a good practice to keep things tidy. Now that your work is complete and everything has been merged into main, you can delete the {{ site.data.web.static_web_app_basic.update_branch_name }} branch from both your local computer and GitHub.

You may think that you want to keep that branch around in case you need to go back to it. Well, Git is designed so that every commit is saved by default. Each commit is assigned an ID and behind the scenes, that branch you created is simply a friendly name for the last commit ID made on that branch. But the commit IDs are there forever (with exceptions). The point is, all the commit history from the {{ site.data.web.static_web_app_basic.update_branch_name }} branch will be added to the main branch *after you merge*. **However, if you delete a branch that has not been merged into another branch, that work is totally gone!**
{: .notice--info}

### Delete Branch in GitHub

There are two ways to do this and both are easy. The easiest is to go to the page for your PR, find the entry where it said the PR was merged and closed and click the **Delete branch** button. The other way is from the page that shows all branches as described [here](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-and-deleting-branches-within-your-repository#deleting-a-branch).

![delete a branch from the GitHub PR](/assets/images/posts/github-pr-delete-branch.png)

### Delete Local Branch

To delete the branch locally, you must first change to another branch. This is also a good chance to update your main local branch from GitHub since it will have the most recent changes that you just merged.

Before we do that, let's do a fetch. This step is optional, but it will let you see what's changed up in GitHub without merging everything into your local repository.

``` shell
git fetch
```

The output will show that there have been changes to the main branch in GitHub.

{% highlight output %}
remote: Enumerating objects: 9, done.
remote: Counting objects: 100% (9/9), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 7 (delta 2), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (7/7), 2.55 KiB | 261.00 KiB/s, done.
From https://github.com/{{ site.data.fake.engineer_github_account }}/{{ site.data.fake.web_public_repo }}
   12b86fa..6231862  main       -> origin/main
{% endhighlight %}

Now we'll merge the changes into our local main. Change your branch to main.

``` shell
git checkout main
```

After a few seconds, VS Code will show that you're in the main branch in the lower-left corner. Pull down the most recent changes from GitHub.

``` shell
git pull
```

If you still have the local SWA CLI running, you can refresh your local browser to confirm that main still works and that it shows your recent changes.

Now delete your local {{ site.data.web.static_web_app_basic.update_branch_name }} branch with the `branch -D` command.

``` shell
git branch -D {{ site.data.web.static_web_app_basic.update_branch_name }}
```
certificate 

Git will tell you the branch was deleted:

{% highlight output %}
Deleted branch solicit-investors (was ae903f9).
{% endhighlight %}

So fresh and so clean!

If you want to see other branches you have locally, simply type `git branch` to list them all out.
{: .notice--info}

## Achievement Unlocked!

Congratulations! You've completed the first service in our series. You've been awarded the prestigious Second Sleep certificate of completion. You can proudly display this in your home office to impress your children or pets.

![Static Web App Basic certificate of completion](/assets/images/posts/secondsleep-cert-static-web-app-basic.png)

Remember, there's no right or wrong way to do this. If you found a solution to your problem, then you did it the right way! Having said that, my way is undoubtedly the most correct way and anything else is very wrong, so check the links below to see what my code looks like when this service is complete.

- [{{ site.data.fake.infrastructure_repo }}](https://github.com/2ndsleep/{{ site.data.fake.infrastructure_repo }}/releases/tag/web%2Fstatic-web-app)
- [{{ site.data.fake.web_public_repo }}](https://github.com/2ndsleep/{{ site.data.fake.web_public_repo }}/releases/tag/web%2Fstatic-web-app%2Ffinal)