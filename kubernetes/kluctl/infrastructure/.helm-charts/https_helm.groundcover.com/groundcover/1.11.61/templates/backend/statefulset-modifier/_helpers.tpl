{{- define "statefulset-modifier.fullname" -}}
{{- printf "%s-statefulset-modifier" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "volume-expansion.annotations-patches" -}}
sts:
- op: add
  value: {{ .annotations | toJson }}
  path: /spec/volumeClaimTemplates/0/metadata/annotations
pvc:
- op: add
  value: {{ .annotations | toJson }}
  path: /metadata/annotations
{{- end -}}


{{- define "volume-expansion.size-patches" -}}
sts:
- op: replace
  value: {{ .size }}
  path: /spec/volumeClaimTemplates/0/spec/resources/requests/storage
pvc:
- op: replace
  value: {{ .size }}
  path: /spec/resources/requests/storage
{{- end -}}


{{- define "volume-expansion.patches" -}}
sts:
- op: add
  value: {{ .annotations | toJson }}
  path: /spec/volumeClaimTemplates/0/metadata/annotations
- op: replace
  value: {{ .size }}
  path: /spec/volumeClaimTemplates/0/spec/resources/requests/storage
pvc:
- op: replace
  value: {{ .size }}
  path: /spec/resources/requests/storage
- op: add
  value: {{ .annotations | toJson }}
  path: /metadata/annotations
{{- end -}}

{{- define "statefulset-modifier.job.image" -}}
{{- printf "%s:%s" (tpl (index .Values "statefulset-modifier" "image" "repository") .) (index .Values "statefulset-modifier" "image" "tag") -}}
{{- end -}}

{{- define "statefulset-modifier.job.annotations" -}}
helm.sh/hook-weight: "0"
helm.sh/hook: "pre-upgrade"
helm.sh/hook-delete-policy: "before-hook-creation"
{{- end -}}

{{- define "statefulset-modifier.rbac.annotations" -}}
helm.sh/hook-weight: "-1"
helm.sh/hook: "pre-upgrade"
helm.sh/hook-delete-policy: "before-hook-creation"
{{- end -}}
