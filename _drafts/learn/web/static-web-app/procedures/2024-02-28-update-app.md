---
title: Update Static Web App
categories: web static-web-app procedure
sort_order: 5
description: We need to make some changes to our web app.
---
{% assign engineer_name = site.fake_username | capitalize %}
{% assign fake_company_name_lower = site.fake_company_name | downcase %}
{% assign web_public_repo = '-web-public' | prepend: fake_company_name_lower %}
{% assign branch_name = 'solicit-investors' %}
{% assign engineer_github_account = site.fake_company_name | append: site.fake_username %}

{{ site.fake_ceo_name }}, the CEO of {% include reference.html item='fake_company' %} - a real ideas guy (trust fund kid) - had the brilliant notion of trying to solicit investors in the company, even though we don't have a product yet. But hey, why should the lack of a product [stop entrepreneurship](https://www.alexanderjarvis.com/25-startups-that-raised-without-a-product/)? He's asked that we add an email address where people can inquire about investing. So sure, let's do that.<!--more-->

## Make Changes Locally

First thing's first, let's make this change to our website locally and test it. Fire up VS Code and open the terminal into the *{{ web_public_repo }}* folder.

### Create New Branch

When we [pushed our changes to our GitHub repos]({% post_url /learn/static-web-app/procedures/2024-02-28-push-to-github %}), we pushed directly to our main branch. Well, that's not exactly the best way to go about it. A more appropriate way would be to create a branch for all your changes, and then create a pull request for that branch when the changes are ready.

I'm going to show you how to do this on the command line. When we make changes to our Terraform configuration in the next post, I'll show you to do this in VS Code.

Run the following command in your terminal to create a new branch named **{{ branch_name }}** and switch to that branch.

``` shell
git checkout -b {{ branch_name }}
```

After a few seconds, you'll see that VS Code has detected you're on a new branch in the lower-left corner.

### Update Static Web Content

If you need a refresher on testing locally, see the [Static Web App Local Development]({% post_url /learn/web/static-web-app/procedures/2024-02-28-static-web-app-local-dev %}) post.
{: .notice--info}

Run the following command to start up the Static Web App emulator on your local computer.

``` shell
./node_modules/.bin/swa start
```

Now open the *src/index.html* file in VS Code and add the following on line 12.

``` html
<p>Interested in investing? Email us at bad-decisions@{{ site.fake_company_domain }}.</p>
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
            <p>Interested in investing? Email us at bad-decisions@{{ fake_company_domain }}.</p>
        </div>

        <footer>This is a demo site inspired by the <a href="https://www.secondsleep.io">Second Sleep</a> project.</footer>
    </body>
</html>
{% endhighlight %}

Now refresh your web browser (or go to `http://localhost:4280` if you closed it), and you'll see your changes.

{% include figure image_path="/assets/images/posts/static-web-app-update-1.png" caption="Great idea, boss!" alt="updated public website" %}

## Create Pull Request

Once things are looking good locally, it's time to create a pull request.

### Commit Changes

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
fatal: The current branch {{ branch_name }} has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin {{ branch_name }}
{% endhighlight %}

Git is telling you that it doesn't know what you want to call the branch when you push it up to GitHub. You'd think it would just call it **{{ branch_name }}**, but Git doesn't like to make assumptions. Run the command it's recommending.

``` shell
git push --set-upstream origin {{ branch_name }}
```

If it worked, you'll see output like this:

{% highlight output %}
...
remote: Create a pull request for '{{ branch_name }}' on GitHub by visiting:
remote:      https://github.com/{{ engineer_github_account }}/{{ web_public_repo }}/pull/new/{{ branch_name }}
remote: 
To https://github.com/{{ engineer_github_account }}/{{ web_public_repo }}.git
 * [new branch]      {{ branch_name }} -> {{ branch_name }}
Branch '{{ branch_name }}' set up to track remote branch '{{ branch_name }}' from 'origin'.
{% endhighlight %}

By the way, now that you set the upstream remote branch, you only have to run `git push` for any further changes you want to push on this branch.
{: .notice--info}

### Create Pull Request in GitHub

Now on to the actual pull request (PR).

