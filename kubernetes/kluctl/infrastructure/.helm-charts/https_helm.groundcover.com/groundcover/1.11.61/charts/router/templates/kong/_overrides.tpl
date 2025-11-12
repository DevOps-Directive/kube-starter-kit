{{- define "kong.fullname" -}}
{{- printf "%s-kong" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The environment values passed to Kong; this should come after all
the template that it itself is using form the above sections.
*/}}
{{- define "kong.env" -}}
{{/*
    ====== AUTO-GENERATED ENVIRONMENT VARIABLES ======
*/}}
{{- $autoEnv := dict -}}

{{- $_ := set $autoEnv "KONG_LUA_PACKAGE_PATH" "/opt/?.lua;/opt/?/init.lua;;" -}}

{{- $_ := set $autoEnv "KONG_PROXY_ACCESS_LOG" "/dev/stdout" -}}
{{- $_ := set $autoEnv "KONG_PROXY_STREAM_ACCESS_LOG" "/dev/stdout basic" -}}
{{- $_ := set $autoEnv "KONG_ADMIN_ACCESS_LOG" "/dev/stdout" -}}
{{- $_ := set $autoEnv "KONG_STATUS_ACCESS_LOG" "off" -}}
{{- $_ := set $autoEnv "KONG_PROXY_ERROR_LOG" "/dev/stderr" -}}
{{- $_ := set $autoEnv "KONG_PROXY_STREAM_ERROR_LOG" "/dev/stderr" -}}
{{- $_ := set $autoEnv "KONG_ADMIN_ERROR_LOG" "/dev/stderr" -}}
{{- $_ := set $autoEnv "KONG_STATUS_ERROR_LOG" "/dev/stderr" -}}

{{- if .Values.ingressController.enabled -}}
  {{- $_ := set $autoEnv "KONG_KIC" "on" -}}
{{- end -}}

{{- with .Values.admin -}}
  {{- $address := "0.0.0.0" -}}
  {{- if (not .enabled) -}}
    {{- $address = "127.0.0.1" -}}
  {{- end -}}
  {{- $listenConfig := dict -}}
  {{- $listenConfig := merge $listenConfig . -}}
  {{- $_ := set $listenConfig "address" (default $address .address) -}}
  {{- $_ := set $autoEnv "KONG_ADMIN_LISTEN" (include "kong.listen" $listenConfig) -}}

  {{- if or .tls.client.secretName .tls.client.caBundle -}}
    {{- $_ := set $autoEnv "KONG_NGINX_ADMIN_SSL_VERIFY_CLIENT" "on" -}}
    {{- $_ := set $autoEnv "KONG_NGINX_ADMIN_SSL_CLIENT_CERTIFICATE" "/etc/admin-client-ca/tls.crt" -}}
  {{- end -}}

{{- end -}}

