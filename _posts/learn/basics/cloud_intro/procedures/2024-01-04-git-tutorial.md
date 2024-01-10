---
title: Git Tutorial
categories: basics cloud_intro procedure
sort_order: 2
description: A link to Git tutorials
tags: git version-control source-control
---
There's already a ton of Git tutorials out there, so I'm just going to point you to them.<!--more--> This will be another brief post.

I would suggest setting aside 8 hours either all at once or spread out over a few days to learn Git. I think it will take less time than that (no shame if not).

Oh and if you're wondering why you're bothering to learn Git, see my [Git post]({% post_url /learn/basics/cloud_intro/explainers/2024-01-04-git %}).

## Installation

If you're using a Mac or Linux computer, you probably already have Git installed. Windows does not come with Git installed by default, so you'll have to install it yourself. A simple way to test on any operating system is to run the following command.

``` bash
git -v
```

You should see output similar to `git version 2.43.0`. If not, follow [these steps](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) to install Git.

## Starter

The **Git Immersion** site has an easy-to-follow tutorial with a pretty interface. It covers a lot of things, but if you took about 15 minutes each day, you could knock it out in about week or two.

[Git Immersion](https://gitimmersion.com){: .btn .btn--info}

## Intermediate

The official Git documentation site has the short and sweet **gittutorial**, which I actually find to be a bit difficult. Nevertheless, it covers the basics and is a solid tutorial.

[gittutorial](https://git-scm.com/docs/gittutorial){: .btn .btn--info}

There are a few things with this tutorial that can be confusing for beginners, so here's some pointers.

- In the [Importing a new project](https://git-scm.com/docs/gittutorial#_importing_a_new_project) section, they tell you to unzip a tarball with the command `tar xzf project.tar.gz`, but they don't supply an example tarball file for you. I created one that you can download [here](/assets/downloads/project.tar.gz).
- When committing messages, you will be dropped into a file editor and how that file editor works will be different depending on your operating system. To get around that, use the `-m` option to specify the commit message, like this: `git commit -m "Update webpage link"`.
- This tutorial refers to the default branch as the legacy `master` which was the default branch names years ago. Your Git client is more likely to use the newer default of `main`, so replace all references of `master` with `main` in the tutorial.
- If you're using a Mac, you're probably not going to have the **gitk** utility installed, so you can run the following to install it.

``` bash
brew update
brew install git-gui
```

## Challenging

Finally and optionally, if you've got the guts, try the **Learn Git Branching** interactive tutorial. This starts out really easy and gets really hard really fast, for real.

[Learn Git Branching](https://learngitbranching.js.org/){: .btn .btn--info}