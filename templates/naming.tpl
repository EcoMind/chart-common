{{- define "partOf" -}}
e4t
{{- end }}

{{- define "namespace" -}}
{{ .Release.Namespace }}
{{- end }}

# ------------------

{{- define "e4t.truncPrefix63" }}
{{- $endIndex := len . }}
{{- if gt $endIndex 63 }}
  {{- $beginIndex := add $endIndex -63 | int }}
  {{- substr $beginIndex $endIndex . }}
{{- else }}
  {{- . }}
{{- end }}
{{- end }}

{{- define "e4t.name.from.path" }}
{{- .Template.Name | trimPrefix .Template.BasePath | trimPrefix "/main/" | trimSuffix ".yaml" }}
{{- end }}

#FIXME avoid copypaste
{{- define "e4t.auto.component.type" }}
{{- $nameFromPath := include "e4t.name.from.path" . }}
{{- $nameSuffix := regexFind "[^/]+$" $nameFromPath }}
{{- $nameSuffix := splitList "-" $nameSuffix }}
{{- first $nameSuffix }}
{{- end }}

{{- define "e4t.auto.component" }}
{{- $nameFromPath := trimPrefix .Template.BasePath .Template.Name | trimPrefix "/main/" | trimSuffix ".yaml" }}
{{- $nameSuffix := regexFind "[^/]+$" $nameFromPath }}
{{- $namePrefix := trimSuffix $nameSuffix $nameFromPath | replace "/" "-" }}
{{- $nameSuffix := regexSplit "-" $nameSuffix -1 }}
{{- $nameSuffix := slice $nameSuffix 1 | join "-" }}
{{- print $namePrefix $nameSuffix | trimSuffix "-" }}
{{- end }}

{{- define "e4t.auto.values" }}
{{- $path := .path }}
{{- $ := .ctx }}
{{- $name := include "e4t.auto.component" $ }}
{{- $inferredType := include "e4t.auto.component.type" $ }}
{{- $inferredPath := $name | replace "-" "." }}
{{- $completePath := print $inferredPath "." $inferredType "." $path }}
{{- include "e4t.dig" (dict "dict" $.Values "path" $completePath ) }}
{{- end }}

{{- define "e4t.dig" }}
{{- $dict := .dict }}
{{- $path := .path }}
{{- $splitPath := splitList "." $path }}
{{- include "e4t.dig.list" (dict "dict" $dict "keys" $splitPath ) }}
{{- end }}

{{- define "e4t.dig.list" }}
{{- $dict := .dict }}
{{- $keys := .keys }}
{{- if not (hasKey $dict (first $keys)) }}
  {{- fail (printf "no key %s in %s" (first $keys) $dict ) }}
{{- end }}
{{- $subdict := get $dict (first $keys) }}
{{- if len $keys | eq 1 }}
  {{- print $subdict }}
{{- else }}
  {{- include "e4t.dig.list" (dict "dict" $subdict "keys" (rest $keys)) }}
{{- end }}
{{- end }}

{{- define "e4t.name" }}
{{- $name := .name }}
{{- $ := .ctx }}
{{- print $.Release.Name "-" $name }}
{{- end }}

{{- define "e4t.auto.name" }}
{{- $name := include "e4t.auto.component" . }}
{{- include "e4t.name" ( dict "name" $name "ctx" $ ) }}
{{- end }}

{{- define "e4t.matchLabels" }}
{{- $name := .name }}
{{- $ := .ctx }}
app.kubernetes.io/name: {{ template "name" $ | quote }}
app.kubernetes.io/instance: {{ $.Release.Name | quote }}
app.kubernetes.io/component: {{ $name | quote }}
{{- end }}

{{- define "e4t.auto.matchLabels" }}
{{- $name := include "e4t.auto.component" . }}
{{- include "e4t.matchLabels" ( dict "name" $name "ctx" $ ) }}
{{- end }}

{{- define "e4t.labels" }}
{{- $name := .name }}
{{- $ := .ctx }}
{{- include "e4t.matchLabels" ( dict "name" $name "ctx" $ ) }}
app.kubernetes.io/version: {{ $.Chart.AppVersion | quote }}
app.kubernetes.io/part-of: {{ template "partOf" . | quote }}
app.kubernetes.io/managed-by: {{ $.Release.Service | quote }}
helm.sh/chart: {{ $.Chart.Name }}-{{ $.Chart.Version | replace "+" "_" }}
{{- if $.Values.global.labels }}
{{ include "common.tplvalues.render" (dict "value" $.Values.global.labels "context" $) }}
{{- end }}
{{- end }}

{{- define "e4t.auto.labels" }}
{{- $name := include "e4t.auto.component" . }}
{{- include "e4t.labels" ( dict "name" $name "ctx" . ) }}
{{- end }}

{{- define "e4t.auto.metadata" }}
metadata:
  name: {{ include "e4t.auto.name" . }}
  namespace: {{ include "namespace" . }}
  labels: 
    {{- include "e4t.auto.labels" . | indent 4 }}
{{- end }}

{{- define "e4t.metadata" }}
{{- $name := .name }}
{{- $ := .ctx }}
metadata:
  name: {{ include "e4t.name" . | quote }}
  namespace: {{ include "namespace" $ | quote }}
  labels:
    {{- include "e4t.labels" . | indent 4 }}
{{- end }}

{{- define "e4t.host.internal" }}
{{- $name := .name }}
{{- $ := .ctx }}
{{- print $.Release.Name "-" $name "." $.Release.Namespace ".svc.cluster.local" }}
{{- end -}}

{{- define "e4t.auto.host.internal" }}
{{- $name := include "e4t.auto.component" . }}
{{- include "e4t.host.internal" ( dict "name" $name "ctx" $ ) }}
{{- end }}

{{- define "e4t.server.java.mount.cfg" }}
{{- $volumeName := .volumeName }}
- mountPath: /app/application.yaml
  name: {{ $volumeName }}
  subPath: application.yaml
  readOnly: true
- mountPath: /app/log4j2.xml
  name: {{ $volumeName }}
  subPath: log4j2.xml
  readOnly: true
{{- end }}