{{- if and ( .Capabilities.APIVersions.Has "cert-manager.io/v1" ) .Values.certificates.enabled -}}
  {{- if (and .Values.certificates.cluster.enabled .Values.cluster.enabled) -}}
    {{- $_ := set $autoEnv "KONG_CLUSTER_MTLS" "pki" -}}
    {{- $_ := set $autoEnv "KONG_CLUSTER_SERVER_NAME" .Values.certificates.cluster.commonName -}}
    {{- $_ := set $autoEnv "KONG_CLUSTER_CA_CERT" "/etc/cert-manager/cluster/ca.crt" -}}
    {{- $_ := set $autoEnv "KONG_CLUSTER_CERT" "/etc/cert-manager/cluster/tls.crt" -}}
    {{- $_ := set $autoEnv "KONG_CLUSTER_CERT_KEY" "/etc/cert-manager/cluster/tls.key" -}}
  {{- end -}}

  {{- if .Values.certificates.proxy.enabled -}}
    {{- $_ := set $autoEnv "KONG_SSL_CERT" "/etc/cert-manager/proxy/tls.crt" -}}
    {{- $_ := set $autoEnv "KONG_SSL_CERT_KEY" "/etc/cert-manager/proxy/tls.key" -}}
  {{- end -}}

  {{- if .Values.certificates.admin.enabled -}}
    {{- $_ := set $autoEnv "KONG_ADMIN_SSL_CERT" "/etc/cert-manager/admin/tls.crt" -}}
    {{- $_ := set $autoEnv "KONG_ADMIN_SSL_CERT_KEY" "/etc/cert-manager/admin/tls.key" -}}
    {{- if .Values.enterprise.enabled }}
      {{- $_ := set $autoEnv "KONG_ADMIN_GUI_SSL_CERT" "/etc/cert-manager/admin/tls.crt" -}}
      {{- $_ := set $autoEnv "KONG_ADMIN_GUI_SSL_CERT_KEY" "/etc/cert-manager/admin/tls.key" -}}
    {{- end -}}
  {{- end -}}

  {{- if .Values.enterprise.enabled }}
    {{- if .Values.certificates.portal.enabled -}}
      {{- $_ := set $autoEnv "KONG_PORTAL_API_SSL_CERT" "/etc/cert-manager/portal/tls.crt" -}}
      {{- $_ := set $autoEnv "KONG_PORTAL_API_SSL_CERT_KEY" "/etc/cert-manager/portal/tls.key" -}}
      {{- $_ := set $autoEnv "KONG_PORTAL_GUI_SSL_CERT" "/etc/cert-manager/portal/tls.crt" -}}
      {{- $_ := set $autoEnv "KONG_PORTAL_GUI_SSL_CERT_KEY" "/etc/cert-manager/portal/tls.key" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- if .Values.admin.ingress.enabled }}
  {{- $_ := set $autoEnv "KONG_ADMIN_GUI_API_URL" (include "kong.ingress.serviceUrl" .Values.admin.ingress) -}}
  {{- $_ := set $autoEnv "KONG_ADMIN_API_URI" (include "kong.ingress.serviceUrl" .Values.admin.ingress) -}}
{{- end -}}

{{- $_ := set $autoEnv "KONG_PROXY_LISTEN" (include "kong.listen" .Values.proxy) -}}

{{- $streamStrings := list -}}
{{- if .Values.proxy.enabled -}}
  {{- $tcpStreamString := (include "kong.streamListen" .Values.proxy) -}}
  {{- if (not (eq $tcpStreamString "")) -}}
    {{- $streamStrings = (append $streamStrings $tcpStreamString) -}}
  {{- end -}}
{{- end -}}
{{- if .Values.udpProxy.enabled -}}
  {{- $udpStreamString := (include "kong.streamListen" .Values.udpProxy) -}}
  {{- if (not (eq $udpStreamString "")) -}}
    {{- $streamStrings = (append $streamStrings $udpStreamString) -}}
  {{- end -}}
{{- end -}}
{{- $streamString := $streamStrings | join ", " -}}
{{- if (eq (len $streamString) 0)  -}}
  {{- $streamString = "off" -}}
{{- end -}}
{{- $_ := set $autoEnv "KONG_STREAM_LISTEN" $streamString -}}

{{- $_ := set $autoEnv "KONG_STATUS_LISTEN" (include "kong.listen" .Values.status) -}}

{{- if .Values.proxy.enabled -}}
  {{- $_ := set $autoEnv "KONG_PORT_MAPS" (include "kong.port_maps" .Values.proxy) -}}
{{- end -}}

{{- $_ := set $autoEnv "KONG_CLUSTER_LISTEN" (include "kong.listen" .Values.cluster) -}}

