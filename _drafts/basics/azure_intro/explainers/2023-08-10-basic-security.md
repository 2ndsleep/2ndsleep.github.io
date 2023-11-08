---
title: Entra ID
categories: basics azure_intro explainer
toc: true
sort_order: 2
description: Microsoft's free cloud directory
---
Security isn't a one-time task, but there are a few basics you should definitely do. This post reviews some low-hanging fruit that I think are most important, but please don't stop here. Work with your colleagues and your security team (if you're lucky enough to have one) to continually improve your security posture. [Introduction to Azure security](https://learn.microsoft.com/en-us/azure/security/fundamentals/overview) is a great place to start.
<!--more-->

Note: Take security seriously.
{: .notice--danger}

## Entra ID

Entra ID is Microsoft's directory service and is probably plays the most crucial security role. A directory service is something that contains **security principals**. A security principal is just a fancy term for objects that perform actions on a resource.

Entra ID was previously known as **Azure Active Directory** which was usually shorted to **Azure AD** or **AAD**.
{: .notice--info}

### User Accounts

The most common security principal is a user account. A user account represents a single person that will usually have a username and password. They are generally going to log into something and then do something to that thing. If you use Gmail, you log into the Google Mail service using your username and password and then you send mail.

### Service Accounts

But not all security principals are users! What if you have a job that runs nightly, such as a script that runs every night to copy files from one file server to another file server? That script needs to run as some type of account. If you're lazy, you'll use your own user account for that, but there's several problems with that.

- You're probably going to have to store your account password somewhere in plain text on the server so the script can run as you. Another person who has elevated access to that server can read your password and then pretend to be you to send pornographies to your boss and get you fired.
- Your password will likely change at which point the job will stop working.
- Should your account even have permission to the server where the job is running?

Service accounts work differently in different environments but usually allow you to configure a service to securely run without having to specify a password or granting the service full access to the server. Azure has a couple of names for service accounts, but they are officially known as **service principals**. We'll talk more about service accounts in the near future.

### Windows Active Directory

If your organization currently has an Active Directory environment, Entra ID can be integrated with Windows Active Directory which we'll talk more about later. If you don't have Active Directory, let me suggest that you keep it that way and rely completely on Entra ID for your directory.

## Entra ID Security Best Practices

The following recommendations are are pulled from Microsoft's [best practices for Entra roles](https://learn.microsoft.com/en-us/azure/active-directory/roles/best-practices) which you should follow. Below are some particularly important ones.

### Global Administrators

Entra ID has a role named **Global Administrator**, which lets you do whatever you want on the tenant. Since it's so powerful, there are a few best practices you should follow.

- [Limit the number of Global Administrators to less than 5](https://learn.microsoft.com/en-us/azure/active-directory/roles/best-practices#5-limit-the-number-of-global-administrators-to-less-than-5).
- [Turn on multi-factor authentication for all administrator accounts](https://learn.microsoft.com/en-us/azure/active-directory/roles/best-practices#3-turn-on-multi-factor-authentication-for-all-your-administrator-accounts) (not just Global Administrators).

### Multi-factor Authentication

Unless you created your tenant before October 22, 2019, Microsoft has already enabled some default security settings to make it much harder for attackers to gain access to your account. These [security defaults](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/security-defaults) do a lot of things you should do anyway, so Microsoft wisely decided to turn them on and make you intentionally disable them if you think you're so damn special.

One singularly helpful configuration of security defaults is that it enforces **multi-factor authentication (MFA)** for your Azure users. MFA simply means that instead of just asking for a password when a user logs on, it asks for another piece of authentication information to prove you are who you claim to be. The secondary authentication information is kind of like second password, but unlike a password this is generated dynamically so that you don't know what it will be until you are logging in. Unless this is literally the first time you've used a computer (or if you've been incarcerated since 2010 - that's also an acceptable excuse) you've seen MFA in action when you're asked to enter a code that was sent to your mobile device when you log onto your bank. Another MFA method is app-based where you have an app on your mobile device generate a code. Unless someone steals your phone no one can get the MFA code, which is hard because if you're like me, you have a panic attack if your phone is away for more than three minutes :disappointed_relieved:.

You'll hear some information security folks tell you that SMS (text message) MFA is not secure. I believe this is a gross and irresponsible overstatement ([this](https://auth0.com/blog/why-sms-multi-factor-still-matters/) summarizes the argument nicely). SMS MFA is less secure than app-based MFA, but the hurdles to compromise SMS MFA are high enough that you should definitely use it instead of nothing. You should encourage app-based MFA over SMS, but always use *some* form of MFA.
{: .notice--info}

In summary, leave security defaults enabled unless you want to take things a step further and use [Conditional Access](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-mfa-howitworks). And if you want to take it even further, consider [passwordless authentication](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-authentication-passwordless).

### Emergency Access Accounts

As great as MFA is, you have to depend on MFA working all the time to log in. If there are problems with MFA, then you'll be locked out of Azure until it's resolved. For this and other reasons, Microsoft recommends that you create two emergency access (or "break glass") accounts. For auditing purposes, you want people to access Azure using their assigned accounts, so these emergency access accounts should only be used for - well - an emergency.

As the [documentation](https://learn.microsoft.com/en-us/azure/active-directory/roles/security-emergency-access) explains, you'll want to exclude these accounts from MFA. But that makes these accounts more vulnerable, so you'll want to monitor and alert if these accounts are ever used. But hey guess what?! Setting up the infrastructure to do exactly that will be one of our first infrastructure as code project, so stay tuned!

Once again, I implore you to take security seriously and don't stop at just this post. Incremental security improvement is better than no progress at all! See [Introduction to Azure security](https://learn.microsoft.com/en-us/azure/security/fundamentals/overview) to start your journey.
{: .notice--danger}
