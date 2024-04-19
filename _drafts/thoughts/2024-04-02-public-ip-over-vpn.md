---
title: Routing a Public IP Over a VPN Connection
category: thoughts
tags: vpn vpn-gateway virtual-network
toc: true
---
{% assign ip_clearinghouse_peer = 'c.c.p.p' %}
{% assign ip_org_peer = 'o.o.p.p' %}
{% assign ip_org_app_public = 'o.o.a.a' %}
{% assign net_clearinghouse_app_public = 'c.c.a.a/x' %}
{% assign net_org_app = '10.0.20.0' %}
{% assign ip_org_app = '10.0.20.32' %}
{% assign ip_org_app_router = '10.0.20.8' %}
{% assign netmask_org_app = 24 %}
{% assign port_org_app = 5000 %}
{% assign net_org_routing = '10.0.16.0' %}
{% assign netmask_org_routing = 24 %}
{% assign ip_org_routing_router = '10.0.16.8' %}
{% assign ip_org_routing_router_azure_gateway = '10.0.16.1' %}
{% assign ip_vyos_vti = '192.168.128.1' %}
{% assign netmask_vyos_vti = 24 %}

Each industry has its weird little standards. When I worked in the pharmacy space, that weird little standard was how you had to route certain public IP addresses over a private VPN.<!--more--> When I first came across this, I scratched my head as to why they did it this way. Then I had to figure out how to do this in a virtual cloud environment. Then I balled up my fists and screamed. Then I figured it out and went and got a beer. It was a tumultuous, exhilarating time!

## The Problem

Since this was required to process pharmacy payments, let me first offer the briefest background on how retail pharmacies process claims. When it's time to pick up your pills (none of my business what it's for), the pharmacy tech sends your prescription and insurance information to your insurance company. The insurance company responds back immediately with how much they will reimburse the pharmacy and how much the patient owes. It's actually a pretty well-oiled machine.

But just like every other part of the medical industry, there is a middleman in this process. Each pharmacy doesn't make a direct connection to each of the roughly [66 pharmacy insurers](https://content.naic.org/cipr-topics/pharmacy-benefit-managers) in the US. Instead, a pharmacy makes a connection to something known as a **clearinghouse** that relays the claim to the correct insurance company. The clearinghouse is like a hub in the middle of a wagon wheel. It connects to all the pharmacies and all the insurance companies.

{% capture pharmacy_attribution %}
{% include attribution.html title='house' image_link='https://commons.wikimedia.org/wiki/File:House.svg' author='barretr (Open Clip Art Library)' author_link='http://openclipart.org/media/people/barretr' license='CC0' license_link='https://creativecommons.org/publicdomain/zero/1.0/deed.en' %}<br />
{% include attribution.html title='office building' image_link='https://commons.wikimedia.org/wiki/File:587-office-building.svg' author='Vincent Le Moign' author_link='https://twitter.com/webalys' license='CC BY 4.0' license_link='https://creativecommons.org/licenses/by/4.0' %}
{% endcapture %}

{% include svg.html path="svg/pharmacy-clearinghouse.svg" caption="Who would have guessed that any part of the American healthcare system is actually efficient?" attribution=pharmacy_attribution %}

<p class="notice--info">My experience with this is only in the pharmacy space, but my understanding is that this model is the same for medical claims processing.<br /><br />For stupid historical reasons, the pharmacy coverage part of your medical insurance is technically known as a pharmacy benefit manager or PBM. If you find yourself at a dinner party sitting next to someone in the retail pharmacy space, use the term "PBM" and watch their face light up and buckle in for a really boring conversation.</p>

Here's a rapid fire set of concepts to know for the rest of this article.

- The insurance company is known as the **payer**. Payers can be any entity that processes a claims (e.g., pharmacy discount cards).
- When the payer processes claims, it's known as **adjudication**.
- The adjudication process has been around since before web services were popular, so this connection is made over TCP sockets (which is why we need the VPN connection in the first place). Some clearinghouses are developing REST services, so hopefully this whole networking model will be a thing of the past in a few years.

### Public IP Addresses to the Rescue

On to the technical problem. Each payer that wants to communicate with the clearinghouse will need some type of network connection. This often will be a site-to-site VPN connection. But when you traditionally think about a corporate site-to-site VPN, you're usually connecting two or more separate private networks that are controlled by the organization. This means you can ensure that each site has a separate private address space that doesn't overlap. For instance, your small satellite office in San Francisco, CA may have the 192.168.0.0/24 address space whereas your gigantic headquarters in Boerne, TX has the 10.0.0.0/12 address space.

