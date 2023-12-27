---
title: Naming Conventions
categories: basics azure_intro explainer
toc: true
sort_order: 3
description: Possibly the most singularly important part of your job
---
Spend some time thinking about how you will name your resources and you'll be thankful. This sounds trivial, but it is perhaps the most important thing you'll do.
<!--more-->

## Naming and Tagging

First, let's get some terms out of the way. **Naming** is exactly what you think it is: what you name your Azure resources.

Azure resources allow you to apply [**tags**](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources). These are simply name-value pairs of whatever the frick you want. Here's some tagging examples.

|Tag Name|Value|
|--------|-----|
|environment|prd, stg, dev|
|cost-center|Engineering, Business Intelligence, IT|
|workload|web API, billing export, ETL|

You can then use those tags to do the following things:

- Search for resources that have specific tag values. For example, find all the staging resources.
- Apply policies to resources. For example, you could have a policy that adds a [delete lock](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources?tabs=json) on all your production resources so someone doesn't accidentally delete those resources.
- Run billing reports. For example, you can see how much the Engineering department is spending on Azure resources and then go yell at them.

## Define a Naming & Tagging Convention

If you haven't quit reading yet, I implore you to take literally 5-10 minutes and think about and document your naming strategy. It sounds silly, but if you don't come up with a strategy, your resources are going to get out of hand really fast and won't be able to easily identify them.

### Quick & Dirty

If you want a quick and dirty approach, see Azure's [Define your naming convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) where you'll find this recommended pattern:

{% include figure image_path="https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/_images/ready/resource-naming.png" alt="recommended naming convention" caption="Recommended Azure resource naming convention" %}

### Long & Clean

If you have about twenty minutes free, read through Microsoft's [Naming and tagging](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging) documentation. They also have a recommended list of [abbreviations for resource types](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).

### My Approach

Okay, in my experience I've found that Microsoft's recommendation doesn't quite fit my needs. First, I've never found that putting the resource type in the name is helpful because you can easily group resources by type in the portal or on the command line. It just takes up space. Second, knowing the region hasn't been that helpful. I prefer to instead use the instance value to distinguish different locations, but I think many of you will disagree depending on your scenario. And finally, you may want to consider adding your organization name to the resource name if you work in a company that has subsidiaries or plan to gain or become a subsidiary in the future.

With those justifications, here's what I've settled on.

```
organization-workload-environment-instance
```

So if you work for a company named **{{ site.fake_company_name }}** and you're deploying the **Web API** product in **production**, you may name it this:

```
{{ site.fake_company_code }}-webapi-prd-1
```

The first thing you may notice is that a lot of items are shortened. The main reason is to save space so that they names aren't super long which can be particularly difficult if you're working on the command line. But another reason you might want to do this is because you want each segment to have a pre-determined length. This is convenient because you may want to run a script to get all the resources that are associated with, say, a particular workload. If all the resources have a known length, the script could know to grab characters 7-12 for the workload. To help with this, you'll probably want to document a list of codes that will be used for each segment, perhaps as such:

|Organization|Code|
|------------|----|
|{{ site.fake_company_name }}|{{ site.fake_company_code }}|
|AdventureWorks|adwk|
|Datum|datm|

|Workload|Code|
|--------|----|
|Database|sqldat|
|Web API|webapi|
|Front-End|userui|

|Environment|Code|
|-----------|----|
|Production|prd|
|Staging|stg|
|Test|tst|
|Development|dev|

Coming up with acronyms is hard.
{: .notice--info}

The **instance** segment can be a free-form value, but will generally be a number that is incremented. You may want to supply additional information if necessary. Suppose we have two APIs: one for billing and one for inventory. Then you might name them the following:

```
{{ site.fake_company_code }}-webapi-prd-billing1
{{ site.fake_company_code }}-webapi-prd-inventory1
```

Earlier I gave an example of a script that would parse the resource name based on the length of each segment. You may think that it doesn't matter what the length of the segments are because you could just break things apart by the dashes. But you run into two problems here. One is that you may want to use dashes in the codes. But the bigger problem is that not all resources allow the same type of characters. In fact, a storage account name cannot contain dashes. So you may need a separate naming convention for different resource types. For storage accounts, we'll make ours the same convention, but without dashes. This is where the fixed-length nature of the segments is important.

Here's an example storage account name:

```
{{ site.fake_company_code }}webapiprd1
```

Here's another wrinkle. Unlike most resources, storage account names need to be globally unique. That means that no one else in the planet can use the same storage account name as you. Adding the organization name to the beginning will make it more likely that your name will be unique.

As you can see, there are a number of things to consider and the one I use probably won't fit your needs, but I wanted to step you through the decision-making process I used.

## Infrastructure as Code

The whole point of this blog is to automate everything so of course we'll create an infrastructure as code module to handle naming and tagging for us automatically in a future post.