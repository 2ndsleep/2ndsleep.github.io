---
title: First Active Directory Domain Controller - Scripted
service: Active Directory
procedure: New Domain
type: scripted
---
Here's the steps to create a domain controller using PowerShell.

Things in the dark grey boxes are blocks of code. I'm not wild about how this theme displays code, but maybe it's because it's a little unorthodox. Here's an example of something I'm used to seeing: [Minimal Theme](https://pages-themes.github.io/minimal/)

# Run this command first

```
$Cred = Get-Credential
Install-Domain -Domain domain.com -Credential $Cred -NoRestart
```

# Run this command next

```
Configure-Domain
```