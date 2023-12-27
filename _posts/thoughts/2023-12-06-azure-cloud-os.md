---
title: The Azure Cloud Operating System
category: thoughts
toc: true
---
If you read my post about the [history of the cloud]({% post_url /learn/basics/cloud_intro/explainers/2023-12-03-what-is-the-cloud %}), you may be thinking that I've skipped over some important steps on the cloud story. In short, I said that the cloud is built on virtualization. But if you've dipped your toe in the cloud world, you'd know that most cloud providers offer more than just virtual machines. You may know that they offer other services like storage, databases, and virtual networking.

## Cloud Operating System

Cloud providers each have their own cloud operating system. In Azure's case, the cloud operating system consists of two main parts: the **fabric controller** and the **orchestrator**.

Let's start with the fabric controller. Each Azure datacenter is filled with tons of racks that are each filled with physical servers. The servers on these racks are capable of spinning up virtual machines. The thing that tells these servers when and what type of virtual machine to spin up is managed by the fabric controller that runs on each rack.

The orchestrator runs separately from these racks and is charge of sending the appropriate commands to the appropriate fabric controller. When you request a new VM from the Azure portal, that command will go to the orchestrator. The orchestrator will decide which fabric controller agent to send the request. (Technically, the request from the portal will go to an API that will then be sent to the orchestrator.)

Actually, this video probably explains everything better than I did:

<div class="responsive-video-container">
  <iframe src="https://www.microsoft.com/en-us/videoplayer/embed/RE2ixGo?postJsllMsg=true" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowfullscreen></iframe>
</div>

## More Than VMs

Any of the discussions I've seen about the Azure cloud operating system always use the example of creating VMs. But there's so much to Azure, you might be wondering what about all those other resource types, like databases and storage accounts. Well, almost everything that is created by the cloud operating system is one or more VMs of some sort. If you request a Windows VM, well that will obviously be a VM. But if you create an Azure SQL Server, that will create a few VMs that you can't see but are there behind the scenes.

What if you create a virtual network or storage account? Is a VM created? Actually, I don't know the answer to that, but my guess is that for a virtual network, it's a VM with some type of proprietary network appliance is created. For a storage account, I'm guessing that it's some type of shared infrastructure that's managed by the orchestrator. I've Googled the hell out of this and can't find an explanation so if anyone knows or can point me to white papers or videos that describe the Azure cloud OS in more detail, please let me know.
{: .notice--info}

## Azure Is Always Changing

The Azure infrastructure is always changing. Check out this video for the most recent updates from 2023:

{% include video id="sgIBC3yWa-M" provider="youtube" %}