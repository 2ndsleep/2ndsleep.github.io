---
title: Azure Security
categories: basics cloud_intro explainer
toc: true
sort_order: 6
---
Security isn't a one-time task, but there are a few basics you should definitely do.<!--more--> This post reviews some low-hanging fruit that I think are most important, but please don't stop here. Work with your colleagues and your security team (if you're lucky enough to have one) to continually improve your security posture. [Introduction to Azure security](https://learn.microsoft.com/en-us/azure/security/fundamentals/overview) is a great place to start.

Note: Take security seriously.
{: .notice--danger}

## RBAC

**Role-based access control (RBAC)** is a foundational security concept. With RBAC, roles are defined and then assigned to objects. Roles themselves are just a collection of operations that are allowed to be performed on specific objects. For example, the role of **Storage Blob Data Contributor** is a collection of the following operations that are allowed to be performed on Azure Storage Accounts:

```
Microsoft.Storage/storageAccounts/blobServices/containers/delete
Microsoft.Storage/storageAccounts/blobServices/containers/read
Microsoft.Storage/storageAccounts/blobServices/containers/write
Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action
Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action
```

In other words, the Storage Blob Data Contributor role defines the set of permissions to read, write, and delete Storage account containers and blobs and generate a [SAS token](https://learn.microsoft.com/en-us/rest/api/storageservices/create-user-delegation-sas).

The important thing here is that users or groups are assigned to roles which then grants them the role's permissions. Users are not directly granted permission to do something. For instance, you wouldn't directly assign the `Microsoft.Storage/storageAccounts/blobServices/containers/read` permission to a user. In fact, I don't think it's possible. You can, however, create a role with only that permission and then assign that to a user.

Less frequently, users or groups are *denied* a role, which explicitly prevents them from doing something. Denying permission is less common because by default, users are denied permission to do anything until assigned to a role. An example might be if your company has a group called Engineers and nested within that group is another group called Engineering Interns. The Engineers group is assigned the Contributor role on a subscription, but you want to deny all the delete permissions to the Engineering Interns group, because their hearts are in the right place, but you know.
{: .notice--info}

### Azure vs. Azure AD RBAC

Azure resources and Azure AD both use RBAC to grant permissions. And since it's Microsoft, they confusingly call the first **Azure RBAC** and the second **Azure AD RBAC**. Here's the takeaways I want you to know:

- Azure RBAC is to assign permission for Azure *resources* like VMs, databases, etc.
- Azure AD RBAC is to assign permission to operations related to Azure Active Directory, like the Password Administrator role that can reset most user passwords.
- Azure RBAC and Azure AD RBAC are two distinct access management mechanisms, but there is the slightest bit of interaction, which we'll see.

### Azure RBAC

Once again, Azure RBAC is used to grant access to Azure *resources*. You assign any security **principal** to a role at a certain scope. There's a lot to unpack in that short sentence, so let's go term-by-term.

#### Security Principals

A security principal is any security object. Okay, what's a security object? A security object is anything that will be doing something to another thing. It's the security object that wants to connect to another resource to do something with that resource.

Users that have a username and password are the security principals you probably think of most of the time. But a lot of times a service needs to connect to another service to do something, such as an application that runs nightly to download files from a Storage account. That application will need to run as some kind of account in order to authenticate to that storage account. That type of account has a few different names in Azure, but let's call it a **service principal** for now.

#### Roles

The role is what we discussed in the previous section. The principal will be assigned a role to give that principal permission to do something with a resource, like read or write that resource. You can see all the Azure built-in roles [here](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles).

#### Scope

The scope means at what level in the [Azure hierarchy]({% post_url /basics/cloud_intro/explainers/2023-08-08-azure-hierarchy %}#) the permission will apply. Let's say you assign the Storage Blob Data Contributor role to the user kyle@scramoose.dev at the subscription scope. That user will be able to read and write any blobs in the subscription. If you instead apply that at the level of a resource group named `KylesStuff`, kyle@scramoose.dev will only be able to read and write blobs in that resource group. And finally, you may decide to apply it directly to the Storage account named `kylesweirdfilesdontlook`, then kyle@scramoose.dev will only be able to read and write blobs in that Storage account.

In the [Azure structure]({% post_url /basics/cloud_intro/explainers/2023-08-08-azure-hierarchy %}) post, I breezed right by [management groups]({% post_url /basics/cloud_intro/explainers/2023-08-08-azure-hierarchy %}#management-groups) because we didn't have enough context at the time. But one purpose of management groups is as a security scope. So you can set permissions at layers above subscriptions by setting them at management groups. For example, you may create three management groups to represent the mega-facilities of your company: San Francisco, CA, New York, NY and Boerne, TX. Each of those management groups is made up of two subscriptions. For the whole tenant, you grant the Boerne engineering team the Owner role. You trust the talent in that small town, so they can manage all resources in all subscriptions. However, you recognize that there aren't many reliable engineers in all of San Francisco nor New York, so you assign the San Francisco engineering team the Reader role to the San Francisco management group and the New York engineering team the Contributor role to the New York management group (because you trust them a little more).

### Azure AD RBAC

Azure AD RBAC is a little more straightforward because you don't have scopes. Everything just applies to Azure AD. So users or groups are assigned to Azure AD roles and they have those roles' permissions. You can see all the Azure AD built-in roles [here](https://learn.microsoft.com/en-us/azure/active-directory/roles/permissions-reference).

### Using Groups

Instead of assigning users directly roles, which can be a lot of work, make your job easy by [assigning groups to roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview#groups) and then adding users to groups. This kind of extends the idea of RBAC into what I call group-based-role-based access control, which I shorten to GBRBAC and pronounce "ga-bra-bawk!" screeching out the last "bawk" like a crow that is signaling distress to other crows. But you can call it whatever you're most comfortable with.

Microsoft recommends this approach, but I have a small bone to pick with their recommendation. They suggest that you use nested groups which I normally would agree with except that **not all Azure resources [acknowledge nested groups](https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/directory-service-limits-restrictions)**. So you may want to consider having each group only contain users and not other groups. You may even find that this makes management easier because someone must be explicitly a member of a group in order to get access to resources and you don't have those issues where someone is getting access that you didn't expect.
{: .notice--warning}

Azure AD groups are a magical place where Azure RBAC and Azure AD RBAC meet. You can use groups to manage your Azure RBAC as described in the [Azure RBAC](#azure-rbac) section but you can also [assign Azure AD roles to groups](https://learn.microsoft.com/en-us/azure/active-directory/roles/groups-concept). One hitch: **you have to make a group as role-assignable when you create the group, not after**. Once you mark a group as role-assignable, you can change which Azure AD roles are assigned, but marking it as role-assignable is the one thing you have to do upfront.

Why not make all groups role-assignable you may ask? Well, there's a limit of 500 role-assignable groups. Deciding when to create role-assignable groups is a little tricky, but I tend to create role-assignable groups when the group indicates a general job function. It could be entire job roles like **Developers** or **Security Managers** or more general work like **Operators** or **Readers**. The tricky part is that you may want to assign Azure AD roles in the future even if it's not necessary now. With that in mind, it more be more helpful to think of when you *do not* want to create role-assignable groups. If the group is to grant access to specific resources or if you have an app that is integrated with Azure AD, you probably don't need it to be a role-assignable group, like **SQL Administrators** or **{{ site.fake_company_name }} API Readers**.

## Global Administrators

Azure AD has a role named **Global Administrator**, which lets you do whatever you want on the tenant. Since it's so powerful, there are a few best practices you should follow.

- [Limit the number of Global Administrators to less than 5](https://learn.microsoft.com/en-us/azure/active-directory/roles/best-practices#5-limit-the-number-of-global-administrators-to-less-than-5).
- [Turn on multi-factor authentication for all administrator accounts](https://learn.microsoft.com/en-us/azure/active-directory/roles/best-practices#3-turn-on-multi-factor-authentication-for-all-your-administrator-accounts) (not just Global Administrators).

## Multi-factor Authentication

Unless you created your tenant before October 22, 2019, Microsoft has already enabled some default security settings to make it much harder for attackers to gain access to your account. These [security defaults](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/security-defaults) do a lot of things you should do anyway, so Microsoft wisely decided to turn them on and make you intentionally disable them if you think you're so damn special.

One singularly helpful configuration of security defaults is that it enforces **multi-factor authentication (MFA)** for your Azure users. MFA simply means that instead of just asking for a password when a user logs on, it asks for another piece of authentication information to prove you are who you claim to be. The secondary authentication information is kind of like second password, but unlike a password this is generated dynamically so that you don't know what it will be until you are logging in. Unless this is literally the first time you've used a computer (or if you've been incarcerated since 2010 - that's also an acceptable excuse) you've seen MFA in action when you're asked to enter a code that was sent to your mobile device when you log onto your bank. Another MFA method is app-based where you have an app on your mobile device generate a code. Unless someone steals your phone no one can get the MFA code, which is hard because if you're like me, you have a panic attack if your phone is away for more than three minutes :disappointed_relieved:.

You'll hear some information security folks tell you that SMS (text message) MFA is not secure. I believe this is a gross and irresponsible overstatement ([this](https://auth0.com/blog/why-sms-multi-factor-still-matters/) summarizes the argument nicely). SMS MFA is less secure than app-based MFA, but the hurdles to compromise SMS MFA are high enough that you should definitely use it instead of nothing. You should encourage app-based MFA over SMS, but always use *some* form of MFA.
{: .notice--info}

In summary, leave security defaults enabled unless you want to take things a step further and use [Conditional Access](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-mfa-howitworks). And if you want to take it even further, consider [passwordless authentication](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-authentication-passwordless).

## Emergency Access Accounts

As great as MFA is, you have to depend on MFA working all the time to log in. If there are problems with MFA, then you'll be locked out of Azure until it's resolved. For this and other reasons, Microsoft recommends that you create two emergency access (or "break glass") accounts. For auditing purposes, you want people to access Azure using their assigned accounts, so these emergency access accounts should only be used for - well - an emergency.

As the [documentation](https://learn.microsoft.com/en-us/azure/active-directory/roles/security-emergency-access) explains, you'll want to exclude these accounts from MFA. But that makes these accounts more vulnerable, so you'll want to monitor and alert if these accounts are ever used. But hey guess what?! Setting up the infrastructure to do exactly that will be our first infrastructure as code project, so stay tuned!

## Azure AD Security Best Practices

Some of the above recommendations are are pulled from Microsoft's [best practices for Azure AD roles](https://learn.microsoft.com/en-us/azure/active-directory/roles/best-practices) which you should follow.

Once again, I implore you to take security seriously and don't stop at just this post. Incremental security improvement is better than no progress at all! See [Introduction to Azure security](https://learn.microsoft.com/en-us/azure/security/fundamentals/overview) to start your journey.
{: .notice--danger}