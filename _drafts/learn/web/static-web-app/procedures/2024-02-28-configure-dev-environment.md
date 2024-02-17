---
title: Configure Your Development Environment
categories: web static-web-app procedure
sort_order: 1
description: First thing's first, let's set up our repositories and VS Code.
projects_folder:
  - name: $HOME (my home folder)
    children:
      - name: Projects
        children:
          - name: repository-1
          - name: repository-2
          - name: repository-3
---
{% assign fake_company_name_lower = site.fake_company_name | downcase %}
{% assign infrastructure_repo = '-infrastucture' | prepend: fake_company_name_lower %}
{% assign web_public_repo = '-web-public' | prepend: fake_company_name_lower %}

Let's get our house in order first and create our GitHub repositories and set up our VS Code workspace.<!--more-->

This post shows how to create your repos in GitHub first and then clone them to your local computer. It is totally possible to create your repo on your local computer first and then push it up to an empty GitHub repository but it is slightly harder to demonstrate and more error-prone, which is why I'm doing it this way.
{: .notice--info}

## Projects Folder

Although not absolutely required, it's nice to decide where you're going to put your code on your local computer. You can put it anywhere if you want, but let's try to be organized here. Here's how I like to do things:

{% include filesystem.html id="projects_folder" %}

The *$HOME* folder is your user profile folder, which will be *\Users\{{ site.fake_username }}* in Windows and */Users/{{ site.fake_username }}* in macOS and Linux (assuming your username is {{ site.fake_username }}). I put all my repositories in the *Projects* subfolder which exists by default in macOS but you can create it in Windows or Linux.

We're not going to create our repository folders quite yet. That will happen automatically when we clone them from GitHub.
{: .notice--info}

## Create GitHub Repos

The first we're going to do is create a new repository in GitHub. If you've been following the [guided tour]({% link _pages/guided.md %}), you've already created your [infrastructure repository]({% post_url /learn/basics/iac/procedures/2024-02-07-github %}), but if you haven't do that now.

We also need a repo for the static website. Follow the same steps to [create a GitHub repository]({% post_url /learn/basics/iac/procedures/2024-02-07-github %}) as you did for the infrastructure repository, but name it **{{ web_public_repo }}** and leave the **Add .gitignore** option set to `None`.

{% include figure image_path="/assets/images/posts/github-new-repo-web-public.png" caption="Create the new repository for the public website code on your GitHub account" alt="new GitHub repository for public website code" %}

When you're done, you should see at least the following two repositories (or something similar if you named them differently) when you go to your profile at [github.com](https://github.com).

- {{ infrastructure_repo }}
- {{ web_public_repo }}

## Clone Repositories

Now we want to pull down the content from the repositories we just created on GitHub down to our local computer. This is called **cloning** your repository. Since we have two repositories for this project, I can show you two different ways for doing things: these hard way with the command line and the easy way with VS Code.

If you haven't [instealled VS Code]({% post_url /learn/basics/iac/procedures/2024-01-31-vscode %}), do that now.
{: .notice--info}

This will all be done with VS Code, even the command line. Before running these commands, launch VS Code and click **File > Close Workspace** from the menu bar. If you don't see the Close Workspace option, it means you don't have a workspace open and you're good to proceed the steps below.

For both of these methods, you'll need to copy the URL of your GitHub repo from the GitHub site. The URL will end with *.git*.

{% include figure image_path="/assets/images/posts/github-copy-repo-url.png" caption="Copy the URL for cloning which will end in *.git*." alt="copy GitHub cloneable URL" %}

### Clone with Command Line

Let's clone our {{ infrastructure_repo }} with the command line.


1. In VS Code, click **View > Terminal** from the menu bar or type `` Ctrl+` `` to bring up the terminal.
1. Go into your [*Projects*](#{{ 'Projects Folder' | slugify }}) folder by typing `cd ~/Projects` (or `cd` into whatever folder you've chosen to keep your projects in).
1. Copy the URL of your repository and then type `git clone <URL of your repo>` as described [here](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository).<br />![Clone GitHub repo with command line](/assets/images/posts/vscode-git-clone-cli.png)
1. You will be prompted by VS Code to sign into GitHub. Click **Allow** which will launch a web browser where you can log into GitHub. After successfully logging in, you'll be directed back to VS Code where the clone process will continue. *You will not be prompted to log in if you made your repo public or if you have already authenticated to GitHub from the `git` command line.*<br />![GitHub authentication prompt](/assets/images/posts/vscode-git-auth-prompt.png)

Your repository should now be cloned into a subfolder of your *Projects* folder, for example */Users/{{ site.fake_username }}/Projects/{{ infrastructure_repo }}*.

### Clone with VS Code

1. In VS Code, type `Ctrl+Shift+P` (Windows and Linux) or `⇧⌘P` (macOS) to bring up the [Command Palette](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette).
1. Type `clone` and then select **Git: Clone**.<br />![VS Code Git Clone command palette](/assets/images/posts/vscode-git-clone.png)
1. Select **Clone from GitHub**.
1. Type or select the **your-account/{{ web_public_repo }}** repository from the list.<br />![VS Code select GitHub repository](/assets/images/posts/vscode-select-clone-repo.png)
1. Select the [*Projects*](#{{ 'Projects Folder' | slugify }}) folder or whatever folder you've chosen to keep your projects in.<br />![VS Code select Git clone folder destination](/assets/images/posts/vscode-select-clone-folder.png)
1. Click **No/Cancel** when VS Code asks you if you want to open the cloned repository. In most cases, you'd probably say yes, but for our demonstration, we're going to do that in the next section.<br />![VS Code prompt to open cloned repo](/assets/images/posts/vscode-prompt-open-repo.png)

## Set Up VS Code Workspaces

If everything went well in the previous section, you will have two beautiful cloned repositories in your *Projects* folder. Now let's add those repositories to a VS Code [workspace]({% post_url /learn/web/static-web-app/explainers/2024-02-28-developing-app %}#{{ 'VS Code Workspaces' | slugify }}), which will organize these two repositories into a single pane of glass since we'll be working on them together.

1. Launch VS Code.
1. Click **File > Close Workspace**. If you don't see the Close Workspace option, it means you don't have a workspace open and you can move on to the next step.
1. Click on the **Explorer** icon ![VS Code Explorer icon](/assets/images/posts/vscode-explorer-icon.png) in the Activity Bar on the left side of the VS Code window to show the file view.<br />![VS Code Explorer view](/assets/images/posts/vscode-initial-explorer-view.png)
1. Click **File > Add Folder to Workspace** and navigate to the *Projects* folder. Click on the *{{ infrastructure_repo }}* folder without going into the folder itself and then click the **Add** button.<br />![VS Code add folder to workspace](/assets/images/posts/vscode-select-workspace-folder.png)
1. Click **Yes** if it asks you if you trust this folder. Unless you don't trust it, in which case I'm sorry I haven't gained your trust (although I commend your vigilance!).<br />![VS Code trust folder prompt](/assets/images/posts/vscode-trust-prompt.png)
1. Repeat steps 3 and 4, but with the *{{ web_public_repo }}* folder instead.
1. Click **File > Save Workspace As** and then save this workspace as *swa* in a folder of your choosing (I like to create a *Workspaces* folder below my home folder).<br />![VS Code save workspace](/assets/images/posts/vscode-save-workspace.png)