{{/* vim: set filetype=mustache: */}}

{{/* Copyright: (c) 2022, Justin Béra (@just1not2) <me@just1not2.org> */}}
{{/* Apache License 2.0 (see LICENSE or https://www.apache.org/licenses/LICENSE-2.0.txt) */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "streama.name" -}}
    {{- .Values.nameOverride | default .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "streama.fullname" -}}
    {{- if .Values.fullnameOverride }}
        {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
    {{- else }}
        {{- $name := .Values.nameOverride | default .Chart.Name }}
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
{{- define "streama.chart" -}}
    {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Define common labels
*/}}
{{- define "streama.labels" -}}
helm.sh/chart: {{ include "streama.chart" . }}
{{ include "streama.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Define selector labels
*/}}
{{- define "streama.selectorLabels" -}}
app.kubernetes.io/name: {{ include "streama.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "streama.serviceAccountName" -}}
    {{- if .Values.serviceAccount.create }}
        {{- .Values.serviceAccount.name | default (include "streama.fullname" .) }}
    {{- else }}
        {{- .Values.serviceAccount.name | default "default" }}
    {{- end }}
{{- end }}

{{/*
Return the MySQL host
*/}}
{{- define "streama.databaseHost" -}}
    {{- if .Values.mysql.enabled }}
        {{- if eq .Values.mysql.architecture "replication" }}
            {{- printf "%s-primary" (include "mysql.primary.fullname" .Subcharts.mysql ) | trunc 63 | trimSuffix "-" }}
        {{- else }}
            {{- printf "%s" (include "mysql.primary.fullname" .Subcharts.mysql) }}
        {{- end }}
    {{- else }}
        {{- printf "%s" .Values.externalDatabase.host }}
    {{- end }}
{{- end }}

{{/*
Return the MySQL port
*/}}
{{- define "streama.databasePort" -}}
    {{- if .Values.mysql.enabled }}
        {{- printf "3306" | quote }}
    {{- else if .Values.externalDatabase.port }}
        {{- printf "%d" (.Values.externalDatabase.port | int ) | quote }}
    {{- else }}
        {{- printf "3306" | quote }}
    {{- end }}
{{- end }}

{{/*
Return the MySQL database name
*/}}
{{- define "streama.databaseName" -}}
    {{- if .Values.mysql.enabled }}
        {{- printf "%s" .Values.mysql.auth.database }}
    {{- else if .Values.externalDatabase.database }}
        {{- printf "%s" .Values.externalDatabase.database }}
    {{- else }}
        {{- printf "streama" }}
    {{- end }}
{{- end -}}

{{/*
Return the MySQL user
*/}}
{{- define "streama.databaseUser" -}}
    {{- if .Values.mysql.enabled }}
        {{- printf "%s" .Values.mysql.auth.username }}
    {{- else if .Values.externalDatabase.user }}
        {{- printf "%s" .Values.externalDatabase.user }}
    {{- else }}
        {{- printf "streama" }}
    {{- end }}
{{- end }}

{{/*
Return the MySQL password secret name
*/}}
{{- define "streama.databaseSecretName" -}}
    {{- if .Values.mysql.enabled }}
        {{- if .Values.mysql.auth.existingSecret }}
            {{- printf "%s" .Values.mysql.auth.existingSecret }}
        {{- else }}
            {{- printf "%s" (include "mysql.primary.fullname" .Subcharts.mysql) }}
        {{- end }}
    {{- else if .Values.externalDatabase.existingSecret }}
        {{- printf "%s" .Values.externalDatabase.existingSecret }}
    {{- else }}
        {{- printf "%s-externaldb" (include "streama.fullname" .) }}
    {{- end }}
{{- end }}
