# Second Sleep Blog

This is the Jekyll content for the Second Sleep blog. The Second Sleep blog is a project to help system administrators, system engineers, and IT specialists with their Azure deployments. This Jekyll content is intended to be hosted on GitHub pages.

## Getting Started

Running Jekyll for GitHub Pages is slightly different than running Jekyll in general, mostly with the Gemfile. See [About GitHub Pages and Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll) for help getting setup. For help with Jekyll in general, see the [Jekyll Installation](https://jekyllrb.com/docs/installation/) page.

## Minimal Mistakes Theme

This site uses the [Minimal Mistakes Theme](https://mademistakes.com/work/minimal-mistakes-jekyll-theme/) which was created by the talented [Michael Rose](https://mademistakes.com/about/). Go to the [quick start guide](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/) for usage information.

## Navigation

Visitors that drop into the home page are expected navigate through the **Starting Learning** links. These actually links to the [Services](/services) page which lists all the broad categories of blog content. Each service is further divided into Explainers and Procedures.

### Services

Services are the broad categories of blog content. They closely follow Azure resource types, but will not necessarily be a one-to-one mapping of resource types.

#### Services Collection

The `/services` page will enumerate the **services** site collection, displaying a title linking to the service page and the collection item's excerpt. Clicking on a service will navigate to that's service page. The `/services` page is rendered by the [`collection`](https://mmistakes.github.io/minimal-mistakes/docs/layouts/#layout-collection) layout of the Minimal Mistakes Theme. The content for the `/services` page is pulled from the `_pages/services.md` file.

To add a service, create a new markdown or HTML file in the `_services` folder with the following Front Matter.

- title
- permalink

The `title` value will be used to link the service to posts and procedures. The service content will be rendered on the service page, with only the excerpt being displayed on the service collection page.

#### Serivce Page

Each service has its own page with links to [Explainers](#explainers) and [Procedures](#procedures) related to that service. The individual service page is rendered by the `_layouts/service.html` file. The content is pulled from the individual service file in the `_services` collection. The layout is defined in the `_config.yml` file so that any page in the `_services` collection will use the `_layout/services.html` layout.

Explainers are posts containing a Front Matter `category` with a value of **explainer**. Explainer posts that have Front Matter `service` with a value matching the service title will be displayed in the **Learn more about...** section of the service page.

Procedures are a site collection named `_procedures` containing a Front Matter `service` with a value matching the service title. Procedures matching these values will be displayed in the **Do it yourself** section of the service page.

### Procedures

Procedures are a list of posts that show various ways of accomplishing some kind of task. A procedure will contain at least one of the following procedure types, although it will usually contain all three.

- **manual**: A step-by-step set of instructions for the procedure, usually involving using the GUI.
- **scripted**: A scripted method for performing the procedure, usually with PowerShell, Windows command line, or Bash.
- **devops**: An automated way of performing the procedure, usually with ARM templates or PowerShell DSC.

#### Procedure Collection

Procedures are defined by the `_procedures` collection. There is not a page to display all procedures, as that would be an unwieldy list. Instead an individual procedure has its own page which is linked from the parent service page. The procedure page will list any of the posts with a Front Matter `procedure` matching the name of the procedure.

#### Procedures

Procedures are simply posts that have have a Front Matter `procedure` value matching the `title` value of a procedure in the `_procedures` collection, and a Front Matter `category` value of the list at the beginning of [this section](#procedures).

### Explainers

Explainers are posts that descibe how a certain service works in plain English. They are intended to be an introduction for audiences that are not familiar with the topic where introductory information is not readily available.

Explainers are simply posts that have have a Front Matter `category` value of `thoughts`.

## Miscellaneous

SVG drawings made by Inkscape will have a leading prolog that will get rendered as escaped HTML when using the `include` Liquid tag. This prolog looks like this.

``` xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
```

As special include file of `svg.html` will properly render an embedded SVG file by removing the prolog if it exists. The syntax for using this include file is as follows.

```
{% include svg.html path="svg_file_render.svg" %}
```