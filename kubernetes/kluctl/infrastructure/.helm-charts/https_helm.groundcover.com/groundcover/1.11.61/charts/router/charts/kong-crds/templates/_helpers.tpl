{{- define "kong-crds.fullname" -}}
{{- printf "%s-kong-crds" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kong-crds.job.image" -}}
{{- printf "%s:%s" (tpl .Values.image.repository .) .Values.image.tag -}}
{{- end -}}

{{- define "kong-crds.job.annotations" -}}
helm.sh/hook-weight: "0"
helm.sh/hook: "pre-upgrade"
helm.sh/hook-delete-policy: "before-hook-creation,hook-succeeded"
argocd.argoproj.io/hook: Sync
argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
{{- end -}}

{{- define "kong-crds.rbac.annotations" -}}
helm.sh/hook-weight: "-1"
helm.sh/hook: "pre-upgrade"
helm.sh/hook-delete-policy: "before-hook-creation,hook-succeeded"
{{- end -}}
