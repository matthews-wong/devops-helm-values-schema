# devops-helm-values-schema

A small Helm chart for a stateless HTTP service, built around one idea: bad
values should fail at `helm lint` / `helm install`, not at runtime.

- `values.schema.json` rejects unknown keys, wrong types, `latest` tags and
  out-of-range replica counts.
- `values-dev.yaml` and `values-prod.yaml` hold per-environment settings.
- A ConfigMap checksum annotation rolls pods when the config changes.

Work in progress; sections are added as the chart grows.
