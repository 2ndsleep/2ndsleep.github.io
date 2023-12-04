# Second Sleep Blog

This is the Jekyll content for the [Second Sleep blog](https://secondsleep.io). The Second Sleep blog is a project to help system administrators, system engineers, and IT specialists with their Azure deployments. This Jekyll content is intended to be hosted on [GitHub Pages](https://pages.github.com/).

## Getting Started

You can run this project locally or as a Docker container.

### Local

Running Jekyll for GitHub Pages is slightly different than running Jekyll in general, mostly with the Gemfile. See [About GitHub Pages and Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll) for help getting setup. For help with Jekyll in general, see the [Jekyll Installation](https://jekyllrb.com/docs/installation/) page.

Once you've got everything set up, run the following command to start the service locally.

```
bundle exec jekyll serve
```

If you want to display [draft posts](https://jekyllrb.com/docs/posts/#drafts), add the `--drafts` parameter. To display future-dated posts, add the `--future` parameter.

```
bundle exec jekyll serve --drafts --future
```

After that, you can access your local development service at http://localhost:4000.

### Docker

Run the following command to run this project as a Docker container. This assumes your current path (`$PWD`) is this repository. To re-use this container, exclude the `--rm` parameter.

``` bash
docker run --rm --name blog -ditp 4000:4000 \
    --volume="$PWD:/srv/jekyll:Z" jekyll/jekyll /bin/sh \
    -c "bundle install; bundle exec jekyll serve --drafts --future --host=0.0.0.0"
```

To use a Docker container on an arm32v7 Raspberry Pi processor, build it from the Dockerfile.

``` bash
docker build -t razblog .
docker run --rm --name razblog -ditp 4000:4000 \
    --volume="$PWD:/srv/jekyll:Z" razblog /bin/sh \
    -c "bundle install; bundle exec jekyll serve --drafts --future --host=0.0.0.0"
```

## Minimal Mistakes Theme

This site uses the [Minimal Mistakes Theme](https://mademistakes.com/work/minimal-mistakes-jekyll-theme/) which was created by the talented [Michael Rose](https://mademistakes.com/about/). Go to the [quick start guide](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/) for usage information.

## Authoring

Follow these guidelines for authoring pages and posts.

### Training Content

Training-related content is categorized in the following way:

**Service Category | Service | explainer/procedure**

The main category is the **service** which roughly corresponds to a workload that focuses on a specific training topic. A service may be something simple, like a VM, but a later service may later amend that service to add something like monitoring. Services are managed by the `_services` collection.

Since there may be a lot of services, they are grouped into **service categories** which are displayed in the [Learn](/_pages/learn.md) page. Service categories and managed by the `_service_categories` collection.

Posts are the actual blog entries related to the service and come in two flavors: **explainers** and **procedures**. Explainers give detailed background on the service being discussed whereas procedures give the short and sweet how-to.

Categories are defined in a service category, service, or post by specifying the `categories` Front Matter value. This a canonical field and will be specified to the depth necessary for the type of page or post. In other words, the `categories` field will have one item for service categories, two items for services, and three items for posts.

|Category|`categories` Structure|Example|
|--------|----------------------|-------|
|Service Category|`service_category`|`networking`|
|Service|`service_category service`|`networking vnet`|
|Post|`service_category service post_type`|`network vnet explainer`<br />-or-<br />`network vnet procedure`|

### Creating Service Categories and Services

To create a service category or service, create a new file in the `_service_categories` or `services` folder and specify the `categories` value appropriately. The layouts for these pages will render the excerpt for the page as a short description. However, the normal excerpt is not usually suitable for the view, so you should override the excerpt by specifying `excerpt` in Front Matter.

The service pages have additional Front Matter values that you may want to specify.

- `sort_order`: This is a numerical value that sets the order that this service will be rendered on the service category page.
- `guided`: Services can be part of a guided tour that will list the services in the order that they would have been performed for the fake company. Set this value to `true` for this service to appear in the [guided tour](/_pages/guided.md) page.
- `guided_order`: This is a numerical value that sets the order that this service will be rendered on the guided tour page.

### Creating a Training Post

Create a new file in the `_posts` or `_drafts` folder and add the following Front Matter and specify the `categories` value appropriately. A short description will appear under each post in the services pages, but unlike the service category and service pages, we specify this value with the `description` field in Front Matter. This will not override the excerpt, which we will want to preserve for other pages.

The post will also have additional Front Matter values that you may want to specify.

- `sort_order`: This is a numerical value that sets the order that this post will be rendered within the explainer or procedure section on the service page.
- `toc`: This indicated if the table of contents should appear. If omitted, it will default to `true`. You may want to set this value to `false` for shorter posts that will require little to no scrolling.

### Thoughts

"Thoughts" posts are like other posts, but they omit the `categories` Front Matter field and instead have the following line in Front Matter.

``` yaml
category: thoughts
```

You may also choose to omit the table of contents by specifying `toc: false`.

### Subfolders

Service category pages, service pages, and posts can be organized into subfolders for convenience. The subfolder structure will have no bearing on how the static site is generated.

### Stylesheets

The Minimal Mistakes theme can be overridden by modifying one of two files.

The simplest way to make changes is to set custom values for variables in the [minimal-mistakes-variables.scss](/_sass/minimal-mistakes-variables.scss) file. This will override the default values in the [_variables.scss](https://github.com/mmistakes/minimal-mistakes/blob/master/_sass/minimal-mistakes/_variables.scss) file of the theme.

The [minimal-mistakes-overrides.scss](/_sass/minimal-mistakes-overrides.scss) is imported after the theme SASS is imported. You can specify SASS content that will take precedence over the theme's SASS.

### SVG Drawings

SVG drawings made by Inkscape will have a leading prolog that will get rendered as escaped HTML when using the `include` Liquid tag. This prolog looks like this.

``` xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
```

As special include file of `svg.html` will properly render an embedded SVG file by removing the prolog if it exists. The syntax for using this include file is as follows.

```
{% include svg.html path="svg_file_render.svg" %}
```

### Breadcrumbs

The breadcrumbs feature has been customized by the [breadcrumbs.html](/_includes/breadcrumbs.html) include to only show breadcrumbs for service categories, services, and related posts. Set the following items in the `_config.yml` file to customize breadcrumbs.

- `breadcrumbs`: Set to `true` to enable breadcrumbs.
- `breadcrumb_home_label`: Set the text to appear as the root of the breadcrumb chain.
- `breadcrumb_home_url`: Set the path that the root of the breadcrumb chain will link to.
