# No-Op root module

Make any change to a file in this subdirectory to trigger a plan for all digger projects.

Use cases:
- You are modifying a module and want to trigger a plan of all digger projects
- Drift detection has detected drift and you want to create a PR with a plan for all projects

This root module is a hack to work around a couple of digger bugs:
- https://github.com/diggerhq/digger/issues/2485
- Drift reconcilliation via GH issue comments is not currently working (This attempt was reverted: https://github.com/diggerhq/digger/pull/2346)

If/when those are fixed, this can be deleted.

CHANGE_ME_VALUE: 0
