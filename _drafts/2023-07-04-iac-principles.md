---
title: Infrastructure-as-Code Principles
categories: basics cloud_intro explainer
toc: true
---
Some people say platform infrastructure folks are really developers. Others say platform folks are mere humans and should not be allowed to make eye contact with developers. I have [opinions](/thoughts/thinking-like-a-developer), but no matter what you think, there are some ~~coding~~ universal practices that will help you in your platform role.

## Declarative Code

Declarative code sounds like one of those fancy terms, but is a pretty simple concept. Usually when you think of code, you think of *imperative* code. Imperative code is code that performs a bunch of logic and calculations to produce a result. It's an instruction set of "how" something should be done. It's pretty much what comes to mind when you picture code like JavaScript, Python, or C#.

Declarative code on the other hand describes "what" something should look like. But it doesn't care how it's done. HTML is declarative, and infrastructure-as-code like Terraform is declarative. Terraform code will simply say "we want a VM with 16 GB of memory and 2 vCPUs." That code is passed on to another process that will "make it so." Declarative code often is expected to be idempotent, as described in the next section.

For a great explanation of imperative versus declaractive code, see Yehuda Margolis's [Imperative vs Declarative Programming in JavaScript](https://www.linkedin.com/pulse/imperative-vs-declarative-programming-javascript-yehuda-margolis) article.

## Idempotency

You may have come across this word before and thought it was needlessly academic, but it's a real honest-to-God principle that you should think about while authoring infrastructure-as-code. In computery terms, **idempotency** means that when you do some activity with a set of inputs, that activity will yield the same result every time if you provide the same input. Here's an absurbly simple JavaScript example.

``` javascript
function idempotent(param1, param2) {
    return param1 + ' ' + param2;
}
```

You can call this function until you're blue in the face, but he result will be the same each time so long as you use the same parameters.

``` javascript
idempotent('Hello', 'World!')
// Result: 'Hello World!'
idempotent('Hello', 'World!')
// Result will still be: 'Hello World!'
idempotent('Foo', 'Bar')
// Result: 'Foo Bar'
idempotent('Foo', 'Bar')
// Oh wouldn't you guess? The result is again: 'Foo Bar'
```

Okay, here's one that is not idempotent because it is dependent on other factors that may change.

``` javascript
function notIdempotent(param1, param2) {
    return param1 + ' ' + param2 + ' ' + (new Date()).toUTCString();
}
```

As you can see, we threw in today's date and time. Time tends to change, typically in a forward direction. So each call is going to yield a different result, even if we use the same input.

``` javascript
notIdempotent('Hello', 'World!')
// Result: 'Hello World! Wed, 05 Jul 2023 09:25:17 GMT'
notIdempotent('Hello', 'World!')
// Result: 'Hello World! Wed, 05 Jul 2023 09:25:23 GMT'
// We ran it again 5 seconds later, so the output changed.
```

Idempotency alone isn't good or bad, it's just a thing. But when you are writing infrastructure-as-code, you'll want to be able to deploy the same infrastructure again and again and know exactly what it's going to produce. If you deploy an Apache web server one day and then run that exact same deployment the next day, you don't want it delete Apache and install Tomcat. Your developers are expecting an Apache server with some specific settings and you want to be able to deliver that exact same server configuration each time.

In the real world, you might have some infrastructure-as-code that you used to deploy to a test environment. Then you get a Slack message that, oops, an intern deleted the entire test environment. "No problem," you say, "just give me five minutes." You simply re-run the deployment and that test environment is back up! If the deployment was indeed idempotent, then the environment will be exactly the same as the first time you ran it.

# DRY

DRY is an acronym of *Don't Repeat Yourself*. If you see that your code has a lot of the same or similar content, you are violating the DRY principle. For example, if you create a Terraform module to deploy a VM that contains three virtual disks, the most straightforward way to do that would be to create three virtual disk resources. But that introduces some potential headaches down the line.

What if you need to add another disk? Then you need to copy and paste the virtual disk resource. You need to remember to change the disk name and other properties after you paste it, and we tend to forget to make all the changes.