If you're not a network person, there's two types of IPv4 addresses: public and private. Private addresses can be assigned however you want in your private network but cannot be used on the public internet. Since private addresses can be assigned however you want, there's no guarantee that the private address space that the clearinghouse has available will be available on your network. In a perfect world, the clearinghouse would have the same unused private subnet as your organization does. Also, in a perfect world, there would be no disease and we wouldn't need pharmaceutical companies at all, but that's not our reality.

Since public IP addresses are guaranteed to be unique, the clearinghouses have chosen to use that as their solution. So you assign a public IP address to your adjudication endpoint where the clearinghouse will establish a TCP connection. The whole thing looks something like this:

{% capture vpn_overview_attribution %}
{% include attribution.html title='house' image_link='https://commons.wikimedia.org/wiki/File:House.svg' author='barretr (Open Clip Art Library)' author_link='http://openclipart.org/media/people/barretr' license='CC0' license_link='https://creativecommons.org/publicdomain/zero/1.0/deed.en' %}<br />
{% include attribution.html title='firewall' image_link='https://commons.wikimedia.org/wiki/File:Breezeicons-apps-48-firewall-config.svg' author='Uri Herrera and others, KDE Visual Design Group' author_link='https://github.com/KDE/breeze-icons/blob/master/COPYING-ICONS' license='LGPL' license_link='https://www.gnu.org/copyleft/lgpl.html' %}
{% endcapture %}

{% include svg.html path="svg/public-ip-over-vpn-overview.svg" caption="Public IP over VPN high-level network design" attribution=vpn_overview_attribution %}

Using public IPs ensures that there are no IP address collisions like you potentially would have if you were only connecting private networks. There is nothing in the IPSec VPN specifications that say you can't use public IP addresses, but it's a departure from how you regularly do things so it takes some noodling to get it right.

If you've dealt with IP conflicts in the past, you may be thinking that VPN SNAT would be a solution that the clearinghouses could have used. I don't know why they don't offer that, but my guess is that their customers may find that managing SNAT introduces more complexities for both parties than the public IP solution.
{: .notice--info}

### Challenges in Azure

This can be done with native Azure services, but there are some challenges.

