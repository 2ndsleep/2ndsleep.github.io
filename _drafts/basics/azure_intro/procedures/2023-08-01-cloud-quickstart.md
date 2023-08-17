---
title: Your First Cloud Resource
categories: basics azure_intro procedure
toc: true
sort_order: 0
---
If you are brand new to the cloud, it's time to get your hands dirty! <!--more-->Honestly, these tutorials won't teach you a ton about platform engineering, but creating your first resources will be a Karmic experience, connecting you to the cloud universe in a burst of ecstatic energy that will leave you viewing the world in a completely different way. 

We're going to start with a resource type that you may surprisingly find you won't be using that often (depending on the industry you're in): virtual machines. Each cloud provider has perfectly good tutorials in their documentation, so this is just going to be a link to each tutorial. Both of these tutorials are for creating Linux VMs through the user interface, but you'll see options in the left navigation pane for a Windows VM if that's your thing.

- **Azure**: [Quickstart: Create a Linux virtual machine in the Azure portal](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal?tabs=ubuntu)
- **Google Cloud**: [Create a Linux VM instance in Compute Engine](https://cloud.google.com/compute/docs/create-linux-vm-instance)

In the Google Cloud tutorial under the **Create a Linux VM instance** section, it says to go to the **Create an instance** page, but that doesn't seem to appear either in the console home or the Compute Engine API page. In my testing, I had to go back to my [home console](https://console.cloud.google.com/welcome/new) and click the **Create a VM** button under the **Products** section.
{: .notice--warning}