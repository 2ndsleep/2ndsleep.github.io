---
title: Coding Principles
categories: basics iac explainer
sort_order: 4
description: Here are some basic concepts to help you write code better
---
Some people say platform infrastructure folks are really developers. Others say platform folks are mere humans and should not be allowed to make eye contact with developers. I have [opinions]({% post_url /thoughts/2024-01-31-thinking-like-a-developer %}), but no matter what you think, there are some ~~coding~~ universal practices that will help you in your platform role.<!--more-->

## Declarative Code

**Declarative code** sounds like one of those fancy terms, but is a pretty simple concept. Usually when you think of code, you think of **imperative** code. Imperative code is code that performs a bunch of logic and calculations to produce a result. It's an instruction set of "how" something should be done. It's pretty much what comes to mind when you picture code like JavaScript, Python, or C#.

Declarative code on the other hand describes "what" something should look like. But it doesn't care how it's done. HTML is declarative, and infrastructure as code like Terraform is declarative. Terraform code will simply say "we want a VM with 16 GB of memory and 2 vCPUs." That code is passed on to another process that will "make it so." Declarative code often is expected to be idempotent, as described in the next section.

For a great explanation of imperative versus declaractive code, see Yehuda Margolis's [Imperative vs Declarative Programming in JavaScript](https://www.linkedin.com/pulse/imperative-vs-declarative-programming-javascript-yehuda-margolis) article.

## Idempotence

You may have come across this word before and thought it was needlessly academic, but it's a real honest-to-god principle that you should think about while authoring infrastructure as code. In computery terms, **idempotence** means that when you do some activity with a set of inputs, that activity will yield the same result every time if you provide the same input. Here's an absurdly simple JavaScript example.

``` javascript
function idempotent(param1, param2) {
    return param1 + ' ' + param2;
}
```

You can call this function until you're blue in the face, but the result will be the same each time so long as you use the same parameters.

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

Idempotence alone isn't good or bad, it's just a thing. But when you are writing infrastructure as code, you'll want to be able to deploy the same infrastructure again and again and know exactly what it's going to produce. If you deploy an Apache web server one day and then run that exact same deployment the next day, you don't want it delete Apache and install Tomcat. Your developers are expecting an Apache server with some specific settings and you want to be able to deliver that exact same server configuration each time.

IaC code tends to be idempotent unless you go out of your way to make it dynamic by depending on random number generators or datetime values, so knowing about idempotence is a little show-offy if you work with people who don't like you talking fancy to them.

## DRY

**DRY** is an acronym of **Don't Repeat Yourself**. If you see that your code has a lot of the same or similar content, you are violating the DRY principle. For example, let's say that you have a Terraform configuration that deploys two Linux VMs for your new product called Badass™. What does Badass do? Mess around and find out! Anyway, one VM is for a database and the other for a web service. The database will need a large disk but the web service won't be saving anything to disk so it can keep the standard size. Otherwise, everything else about the VMs would be the same.

Well, you could approach it by creating two different virtual machines like this.

{% highlight terraform linenos %}
resource "azurerm_linux_virtual_machine" "database" {
  name                = "database"
  resource_group_name = "{{ site.data.fake.company_code }}-badass"
  location            = "centralus"
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  network_interface_ids = [
    "/subscriptions/{{ site.data.fake.subscription_guid }}/resourceGroups/{{ site.data.fake.company_code }}-badass/providers/Microsoft.Network/networkInterfaces/{{ site.data.fake.company_code }}-badass-nic-db"
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 1023
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  name                = "web"
  resource_group_name = "{{ site.data.fake.company_code }}-badass"
  location            = "centralus"
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  network_interface_ids = [
    "/subscriptions/{{ site.data.fake.subscription_guid }}/resourceGroups/{{ site.data.fake.company_code }}-badass/providers/Microsoft.Network/networkInterfaces/{{ site.data.fake.company_code }}-badass-nic-web"
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
{% endhighlight %}

Notice the only differences are that lines 1, 2, 8, and 19 differ from lines 30, 31, 37, and 48. Everything else is exactly the same. You could instead use a loop to only change the values you care about.

{% highlight terraform linenos %}
locals {
  vm_configs = {
    database = {
      nic = "/subscriptions/{{ site.data.fake.subscription_guid }}/resourceGroups/{{ site.data.fake.company_code }}-badass/providers/Microsoft.Network/networkInterfaces/{{ site.data.fake.company_code }}-badass-nic-db"
      disk_size_gb = 1023
    }
    web = {
      nic = "/subscriptions/{{ site.data.fake.subscription_guid }}/resourceGroups/{{ site.data.fake.company_code }}-badass/providers/Microsoft.Network/networkInterfaces/{{ site.data.fake.company_code }}-badass-nic-web"
      disk_size_gb = 30
    }
  }
}

resource "azurerm_linux_virtual_machine" "badass" {
  for_each            = local.vm_configs
  name                = each.key
  resource_group_name = "{{ site.data.fake.company_code }}-badass"
  location            = "centralus"
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  network_interface_ids = [
    each.value.nic
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = each.value.disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
{% endhighlight %}

Don't worry if you don't understand what's going on line-by-line here, because we'll go over these things slowly in future posts.
{: .notice--info}

As you can see, we first created a local variable that defined the properties that were unique to each VM. Then we used a loop to create two identical VMs, but with different names, virtual network interfaces, and disk sizes. We realize afterwards that our workload is light enough that we can downgrade our VM size, so we change line 19 to `size = "Standard_B1s"` and redeploy the configuration.

Oh look, we were able to raise $2 million in Series A funding just from the tagline for Badass™. We better figure out what this product does so we can start developing it. Technology!
{: .notice--info}