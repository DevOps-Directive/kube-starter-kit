To create crds.yaml need to template cert-manager templates/crds.yaml with the desired version

```
helm template jetstack/cert-manager --version v1.15.1 --set crds.enabled=true -s templates/crds.yaml > crds.yaml
```