{{- if .Values.enterprise.enabled }}
  {{- $_ := set $autoEnv "KONG_PORTAL_API_ACCESS_LOG" "/dev/stdout" -}}
  {{- $_ := set $autoEnv "KONG_PORTAL_GUI_ACCESS_LOG" "/dev/stdout" -}}
  {{- $_ := set $autoEnv "KONG_ADMIN_GUI_ACCESS_LOG" "/dev/stdout" -}}
  {{- $_ := set $autoEnv "KONG_PORTAL_API_ERROR_LOG" "/dev/stderr" -}}
  {{- $_ := set $autoEnv "KONG_PORTAL_GUI_ERROR_LOG" "/dev/stderr" -}}
  {{- $_ := set $autoEnv "KONG_ADMIN_GUI_ERROR_LOG" "/dev/stderr" -}}

  {{- $_ := set $autoEnv "KONG_ADMIN_GUI_LISTEN" (include "kong.listen" .Values.manager) -}}
  {{- if .Values.manager.ingress.enabled }}
    {{- $_ := set $autoEnv "KONG_ADMIN_GUI_URL" (include "kong.ingress.serviceUrl" .Values.manager.ingress) -}}
  {{- end -}}

  {{- if not .Values.enterprise.vitals.enabled }}
    {{- $_ := set $autoEnv "KONG_VITALS" "off" -}}
  {{- end }}
  {{- $_ := set $autoEnv "KONG_CLUSTER_TELEMETRY_LISTEN" (include "kong.listen" .Values.clustertelemetry) -}}

  {{- if .Values.enterprise.portal.enabled }}
    {{- $_ := set $autoEnv "KONG_PORTAL" "on" -}}
      {{- $_ := set $autoEnv "KONG_PORTAL_GUI_LISTEN" (include "kong.listen" .Values.portal) -}}
    {{- $_ := set $autoEnv "KONG_PORTAL_API_LISTEN" (include "kong.listen" .Values.portalapi) -}}

    {{- if .Values.portal.ingress.enabled }}
      {{- $_ := set $autoEnv "KONG_PORTAL_GUI_HOST" .Values.portal.ingress.hostname -}}
      {{- if .Values.portal.ingress.tls }}
        {{- $_ := set $autoEnv "KONG_PORTAL_GUI_PROTOCOL" "https" -}}
      {{- else }}
        {{- $_ := set $autoEnv "KONG_PORTAL_GUI_PROTOCOL" "http" -}}
      {{- end }}
    {{- end }}

    {{- if .Values.portalapi.ingress.enabled }}
      {{- $_ := set $autoEnv "KONG_PORTAL_API_URL" (include "kong.ingress.serviceUrl" .Values.portalapi.ingress) -}}
    {{- end }}
  {{- end }}

  {{- if .Values.enterprise.rbac.enabled }}
    {{- $_ := set $autoEnv "KONG_ENFORCE_RBAC" "on" -}}
    {{- $_ := set $autoEnv "KONG_ADMIN_GUI_AUTH" .Values.enterprise.rbac.admin_gui_auth | default "basic-auth" -}}

    {{- if not (eq .Values.enterprise.rbac.admin_gui_auth "basic-auth") }}
      {{- $guiAuthConf := include "secretkeyref" (dict "name" .Values.enterprise.rbac.admin_gui_auth_conf_secret "key" "admin_gui_auth_conf") -}}
      {{- $_ := set $autoEnv "KONG_ADMIN_GUI_AUTH_CONF" $guiAuthConf -}}
    {{- end }}

    {{- $guiSessionConf := include "secretkeyref" (dict "name" .Values.enterprise.rbac.session_conf_secret "key" "admin_gui_session_conf") -}}
    {{- $_ := set $autoEnv "KONG_ADMIN_GUI_SESSION_CONF" $guiSessionConf -}}
  {{- end }}

  {{- if .Values.enterprise.smtp.enabled }}
    {{- $_ := set $autoEnv "KONG_SMTP_MOCK" "off" -}}
    {{- $_ := set $autoEnv "KONG_PORTAL_EMAILS_FROM" .Values.enterprise.smtp.portal_emails_from -}}
    {{- $_ := set $autoEnv "KONG_PORTAL_EMAILS_REPLY_TO" .Values.enterprise.smtp.portal_emails_reply_to -}}
    {{- $_ := set $autoEnv "KONG_ADMIN_EMAILS_FROM" .Values.enterprise.smtp.admin_emails_from -}}
    {{- $_ := set $autoEnv "KONG_ADMIN_EMAILS_REPLY_TO" .Values.enterprise.smtp.admin_emails_reply_to -}}
    {{- $_ := set $autoEnv "KONG_SMTP_ADMIN_EMAILS" .Values.enterprise.smtp.smtp_admin_emails -}}
    {{- $_ := set $autoEnv "KONG_SMTP_HOST" .Values.enterprise.smtp.smtp_host -}}
    {{- $_ := set $autoEnv "KONG_SMTP_AUTH_TYPE" .Values.enterprise.smtp.smtp_auth_type -}}
    {{- $_ := set $autoEnv "KONG_SMTP_SSL" .Values.enterprise.smtp.smtp_ssl -}}
    {{- $_ := set $autoEnv "KONG_SMTP_PORT" .Values.enterprise.smtp.smtp_port -}}
    {{- $_ := set $autoEnv "KONG_SMTP_STARTTLS" (quote .Values.enterprise.smtp.smtp_starttls) -}}
    {{- if .Values.enterprise.smtp.auth.smtp_username }}
      {{- $_ := set $autoEnv "KONG_SMTP_USERNAME" .Values.enterprise.smtp.auth.smtp_username -}}
      {{- $smtpPassword := include "secretkeyref" (dict "name" .Values.enterprise.smtp.auth.smtp_password_secret "key" "smtp_password") -}}
      {{- $_ := set $autoEnv "KONG_SMTP_PASSWORD" $smtpPassword -}}
    {{- end }}
  {{- else }}
    {{- $_ := set $autoEnv "KONG_SMTP_MOCK" "on" -}}
  {{- end }}

  {{- if .Values.enterprise.license_secret -}}
    {{- $lic := include "secretkeyref" (dict "name" .Values.enterprise.license_secret "key" "license") -}}
    {{- $_ := set $autoEnv "KONG_LICENSE_DATA" $lic -}}
  {{- end }}

