# eks-deploy

Study project that deploys three APIs to AWS EKS. Keep changes small and explicit; do not over-engineer.

## Layout

Directories with the `*-api` suffix are microservices:

- `auth-api`
- `users-api`
- `tasks-api`

| Path | Role |
| --- | --- |
| `*.tf` at repo root | Terraform: EKS module, provider/backend, ECR, secrets |
| `kubernetes/` | Manifests applied to the EKS cluster |
| `docker-compose.yaml` | Local development only |
| `.github/` | CI/CD workflows |

Terraform files today: `main.tf` (EKS module), `provider.tf`, `ecr.tf`, `secrets.tf`.

## Local vs cluster

- Use `docker-compose.yaml` only for local development.
- Deploy to EKS with the manifests in `kubernetes/`.

## Constraints

- This repository is public on GitHub. Do not add credentials, secrets, or any other values that must not be public.
- Never commit MongoDB URIs, `TOKEN_KEY`, kubeconfig, or Terraform state. Keep sensitive values in AWS Secrets Manager (or equivalent), provisioned via Terraform.
- Do not put secrets in plaintext in Kubernetes YAML.

## Terraform

- When an AWS resource is needed, provision it with a Terraform file.
- Reuse the existing EKS module (`eks-terraform` in `main.tf`). Do not recreate the cluster from scratch.
- Follow the current pattern: one `.tf` file per resource type (`ecr.tf`, `secrets.tf`, and so on).

## Kubernetes

- Container images must come from ECR (`ecr.tf`), not hardcoded Docker Hub image names.
- Inject secrets from AWS Secrets Manager (or Kubernetes Secrets created from it), not from literal `env.value` fields.
