# devops-helm-values-schema

A small Helm chart for a stateless HTTP service, built around one idea: bad
values should fail at `helm lint` / `helm install`, not at runtime.

- `chart/values.schema.json` rejects unknown keys, wrong types, `latest` tags,
  privileged container ports and missing resource limits.
- `chart/values-dev.yaml` and `chart/values-prod.yaml` hold per-environment
  settings; only the differences from `values.yaml` live there.
- A `checksum/config` pod annotation rolls the pods when the ConfigMap changes.
- The pod runs as non-root with a read-only root filesystem, all capabilities
  dropped, a RuntimeDefault seccomp profile, and startup, liveness and
  readiness probes.

## Usage

```sh
helm lint chart -f chart/values-prod.yaml
helm template echo chart -f chart/values-prod.yaml
helm install echo chart -f chart/values-prod.yaml
```

The default image is `nginxinc/nginx-unprivileged`, which listens on 8080 and
keeps its temp files under `/tmp` (mounted as a small `emptyDir`).

## Validate

Needs `helm` and `kubeconform` on the PATH.

```sh
make validate
```

This lints both environments, renders them through `kubeconform -strict`, runs
`tests/schema_cases.sh` (eight invalid value sets that must be rejected) and
`tests/rollout_checksum.sh` (a config change must alter the pod template).

## Notes

Helm compiles the schema with a Go regex engine, so lookaheads such as
`(?!latest$)` are not allowed; the `latest` tag is blocked with a `not`/`const`
rule instead.