{{- end }} {{/* End of the Enterprise settings block */}}

{{- if .Values.postgresql.enabled }}
  {{- $_ := set $autoEnv "KONG_PG_HOST" (include "kong.postgresql.fullname" .) -}}
  {{- $_ := set $autoEnv "KONG_PG_PORT" .Values.postgresql.service.ports.postgresql -}}
  {{- $pgPassword := include "secretkeyref" (dict "name" (include "kong.postgresql.fullname" .) "key" "password") -}}

  {{- $_ := set $autoEnv "KONG_PG_PASSWORD" $pgPassword -}}
{{- else if eq .Values.env.database "postgres" }}
  {{- $_ := set $autoEnv "KONG_PG_PORT" "5432" }}
{{- end }}

{{- if (and (not .Values.ingressController.enabled) (eq .Values.env.database "off")) }}
{{- $dblessSourceCount := (add (.Values.dblessConfig.configMap | len | min 1) (.Values.dblessConfig.secret | len | min 1) (.Values.dblessConfig.config | len | min 1)) -}}
{{- if eq $dblessSourceCount 1 -}}
  {{- $_ := set $autoEnv "KONG_DECLARATIVE_CONFIG" "/kong_dbless/kong.yml" -}}
{{- end }}
{{- end }}

{{- $_ := set $autoEnv "KONG_PLUGINS" (include "kong.plugins" .) -}}

{{/*
    ====== USER-SET ENVIRONMENT VARIABLES ======
*/}}

{{- $userEnv := dict -}}
{{- range $key, $val := .Values.env }}
  {{- if (contains "_log" $key) -}}
    {{- if (eq (typeOf $val) "bool") -}}
      {{- fail (printf "env.%s must use string 'off' to disable. Without quotes, YAML will coerce the value to a boolean and Kong will reject it" $key) -}}
	{{- end -}}
  {{- end -}}
  {{- $upper := upper $key -}}
  {{- $var := printf "KONG_%s" $upper -}}
  {{- $_ := set $userEnv $var $val -}}
{{- end -}}

{{/*
    ====== CUSTOM-SET ENVIRONMENT VARIABLES ======
*/}}

{{- $customEnv := dict -}}
{{- range $key, $val := .Values.customEnv }}
  {{- $upper := upper $key -}}
  {{- $_ := set $customEnv $upper $val -}}
{{- end -}}

{{/*
      ====== MERGE AND RENDER ENV BLOCK ======
*/}}

{{- $completeEnv := mergeOverwrite $autoEnv $userEnv $customEnv -}}

# FIXME: added tpl
{{- tpl (include "kong.renderEnv" $completeEnv) . -}}

{{- end -}}