1. Go to your {{ web_public_repo }} in GitHub. You should see a banner in your repo that looks kind of like the image below. ![GitHub "Compare & pull request" banner](https://docs.github.com/assets/cb-34106/mw-1440/images/help/pull_requests/pull-request-compare-pull-request.webp) If you see that banner, click on the button. If not, follow GitHub's instructions for [creating a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).
1. Type a title and description in the next page. The description supports [Markdown](https://www.markdownguide.org/). If you don't want to think about, you can use this:
  - **Title:** `Add Investor Solicitation`
  - **Description:** `Our stupid CEO wanted us to add this stupid text because he's stupid. Luckily he'll never read this because he's stupid.`
1. Click the **Create pull request** button.

This will take you to the PR page where you'll see the description at the top and some checks that should be running. **Don't click the Merge button yet!** You've just done something cool and I want you to appreciate it.

One of the checks that ran was our GitHub Actions workflow. At the top of our workflow, we have these lines:

``` yaml
on:
  push:
    branches: [ "main" ]
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [ "main" ]
```

The `push:` part says to run the workflow when we merge with the main branch, which we'll do in a second. But the `pull_request:` part says to run the workflow when we create a PR that will merge into main, which is what we just did.

Our Static Web App resource is aware of these PRs and will automatically create a separate preview website just for us to review the change we're about to merge.

1. Go to the **{{ site.fake_company_code }}-webpub-prd-1** resource in the [Azure portal](https://portal.azure.com).
1. Click on the **Environments** blade.
1. You'll see your PR listed under the **Preview environments** section. Click on the **Browse** button to open our changes in a browser. You can send this link to your stakeholders to make sure they approve of the changes that are about to be made.

You'll also see this link on the PR page in GitHub if you wait long enough to let the workflow finish whereupon the github-actions bot will leave a comment with a link to the preview URL.
{: .notice--info}

In our scenario, {{ engineer_name }} sent the link to {{ site.fake_ceo_name }} and he sent an email back while he was paragliding with the body of :thumbsup:, so {{ engineer_name }} moved on to the next step.

Back at the PR in GitHub, click on the **Merge pull request** button followed by the **Confirm merge** button.

If you're quick enough to navigate over to the **Actions** tab in your {{ web_public_repo }} repo you'll see two workflows in progress. The first is a new run of the workflow to deploy the website content from our main branch (which has just been updated by the merge) to the Static Web App. When that finishes, the main URL of the Static Web App will have that text about investors.

The second workflow is actually the PR workflow run that kicked off when we created the PR. There is a second job in the workflow defined by `close_pull_request_job:` that is skipped when changes are made to the main branch. But that job is run when the PR is completed. The job deletes that preview environment from our Static Web App. If you view the **Environments** blade of the **{{ site.fake_company_code }}-webpub-prd-1** resource in the Azure portal, you'll see that the environment has been deleted.

## Delete Your Branches

This step is optional but is a good practice to keep things tidy. Now that your work is complete and everything has been merged into main, you can delete the {{ branch_name }} branch from both your local computer and GitHub.

You may think that you want to keep that branch around in case you need to go back to it. Well, Git is designed so that every commit is saved by default. Each commit is assigned an ID and behind the scenes, that branch you created is simply a friendly name for the last commit ID made on that branch. But the commit IDs are there for good (with very minor exceptions). The point is, all the commit history from the {{ branch_name }} branch will be added to the main branch *after you merge*. **However, if you delete branch that has not been merged into another branch, that work is totally gone!**
{: .notice--info}

### Delete Branch in GitHub

There are two ways to do this and both are easy. The easiest is to go to the page for your PR, find the entry where it said the PR was merged and closed and click the **Delete branch** button. The other way is from the page that shows all branches as described [here](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-and-deleting-branches-within-your-repository#deleting-a-branch).

### Delete Local Branch

To delete the branch locally, you must first change to another branch. This is also a good chance to update your main local branch from GitHub since it will have the most recent changes that you just merged.

Change your branch to main.

``` shell
git checkout main
```

Pull down the most recent changes from GitHub.

``` shell
git pull
```

If you still have the local SWA CLI running, you can refresh your local browser to confirm that main still works and that it shows your recent changes.

Now delete your local branch with the `branch -D` command.

``` shell
git branch -D {{ branch_name }}
```

So fresh and so clean!

If you want to see other branches you have locally, simply type `git branch` to list them all out.
{: .notice--info}