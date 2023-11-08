---
title: Passwordless Pitfalls
category: thoughts
---
After changing the primary domain for a user, passwordless MFA stopped working correctly. After logging on, there was a loop to enable another authentication method. Here's the fix.

- Exclude user from conditional access
- Remove entry from Authenticator app
- Force re-registration of MFA for user
- User logs in and re-registers
- Enable passwordless option for account in Authenticator app
- Include user in conditional access