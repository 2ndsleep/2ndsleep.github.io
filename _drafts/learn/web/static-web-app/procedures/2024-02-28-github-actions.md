---
title: Create GitHub Actions Workflow
categories: web static-web-app procedure
sort_order: 5
description: Let's create a GitHub Actions workflow to push our website code to our Azure Static Web App resource. 
---
{% assign fake_company_name_lower = site.data.fake.company_name | downcase %}
{% assign web_public_repo = '-web-public' | prepend: fake_company_name_lower %}

Now it's time to deploy our website to our Static Web App resource using GitHub Actions.<!--more--> If you've been following along, so far we've done the following:

- [Created your GitHub repositories]({% post_url /learn/web/static-web-app/procedures/2024-02-28-configure-dev-environment %}) and cloned them to your local computer
- Created a new [Static Web App resource with Terraform]({% post_url /learn/web/static-web-app/procedures/2024-02-28-swa-terraform %})
- Run the static website on your [local computer]({% post_url /learn/web/static-web-app/procedures/2024-02-28-static-web-app-local-dev %}).
- Pushed all the changes you made [back up to your GitHub repo]({% post_url /learn/web/static-web-app/procedures/2024-02-28-push-to-github %}).

And as you recall, we haven't put our custom website content on our Azure Static Web App resource so it's using a [temporary default website]({% post_url /learn/web/static-web-app/explainers/2024-02-01-static-web-app %}#{{ 'How Do I Upload My Web Content to This Site?' | slugify }}). We're finally going to deploy the site that our designer created to our Azure Static Web App resource. The way this works is that we create a CI/CD pipeline with **GitHub Actions** known as a **workflow** that will take our website code and deploy it to our Static Web App. And this is way easier than it sounds.

## Create Static Web App API Token Secret in GitHub

We're going to create a GitHub Actions workflow in the next section, but first we'll need a way for our workflow to authenticate to our Static Web App resource so that it can deploy our website to it. Our Static Web App has an API token that we can copy and add to our GitHub repository so that the workflow can use it for authentication.

For this one-time task, the easiest way is to get the token from the portal.

1. Go to the [Azure portal](https://portal.azure.com) and find your Static Web App resource in the **{{ site.data.fake.company_code }}-webpub-prd-1** resource group.
1. In the overview blade for the Static Web App, click the **Manage deployment token** button at the top. ![Managing deployment token](https://learn.microsoft.com/en-us/azure/static-web-apps/media/deployment-token-management/manage-deployment-token-button.png).
1. Click the button to copy ![copy icon](/assets/images/posts/azure-copy-icon.png) the token.

Now that you have the token, you'll need to create the secret in your {{web_public_repo }} repository. Follow the GitHub instructions for [creating secrets for a repository](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository).

- For the secret name, use `AZURE_STATIC_WEB_APPS_API_TOKEN`.
- For the secret value, paste the API token you copied from the Azure portal.

As you'll see in a moment, this secret for the `${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}` variable in our workflow YAML below.

## Create GitHub Actions Workflow

Now it's time to create the workflow.

1. Go to your {{ web_public_repo }} repository in GitHub.
1. Click the **Actions** tab at the top. If you haven't yet created any workflows yet, it will take you to the page to create a new workflow. If you have already created any workflows, click the **New workflow** button. ![GitHub Actions button](https://docs.github.com/assets/cb-15465/mw-1440/images/help/repository/actions-tab-global-nav-update.webp)
1. Click the link below the **Choose a workflow header** to **set up a workflow yourself**. *You'll presented with a list of recommended starter workflows and you can search for the `azure static web app` starter workflow, but our workflow is customized enough that we want to create it from scratch.*
1. Change the name of the file to `azure-staticwebapp.yml`. *(Or any name you want. It doesn't matter, it's just that the default name isn't descriptive enough.)*
1. Paste the code below into the editor.
1. Click the **Commit changes** button, optionally change the commit message, and then click the **Commit changes** button again. Leave the **Commit directory to the `main` branch** option selected.

``` yaml
{% raw %}name: Deploy web app to Azure Static Web Apps

on:
  push:
    branches: [ "main" ]
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [ "main" ]

env:
  APP_LOCATION: "/src"

permissions:
  contents: read

jobs:
  build_and_deploy_job:
    permissions:
      contents: read # for actions/checkout to fetch code
      pull-requests: write # for Azure/static-web-apps-deploy to comment on PRs
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
      - name: Build And Deploy
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }} # Get this from the Azure portal for the Static Web App resource
          repo_token: ${{ secrets.GITHUB_TOKEN }} # This is created automatically by GitHub Actions
          action: "upload"
          app_location: ${{ env.APP_LOCATION }}
          skip_app_build: true
          skip_api_build: true

  close_pull_request_job:
    permissions:
      contents: none
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request Job
    steps:
      - name: Close Pull Request
        id: closepullrequest
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }} # Get this from the Azure portal for the Static Web App resource
          action: "close"{% endraw %}
```

The `${{ secrets.GITHUB_TOKEN }}` secret is created and managed automatically and dynamically by GitHub and you don't need to do anything for that. Read more about it [here](https://docs.github.com/en/actions/security-guides/automatic-token-authentication).
{: .notice--info}

## Check Workflow

The workflow will began running as soon as you commit your changes to the YAML file. That's because the lines below tell GitHub to run this anytime changes are made to the main branch, and you just committed the changes of the workflow YAML file itself to the main branch (very meta 🤯). You can see if this workflow ran successfully by clicking on the **Actions** tab for your repo where you'll see a list of the workflows.

![GitHub Actions button](https://docs.github.com/assets/cb-15465/mw-1440/images/help/repository/actions-tab-global-nav-update.webp)

If you see a green checkmark next to the most recent workflow run, you're good! Now go to the URL of your Static Web App that you got way back in our [Terraform deployment]({% post_url /learn/web/static-web-app/procedures/2024-02-28-swa-terraform %}#{{ 'Admire Our Work' | slugify }}), and see if our code is there.