{{- define "echo-service.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "echo-service.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "echo-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "echo-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "echo-service.labels" -}}
{{ include "echo-service.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/component: web
app.kubernetes.io/part-of: echo-service
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}