The main challenge is that Azure VPN Gateway does not support DNAT. As you recall, the clearinghouse will be sending packets over the VPN to a public IP address. We need to translate that destination public IP address to the private IP address associated with our application, but the VPN Gateway lacks any DNAT feature. If you Google it you may discover that all but the cheapest SKUs support [NAT](https://learn.microsoft.com/en-us/azure/vpn-gateway/nat-overview). But this is only source NAT. Even if the source is translated, the destination will still go to our public IP address.

But hmmm, you think. Maybe you could game the system and route to that public IP through Azure's software-defined networking, you think. Since the packets to our application's public IP can route over the VPN we could assign the public IP to a VM and let it just route that last little bit over the public internet, is your thought. After all, since this will be going from one Azure resource (VPN Gateway) to another Azure resource (VM), it will probably stay within the edge of the Microsoft global network ([cold potato routing](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/routing-preference-overview#routing-via-microsoft-global-network)), such is your thinking.

Shame on you for such sinful thoughts! That network is still untrusted! But even if your CSO approved such a hairbrained scheme, the Azure VPN Gateway [does not allow internet access](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-p2s-advertise-custom-routes#forced-tunneling), so you can give up on the idea.

## Preparation

There's a handful of ways to tackle this in Azure, including some bad ideas that I'll show you! First, gather the following networking information. I'll reference these throughout the rest of this article.

|IP Address or Network|Visibility|Owner|Description|Example Used|
|------------------|----------|-----|-----------|-------|
|Your IPSec VPN peer|public|you|Public IP address of your IPSec peer. This will either be assigned to your NVA or your Azure VPN Gateway.|{{ ip_org_peer }}|
|Clearinghouse IPSec VPN peer|public|clearinghouse|Public IP address of the clearinghouse's IPSec peer.|{{ ip_clearinghouse_peer }}|
|Adjudication public endpoint|public|you|Public IP address of your adjudication application that the clearinghouse connects to. This will be NAT'ed to the private IP.|{{ ip_org_app_public }}
|Adjudication private endpoint|private|you|Private IP address of your adjudication application. This will probably be a VM, AKS, or a load balancer.|{{ ip_org_app }}|
|Adjudication application subnet|private|you|Azure virtual network subnet where your adjudication application instance(s) will live. We'll be calling this the **adjudication** subnet.|{{ net_org_app }}/{{ netmask_org_app }}|
|Clearinghouse source subnet|public|clearinghouse|Public IP subnet of traffic originating from the clearinghouse.|{{ net_clearinghouse_app_public }}|
|Routing subnet|private|you|Azure virtual network subnet used by your NVA or custom router. We'll be calling this the **routing** subnet.|{{ net_org_routing }}/{{ netmask_org_routing }}|
|Router **routing** NIC IP|private|you|Private IP addressed assigned to the NIC in the **routing** subnet of your NVA or custom router. This will be the next-hop to the adjudication public IP address (`{{ ip_org_app_public }}`) on the route table assigned to the Azure VPN Gateway subnet when using a custom VM router.|{{ ip_org_routing_router }}|
|Router **adjudication** NIC IP|private|you|Private IP addressed assigned to the NIC in the **adjudication** subnet of your router. This will be the next-hop to the clearinghouse network (`{{ net_clearinghouse_app_public }}`) on the route table associated with the adjudication subnet when using an NVA.|{{ ip_org_app_router }}|

You will provision the public IP address for the adjudication public endpoint but won't actually associate it to an Azure resource. This public IP will be translated to the private IP address of your adjudication private endpoint by a NAT rule inside your NVA or custom router VM. You can acquire this public IP from Azure or from another vendor. If you purchase it from Azure, you simply buy a static public IP resource and then let it sit there. The point is to remove the IP from the global address pool so that it's not used for something else.
{: .notice--info}

This post assumes that you have two separate subnets defined in your virtual network infrastructure: **adjudication** and **routing**. Furthermore, it is assumed that the adjudication subnet only contains resources related to your adjudication services, such as VMs and load balancers and that your routing subnet is only used for your NVA or custom router VM.
{: .notice--info}

## Generic Configuration

This is the configuration that will be common to all scenarios.

|Configuration|NVA Solution Implementation|Azure VPN Gateway Implementation|
|-------------|---------------------------|--------------------------------|
|Translate adjudication endpoint public IP to private IP|DNAT rule within NVA|`iptables` or `NetNat` PowerShell module|
|Route to adjudication public endpoint|Static route to VNet subnet within NVA|Route table associated with VPN Gateway subnet|
|Route to clearinghouse network|Static route to clearinghouse subnet over VPN within NVA **and** route table associated with adjudication application subnet|Route table associated with adjudication application subnet (VPN Gateway should already have implicit route to clearinghouse)|

1. Configure a NAT rule on your network solution to translate your adjudication endpoint's public IP to its private IP (`{{ ip_org_app_public }}` :arrow_right: `{{ ip_org_app }}`).
1. Configure routing from your VPN to the public IP address of your application (`{{ ip_org_app_public }}`). This will be configured within your NVA or as a route table associated with your VPN Gateway subnet. (Some NVA routers may define this route automatically as part of the NAT definition.)
1. Configure routing from your application to the public subnet of the clearinghouse (`{{ net_clearinghouse_app_public }}` :arrow_right: VPN). This will require a route table associated with the subnet where your adjudication application service lives.
1. **Allow access for your adjudication application's port through all appropriate NSGs and/or NVA access rules.** Don't forget about this when troubleshooting any solution your implement!

The adjudication subnet will need a route to the clearinghouse network as will any other applications that need to contact the clearinghouse. The clearinghouse will probably provide an IP address that you can ping for a health probe, so consider any subnets where your probes may live.
{: .notice--info}

## Solution: Network Virtual Appliance (Good Idea)

The best way to do this is to use a network virtual appliance (NVA). An NVA is virtual router from a non-Microsoft vendor of your choosing (Cisco, Palo Alto, Fortinet, etc.) that you can purchase from the Azure marketplace. This is like plopping a physical router that you're already familiar with in Azure (but it's like, virtual, man) and grants you complete control over your networking infrastructure, including the VPN connection, routing, and NAT. If you already have experience using, say, a Cisco device, you can apply all of your existing knowledge to the NVA without having to learn a new Azure networking service. The downside is that this can be a bit costly since you'll be paying for the underlying Azure VM that the NVA runs on plus a premium for the vendor's product license.

{% capture nva_attribution %}
{% include attribution.html title='house' image_link='https://commons.wikimedia.org/wiki/File:House.svg' author='barretr (Open Clip Art Library)' author_link='http://openclipart.org/media/people/barretr' license='CC0' license_link='https://creativecommons.org/publicdomain/zero/1.0/deed.en' %}<br />
{% include attribution.html title='physical router image' image_link='https://commons.wikimedia.org/wiki/File:Router.svg' author='George Shuklin' author_link='https://commons.wikimedia.org/wiki/User:George_Shuklin' license='Creative Commons Attribution-Share Alike 3.0 Unported' license_link='https://creativecommons.org/licenses/by-sa/3.0/deed.en' %}
{% endcapture %}

{% include svg.html path="svg/public-ip-over-vpn-nva.svg" caption="Public IP over VPN NVA network design" attribution=nva_attribution %}

Since this can be any type of device, I'm not going to show you how to do it, but you'll want to do the following in general on the NVA.

1. Create your NVA resource in Azure and with at least two NICs.
  - Assign a private static IP (`{{ ip_org_routing_router }}`) to the first NIC on the **routing** subnet.
  - Assign a static public IP address (`{{ ip_org_peer }}`) to the first NIC that will be used for the VPN peer. This is *not* the same as the public IP address for your application endpoint. (This public IP may also be used as your management access point, depending on the vendor.)
  - Assign a private static IP (`{{ ip_org_app_router }}`) to the second NIC on the **adjudication** subnet.
1. Establish a VPN connection to the clearinghouse's IPSec peer IP (`{{ ip_clearinghouse_peer }}`).
1. Create a NAT rule to translate your application's public IP address to its private address (`{{ ip_org_app_public }}` :arrow_right: `{{ ip_org_app }}`).
1. If necessary, create a NAT rule to translate your application's private IP address to its public address (`{{ ip_org_app }}` :arrow_right: `{{ ip_org_app_public }}`). For some routers, this may have been done as part the previous step.
1. If necessary, create a route to the clearinghouse's public IP over the VPN (`{{ net_clearinghouse_app_public }}` :arrow_right: VPN). For some routers, this route is inferred from the VPN.

You will also need to create an [Azure Route Table](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table#create-a-route-table) with a route to the NVA and associate it with the **adjudication** subnet and any other subnet that needs to access the clearinghouse network. Without this, our adjudication app will assume that traffic to `{{ net_clearinghouse_app_public }}` should go through the internet. In our example, the route table would contain a route with these properties.

|**Destination type**|IP Addresses|
|**Destination IP addresses**|{{ net_clearinghouse_app_public }}|
|**Next hop type**|Virtual appliance|
|**Next hop address**|{{ ip_org_app_router }}|

## Solution: Azure VPN Gateway + Custom VM Router (Bad Idea)

If your company is bordering on bankruptcy and needs to do this on the cheap, you can build your own router using a Linux or Windows VM. If that's your situation, well it's concerning that you're in the healthcare space. But on the other hand, this solution works just fine and I don't see any obvious security risks. It just doesn't feel right. In any case, here's how you do it.

This solution involves two parts: an Azure VPN Gateway and either a Linux or Windows Server VM and the architecture looks like this:

{% capture custom_router_attribution %}
{% include attribution.html title='house' image_link='https://commons.wikimedia.org/wiki/File:House.svg' author='barretr (Open Clip Art Library)' author_link='http://openclipart.org/media/people/barretr' license='CC0' license_link='https://creativecommons.org/publicdomain/zero/1.0/deed.en' %}
{% endcapture %}

{% include svg.html path="svg/public-ip-over-vpn-custom-vm.svg" caption="Public IP over VPN custom router VM network design" attribution=custom_router_attribution %}

### Azure VPN Gateway

You'll first need a VPN connection betwixt the clearinghouse and the Azure virtual network where your adjudication application lives. I can't provide a step-by-step for this since it will depend on the clearinghouse, but Microsoft has a [tutorial](https://learn.microsoft.com/en-us/azure/vpn-gateway/tutorial-site-to-site-portal) for a site-to-site VPN Gateway connection. This is always the tricky part and will probably involve some back and forth with the clearinghouse technician. You probably won't get it right the first time, so be prepared for this to potentially take a few days to get squared away.

The frustrating thing is that the Azure VPN Gateway lacks real-time [logging](https://learn.microsoft.com/en-us/azure/vpn-gateway/troubleshoot-vpn-with-azure-diagnostics) which makes troubleshooting a slog. Below are my suggestions for items to check. The Azure VPN Gateway resource itself doesn't have a lot of configuration. Most of the settings for the configuration are found on the connection listed in the **Connections** blade of the VPN Gateway resource in the portal. The connection resource will have a link to the associated local network gateway resource that defines certain properties for the clearinghouse's side of the connection.

- Check Microsoft's recommended [site-to-site VPN troubleshooting](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-troubleshoot-site-to-site-cannot-connect) list.
- Ensure that the basic configuration items are correct, like the pre-shared key (PSK) and IPSec peer addresses (yours and the clearinghouse's side).
- Check that the [default cryptographic policies](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices#ipsec) will work for your clearinghouse. If not, you can use a [custom configuration](https://learn.microsoft.com/en-us/azure/vpn-gateway/ipsec-ike-policy-howto) for your connection.
- Check if the clearinghouse uses a policy- or route-based gateway. If policy-based, enable the policy-based traffic selector option and define the custom traffic selectors.
- On the local network gateway resource, ensure that the address space for the clearinghouse's public IP address range is correct.

### Route Tables

You will need to create two [Azure Route Tables](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table#create-a-route-table) so that the VPN Gateway knows where the adjudication application IP is and the so that the adjudication application knows how to get back to the clearinghouse.

Create a route table with a route that has the following properties and associate it with your **GatewaySubnet** subnet. (If you don't remember adding this subnet, you're not crazy. This subnet is created automatically when you create the VPN Gateway.)

|**Destination type**|IP Addresses|
|**Destination IP addresses**|{{ ip_org_app_public }}/32|
|**Next hop type**|Virtual appliance|
|**Next hop address**|{{ ip_org_routing_router }}|

Create a route table with a route that has the following properties and associate it with your **adjudication** subnet. Without this, our adjudication app will assume that traffic to `{{ net_clearinghouse_app_public }}` should go through the internet.

|**Destination type**|IP Addresses|
|**Destination IP addresses**|{{ net_clearinghouse_app_public }}|
|**Next hop type**|Virtual network gateway|
|**Next hop address**|n/a|

### Custom VM Router

The first step is to create a VM. The Linux example here will use Debian, so choose that option unless you're comfortable configuring networking on other distributions.

1. Create your Debian Linux or Windows Server VM with a static private IP address (`{{ ip_org_routing_router }}`) in the **routing** subnet.
1. [Enable IP forwarding](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface?tabs=azure-portal#enable-or-disable-ip-forwarding) on the NIC for the VM.
1. [Create a second NIC](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface-vm#add-a-network-interface-to-an-existing-vm) on the VM with a static private IP address (`{{ ip_org_app_router }}`) in the **adjudication**.
1. [Enable IP forwarding](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface?tabs=azure-portal#enable-or-disable-ip-forwarding) on the second NIC.

If this is an existing environment, you likely already have opened up the appropriate SSH or RDP access to your VMs. If not, you can use the [serial console](https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/windows/serial-console-overview) to access the command line of your VMs.

#### Linux Router

Even though the NICs on our VM allow forwarding, we also need to tell the Linux OS that forwarding is allowed. Edit the `/etc/sysctl.conf` file with your favorite editor, for example:

``` shell
sudo nano /etc/sysctl.conf
```

Uncomment `net.ipv4.ip_forward` line or edit the file so that you have the following entry:

{% highlight console %}
net.ipv4.ip_forward=1
{% endhighlight %}

Run the following command to enable forwarding immediately.

``` shell
sudo sysctl -p
```

First, let's confirm the name of our NIC that's in our routing subnet.

``` shell
ip addr
```

See which NIC has the IP address associated with your routing subnet. It will probably be `eth0`, but if it's different use the correct name in the command below. Now let's add an `iptables` NAT rule to translate the adjudication endpoint public IP to its private IP.

``` shell
sudo apt update
sudo apt install iptables
sudo iptables -t nat -A PREROUTING -i eth0 -d {{ ip_org_app_public }} -j DNAT --to-destination {{ ip_org_app }}
```

You can confirm the rule is there with this command:

``` shell
sudo iptables -L -n -t nat --line-numbers
```

Your NAT rule will disappear upon restarting your VM, so you can use `iptables-persistent` to reload them upon reboot.

``` shell
sudo apt install iptables-persistent
sudo netfilter-persistent save
```

#### Windows Server Router

This idea is even worse than the Linux router. The main reason is that Windows isn't designed for sophisticated routing, so the best we can do is translate individual ports. To do this, you have to assign your adjudication application's public IP as an additional IP to the NIC on the routing subnet. The side effect is that, by default, when you ping the adjudication application's public IP address, the Windows Server router will respond. This can be confusing when you're troubleshooting. This whole thing is dumb and I hope you don't do it. But here's how.

First, open a PowerShell prompt. Ugh, I don't already like this first step to disable the Windows firewall. Only do this if this is a test server or if you're initially configuring the server. After you get this working, re-enable the firewall with the appropriate holes punched through for your adjudication application.

``` powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

Next, let's make this VM a router. *This will restart your VM.*

``` powershell
Add-WindowsFeature RemoteAccess, Routing -IncludeAllSubFeature -IncludeManagementTools -Restart
```

Next let's find the names of your NICs so that we can rename them to ensure our next script will run appropriately. Run the following command.

``` powershell
Get-NetAdapter | Get-NetIPAddress -AddressFamily IPv4
```

Note the `InterfaceAlias` values for each NIC and use it to replace the values of `$OriginalRoutingNicAlias` and `$OriginalAdjudicationNicAlias` below. Replace all the other variables with the correct values. And of course, modify this script to suite your needs.

``` powershell
$OriginalRoutingNicAlias = 'Ethernet1'
$OriginalAdjudicationNicAlias = 'Ethernet2'
$AdjudicationAppPublicIP = '{{ ip_org_app_public }}'
$RoutingSubnetNicIP = '{{ ip_org_routing_router }}'
$RoutingSubnetAzureGatewayIP = '{{ ip_org_routing_router_azure_gateway }}'
$RoutingSubnetMask = {{ netmask_org_routing }}
$AdjudicationAppPrivateIP = '{{ ip_org_app }}'
$AdjudicationAppTcpPort = {{ port_org_app }}

# Rename the NICs. It's just nice that way.
Rename-NetAdapter -Name $OriginalRoutingNicAlias -NewName Routing
Rename-NetAdapter -Name $OriginalAdjudicationNicAlias -NewName Adjudication

# Add the adjudication application public IP address to the routing NIC.
# First, manually assign the private IP to the routing NIC. (We can't have a mix of DHCP and static, so we need to re-assign the routing NIC it's original IP address.)
New-NetIPAddress -InterfaceAlias Routing -AddressFamily IPv4 -IPAddress $RoutingSubnetNicIP -PrefixLength $RoutingSubnetMask -DefaultGateway $RoutingSubnetAzureGatewayIP
New-NetIPAddress -InterfaceAlias Routing -AddressFamily IPv4 -IPAddress $AdjudicationAppPublicIP -PrefixLength 32

# Make this VM a router.
Install-RemoteAccess -VpnType RoutingOnly

# Create NAT rule to translate the adjudication app public IP to the private IP.
New-NetNat -Name AppEndpoint -ExternalIPInterfaceAddressPrefix "$AdjudicationAppPublicIP/32"
Add-NetNatExternalAddress -NatName AppEndpoint -IPAddress $AdjudicationAppPublicIP
Add-NetNatStaticMapping -NatName AppEndpoint -ExternalPort $AdjudicationAppTcpPort -InternalPort $AdjudicationAppTcpPort -ExternalIPAddress $AdjudicationAppPublicIP -InternalIPAddress $AdjudicationAppPrivateIP -Protocol TCP
```

Easy, right?

## Solution? Azure Firewall? (An Idea)

Theoretically, you could use an Azure VPN Gateway in combination with an [Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/overview) to do the NATing, but I couldn't get it to work. Here's the path I traveled...

Azure Firewall supports [DNAT](https://learn.microsoft.com/en-us/azure/firewall/basic-features#inbound-dnat-support). Oh great, there's our solution right there. But it turns out they don't mean any arbitrary DNAT; it's specifically DNAT to the Firewall's public IP address to a backend private address, kind of like a reverse proxy. Okay, that won't work because the destination public IP is to our adjudication app, not the IP address of our Azure Firewall.

The documentation says that you can use [public IP addresses in your private networks](https://learn.microsoft.com/en-us/azure/firewall/basic-features#outbound-snat-support). That leads to [this excellent article](https://techcommunity.microsoft.com/t5/azure-network-security-blog/azure-firewall-nat-behaviors/ba-p/3825834) about NAT behaviors in Azure Firewall. If you scroll down to the subheading **East-West Traffic Flow (IANA RFC 1918 & IANA RFC 6598)**, it describes what appears to be almost exactly what we're trying to do. From my understanding, if you assign a public IP to your VM or use a public load balancer, you can create an Azure Firewall network rule to allow traffic to the public IP and Azure Firewall will magically find the private route to your resource. You'll probably also want to set the **Private IP ranges (SNAT)** to *Never* or at least exclude the public IP address.

However, I just couldn't get this to work. The Azure Firewall logs showed that the network rule was allowing the traffic to the public IP, but there was no evidence that my test adjudication endpoint was receiving any traffic. If anyone has better luck with this solution, I'd love to hear it!

## Bonus: Simulating the Clearinghouse

If you want to test this out before engaging your clearinghouse, you can try to simulate the clearinghouse VPN connection from your home or office. I simulated the IPSec VPN connection by using the free [VyOS router](https://vyos.org) on a VM on my MacBook. The VyOS router does not have to be directly attached to your ISP's public IP if you allow the correct port forwarding, which should be supported even on your home router/firewall.

I used VyOS version 1.5 for this example with a little help from the [Route-Based Site-to-Site VPN to Azure (BGP over IKEv2/IPsec)](https://docs.vyos.io/en/equuleus/configexamples/azure-vpn-bgp.html) documentation. Note that some of the commands on that page are slightly different for version 1.5.
{: .notice--info}

First, allow access and/or enable port forwarding for the following ports through all of your routers on the path to your VyOS VM. (Note, this will vary depending on your networking infrastructure and may not be possible at all. If it's not possible, then your SOL for this section.)

- UDP 500
- UDP 1701
- UDP 4500

Download a free [nightly build](https://vyos.org/get/) of VyOS and [install](https://docs.vyos.io/en/equuleus/installation/install.html#permanent-installation) on your VM platform of choice. For this example, my VM has only one virtual NIC in bridged mode so that it connects to the same network as my VM host.

Back at my physical router, I created a DHCP reservation for my VM to make the rest of this a little easier.

After your VM restarts, log into the VyOS and check the name of your NIC. If it's different than `eth0`, use that value in place of `eth0`.

``` shell
show interfaces
```

Now go to configuration mode.

``` shell
configure
```

I strongly suggest you [change your password](https://docs.vyos.io/en/latest/configuration/system/login.html#local) at this point.
{: .notice--info}

At any point in the rest of this procedure, you can make your changes take effect by using `commit` command and save the changes to disk to preserve your changes after a reboot with the `save` command.
{: .notice--info}

Configure your NIC to use DHCP.

``` shell
set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth0 description Public
```

Optionally, set the DNS server in case you need to resolve an internet name. This will probably be the same DNS server that your VM host uses.

``` shell
set system name-server <IP of your home/business router DNS server>
```

Create a virtual tunnel interface (VTI). This is required to create a route-based VPN. The IP address can be any private IP that is not being used.

``` shell
set interfaces vti vti0 address {{ ip_vyos_vti }}/{{ netmask_vyos_vti }}
set interfaces vti vti0 description "Azure tunnel"
```

Create your phase 1 and 2 configurations. Each of these groups will be named `azure`.

``` shell
set vpn ipsec ike-group azure dead-peer-detection action restart
set vpn ipsec ike-group azure dead-peer-detection interval 15
set vpn ipsec ike-group azure dead-peer-detection timeout 45
set vpn ipsec ike-group azure ikev2-reauth
set vpn ipsec ike-group azure key-exchange ikev2
set vpn ipsec ike-group azure lifetime 28800
set vpn ipsec ike-group azure proposal 1 dh-group 2
set vpn ipsec ike-group azure proposal 1 encryption aes256
set vpn ipsec ike-group azure proposal 1 hash sha256

set vpn ipsec esp-group azure lifetime 27000
set vpn ipsec esp-group azure mode tunnel
set vpn ipsec esp-group azure pfs dh-group2
set vpn ipsec esp-group azure proposal 1 encryption aes256
set vpn ipsec esp-group azure proposal 1 hash sha256
```

Enable IPSec on `eth0`.

``` shell
set vpn ipsec interface eth0
set vpn ipsec options disable-route-autoinstall
set vpn ipsec options interface eth0
```

Configure authentication settings.

``` shell
set vpn ipsec authentication psk azure id {{ ip_clearinghouse_peer }}
set vpn ipsec authentication psk azure secret "use anything but this exact value here"
```

Configure your site-to-site connection we'll be calling "azure."

``` shell
set vpn ipsec site-to-site peer azure authentication local-id <your local IP>
set vpn ipsec site-to-site peer azure authentication mode pre-shared-secret
set vpn ipsec site-to-site peer azure authentication remote-id {{ ip_org_peer }}
set vpn ipsec site-to-site peer azure connection-type initiate
set vpn ipsec site-to-site peer azure ike-group azure
set vpn ipsec site-to-site peer azure ikev2-reauth inherit
set vpn ipsec site-to-site peer azure local-address <your local IP>
set vpn ipsec site-to-site peer azure remote-address {{ ip_org_peer }}
set vpn ipsec site-to-site peer azure vti bind vti0
set vpn ipsec site-to-site peer azure vti esp-group azure
```

Create a NAT rule to translate the source IP for anything going to your adjudication applicaiton's public IP address to the source public IP of the clearinghouse. You can use an IP from your clearinghouse's interesting traffic if you know that range already. If not, you can make up a source public IP for testing purposes.

``` shell
set nat source rule 100 destination address {{ ip_org_app_public }}
set nat source rule 100 outbound-interface name vti0
set nat source rule 100 translation address <any IP from {{ net_clearinghouse_app_public  }}>
```

Create a static route to your adjudication's public IP address to go over the VPN. It's also helpful to create a static route for your Azure virtual network subnets so you can at least confirm that you can connect to your Azure environment by private IP.

``` shell
set protocols static route {{ ip_org_app_public }}/32 interface vti0
set protocols static route {{ net_org_app }}/{{ netmask_org_app }} interface vti0
set protocols static route {{ net_org_routing }}/{{ netmask_org_routing }} interface vti0
```

Commit and save your changes.

``` shell
commit
save
```

If this is the first time you've committed your changes, you may see a message about the vti interface not existing. You can ignore that.
{: .notice--info}

Try to ping the private IP of either your NVA or custom router. It may take several seconds for the VPN to come up if this is the first time you're sending traffic over it.

``` shell
ping {{ ip_org_routing_router }}
```

To see the connection status of your VPN, run this command. (The `run` command is needed if you're in VyOS configuraiton mode. If you're in the command mode, you can omit `run`.)

``` shell
run show vpn ipsec sa
```

If you're VPN still isn't coming up, take a peek at the VPN log to see if you can make heads or tails of it. Type `Shift+G` to scroll to the bottom of the log.

``` shell
run show vpn log
```

Still stuck? Check out the [VyOS documentation](https://docs.vyos.io/en/latest/introducing/about.html). Godspeed!

## Bonus: Simulating Adjudication Application

If you're not the app developer, just a lowly operations technician who is looked upon with derision by your software engineering peers (they think they're so great), you can still emulate a TCP endpoint by spinning up a listener and testing that port.

### Create TCP Listener

If your adjudication endpoint is a Linux VM, run this command.

``` shell
nc -l {{ port_org_app }}
```

This will wait until it receives a packet on TCP port {{ port_org_app }} and then exit out. To exit before then, hit `Ctrl+C`.

In Windows, run the following PowerShell command to start a listener.

``` powershell
($Listener = [System.Net.Sockets.TcpListener] {{ port_org_app }}).Start()
```

This will run until you stop it, which you can do with the following command.

``` powershell
$Listener.Stop()
```

### Probe TCP Port

To test the connection from Linux, run the following command.

``` shell
nc -zv {{ ip_org_app_public }} {{ port_org_app }}
```

And from Windows, run this PowerShell command.

``` powershell
Test-NetConnection {{ ip_org_app_public }} -Port {{ port_org_app }}
```