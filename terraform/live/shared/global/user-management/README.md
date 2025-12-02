## TODO: 
1. ✅ Bootstrap IAM user in management account
2. ✅ Validate octo-sts ability to handle team membership
    https://github.com/DevOps-Directive/kube-starter-kit/pull/50#issuecomment-3598164615

Blargh... 

```
403 You must be an organization owner or team maintainer to add a team membership. []
```
https://github.com/DevOps-Directive/kube-starter-kit/actions/runs/19835081090/job/56830284337


ACTUALLY I JUST HAD SET READONLY for the org:members permission 🙈



---

Should I split this out and have it run isolated?
- Separate repo
  - Different AWS role assumption path
  - Broader GH permissions
- Separate bucket the management account

Useful to establish patterns for having more than 1 repo...