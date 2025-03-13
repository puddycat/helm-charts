{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "avahi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "avahi.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "avahi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "avahi.labels" -}}
helm.sh/chart: {{ include "avahi.chart" . }}
{{ include "avahi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "avahi.selectorLabels" -}}
{{- if .Values.service.labelsOverride }}
{{- tpl (.Values.service.labelsOverride | toYaml) . }}
{{- else }}
app.kubernetes.io/name: {{ include "avahi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "avahi.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "avahi.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Renders a value that contains template.
Usage:
{{ include "avahi.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "avahi.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{- define "avahi.basePluginAttrs" -}}
{{- if .Values.avahi.prometheus.enabled }}
prometheus:
  export_addr:
    ip: 0.0.0.0
    port: {{ .Values.avahi.prometheus.containerPort }}
  export_uri: {{ .Values.avahi.prometheus.path }}
  metric_prefix: {{ .Values.avahi.prometheus.metricPrefix }}
{{- end }}
{{- if .Values.avahi.customPlugins.enabled }}
{{- range $plugin := .Values.avahi.customPlugins.plugins }}
{{- if $plugin.attrs }}
{{ $plugin.name }}: {{- $plugin.attrs | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "avahi.pluginAttrs" -}}
{{- merge .Values.avahi.pluginAttrs (include "avahi.basePluginAttrs" . | fromYaml) | toYaml -}}
{{- end -}}