---
title: Things to Know About This Project
categories: web static-web-app explainer
sort_order: 3
description: This is a bunch of random things about this project node
tags: terraform terraform-cloud service-principal vs-code workspaces gitignore
---
Since this is the first real service we're deploying as part of our {% include reference.html item='fake_company' %} venture, here's a bunch of random shit to know before you [jump in]({% post_url /learn/web/static-web-app/procedures/2024-02-28-configure-dev-environment %}).<!--more-->

## Terraform vs. Terraform Cloud

The first thing to know is that I've been promising that we'll use Terraform Cloud in this project. That is true, but for this very first one, we'll use the [Terraform CLI]({% post_url /learn/basics/iac/explainers/2024-02-06-terraform %}#{{ 'Terraform Cloud' | slugify }}) to deploy everything from the command line. I want you to deploy this from the command line to get a better feel for Terraform itself before we start using Terraform Cloud. Deploying from Terraform Cloud can feel a little abstract and I think it will be good to get a tactile feel for it under your belt or suspenders or sweatpants.

### Service Principal for Terraform Access to Azure

If you did the [Terraform tutorial]({% post_url /learn/basics/iac/procedures/2024-02-06-azure-terraform-tutorial %}) for Azure, you got to a step where they asked you to [create a service principal](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build#create-a-service-principal). Using a service principal is a good practice, but they don't really explain why. I can speculate two reasons as to why they include this.

I explain what a service principal is in my [Entra ID]({% post_url /learn/basics/azure_intro/explainers/2024-01-12-entra-id %}#{{ 'Service Accounts' | slugify }}) explainer, but in short, a service principal is an account that is used by services (instead of people) to access other services. So in the Terraform tutorial, they ask you to create a service principal and then grant it the *Contributor* role to your subscription, which lets you perform almost any non-security related action on your Azure subscription. When you ran the rest of the steps in the tutorial, everything was run as that service principal, not as you.

The first likely reason for this is that Terraform doesn't actually know if your account has Contributor access. It also doesn't know if your account *should* have Contributor access. This may be prohibited by a policy for your organization or maybe you're just really security-minded and want to limit what access your account has (good for you, if so!).

The other likely reason is that now that you've created a service principal, you can use this service principal in future CI/CD operations, such as [Terraform Cloud]({% post_url /learn/basics/iac/explainers/2024-02-06-terraform %}#{{ 'Terraform Cloud' | slugify }}). When Terraform Cloud needs to connect to Azure to deploy resources, you can't use your username and password. It will only allow a service principal. You wouldn't want to use your user account anyway, for reasons I explain [here]({% post_url /learn/basics/azure_intro/explainers/2024-01-12-entra-id %}#{{ 'Service Accounts' | slugify }}). So Terraform's tutorial tees you up for best practices.

### Your User Account for Terraform Access to Azure

Here's the thing, though. If you're not using your company's Azure tenant and created a new tenant on your own, your account will by default be assigned the Global Administrator role. If you're only using this for shits 'n giggles like running the examples from my lovely site, that should be okay. In that case, you don't need to create a service principal for the examples in this series of posts. Simply by logging in with `az login` and excluding the `ARM_CLIENT_ID` and `ARM_CLIENT_SECRET` environment variables, you can apply the Terraform configurations to create Azure resources. In other words, you wouldn't need to create and use a service principal for this Static Web App example.

I'm using the warning color here to highlight that using a service principal is the most secure and "proper" way to do this. Don't use your user account for deployments in a real-world scenario. Even for testing and lab purposes, consider using a service principal.
{: .notice--warning}

Using a service principal is still a better approach, so I'm going to use that in the examples for this service.

## VS Code Workspaces

We're going to organize our work in VS Code into something called a [workspace](https://code.visualstudio.com/docs/editor/workspaces). You often find yourself working on several projects at one time, constantly switching back and forth among them. Workspaces allow you collect all the various folders that are related to a project into a single pane of glass. When you need to turn your attention to another project, you can just switch to that workspace and all the folders are displayed. It will even remember which files you had open when you switch back to the workspace.

This is especially useful if you're a platform infrastructure engineer who is deploying an application, just like this scenario. We'll be using two repositories: one for the platform infrastructure (Terraform) and one for the static website code. We can add both of those folders to our workspaces since we'll be working on them as part of the same project.

## .gitignore

The *.gitignore* file is an optional file you can add to a Git project that tells Git not to include certain files in its repository. There are many reasons you may not want to commit some files to your repo, and here are the two main reasons I can think of.

The first is that you may have configuration files that are specific to your environment. For example, a developer may have a configuration file that tells the app to connect to a database on that developer's local laptop. The database hopefully doesn't have any production data on it, because we're concerned about security and customer privacy (right??), but instead has enough data so the developer can run and test the application locally. That database connection information is useless outside of the developer's laptop, so there's no need to check it in. In fact, it will only cause problems when another developer pulls the newest updates because it will have some other weird developer's connection strings. So it's best to leave it out of the repo altogether. The file can still exist locally, but can be edited independently by each developer without being committed to the repo.

Really, leave the configuration information out? Don't we need that in production? As we'll see in future projects, we can and will inject the correct configuration strings for each environment as part of our CI/CD process.
{: .notice--info}

The second reason is kind of related to the first, which is that you may have sensitive data that you don't ever want to be in your repository. This may not be passwords necessarily (and hopefully isn't!) but may be grey area items, like Azure subscription IDs.

For your infrastructure repository, select **Terraform** for the dropdown box under the **Add .gitignore** section when creating the repository. If you didn't do that, you can also create or edit your *.gitignore* file to include the entries from [GitHub's recommended *.gitignore* for Terraform](https://github.com/github/gitignore/blob/main/Terraform.gitignore).

## Node Dependencies

When we develop our web application code [locally]({% post_url /learn/web/static-web-app/procedures/2024-03-01-swa-local-dev %}), we will install the **@azure/static-web-apps-cli** (SWA CLI) Node package using the `npm` command. The SWA CLI package simulates an Azure Static Web App service on your local computer.

You can install Node packages either globally or as a development dependency. Microsoft's documentation recommends you install the SWA CLI package as a development dependency but doesn't explain why. So I'll try to clear it up a bit.

Typically, you'd only want global dependencies to be installed on your production server. The SWA CLI would never be used in production since it's designed specifically for testing locally. You don't run the Static Web App emulator in production; you run your app on the real Static Web App.

On your local laptop, if you're not using Node for anything other than this project then it doesn't really matter. You could make the argument that it's a good idea to install the SWA CLI as a development dependency in case you have multiple projects and want different versions of the SWA CLI for each project. I don't really know why they tell you to install it as a development dependency, but I'd love to hear from someone who knows this stuff better than I do.

I guess I didn't clear it up.
{: .notice--info}

I'm going with the development dependency path since I'm a rule-follower. When you do that, the dependencies will go into a subfolder named *node_modules* relative to where ever you ran the `npm install` command. But I'd like to point out that even though Microsoft's Static Web App local development documentation says to use development dependencies, they show all the [examples](https://learn.microsoft.com/en-us/azure/static-web-apps/local-development#get-started) as if it were installed globally. So anywhere they show the `swa` command, replace that with `./node_modules/.bin/swa`.

No matter which route you go, you should exclude all the Node-related files from your repository by adding the following lines to your *.gitignore* file.

```
node_modules
package-lock.json
package.json
swa-cli.config.json
```

If you are actually writing a Node application (which we are not doing for this service), you probably shouldn't exclude these files. Again, you Node developers out there, please leave comments with any thoughts, guidance, or corrections.