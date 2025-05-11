# Helm Chart DevLab

This project is a lightweight boilerplate designed for **learning, testing, and developing Helm charts** using GitOps workflows and ArgoCD preview environments. It's ideal for developers who want to iterate on infrastructure charts and see live feedback on a local or remote Kubernetes cluster.

---

## 🧱 Project Structure

```
helm-chart-devlab/
├── charts/
│   └── demo-app/                # A minimal chart for sandbox testing
├── argocd/
│   └── applicationsets/
│       ├── demo-app.yaml        # AppSet for the demo app
│       └── template.yaml        # Copy this to start a new chart preview
├── scripts/
│   └── init-chart.sh            # Helper script to scaffold charts + AppSets
├── .github/
│   └── workflows/ci.yaml        # GitHub Actions chart linting/testing
└── README.md                    # This file
```

---

## 🚀 What This Boilerplate Does

- ✅ Provides a real-world structure to build and test Helm charts
- ✅ Uses ArgoCD to deploy preview environments for PRs and branches
- ✅ Manages each PR as a dynamic namespace (`demo-dev`, `demo-pr-42`)
- ✅ Validates Helm charts via GitHub Actions

You can fork this repo and use it to build and iterate on any chart.

---

## 🔁 Preview Flow Diagram

```text
GitHub PR → ArgoCD ApplicationSet → Renders Chart → Deploys to demo-pr-42 namespace
```

---

## 🧪 Chart for Demo Purposes

The included `charts/demo-app/` chart is a lightweight NGINX deployment with minimal resource usage. It is ideal for previewing Helm functionality without overwhelming a test cluster.

You can replace it with your own chart while maintaining the same GitOps flow.

---

## 🔧 Setup Instructions

### 1. Install ArgoCD
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace
```

### 2. Deploy the ApplicationSet

Before applying the ApplicationSet, you need a GitHub Personal Access Token (PAT) so ArgoCD can fetch pull request metadata.

**Use the following settings:**

- **Name**: `argocd-preview-env-access`
- **Description**: Token used by ArgoCD ApplicationSets to fetch PRs and branches for dynamic preview environments.
- **Scopes**:
  - `repo` (for both public and private repos)
  - `read:org` (if the repo is under an organization)

Then create the token secret in your cluster:

```bash
kubectl create secret generic github-token \
  --from-literal=token=<your_github_pat> \
  -n argocd
kubectl apply -f argocd/applicationsets/demo-app.yaml
```

### 3. Create a New Chart and ApplicationSet

Use the helper script to scaffold everything for a new chart:

```bash
./scripts/init-chart.sh <chart-name> [<repo-owner>] [<repo-name>]
```

If `repo-owner` and `repo-name` are omitted, the script will prompt you.

This will:
- Create a Helm chart under `charts/<chart-name>`
- Copy and customize `argocd/applicationsets/template.yaml`

Then apply your new AppSet:
```bash
kubectl apply -f argocd/applicationsets/<chart-name>.yaml
```

---

## 🧠 What You Can Do with This Repo

- 🔨 Develop your own charts in `charts/<your-chart>`
- 🔁 Create one ApplicationSet per chart for dynamic previews
- 🔍 Use `values.namespace` and `envSuffix` to isolate each preview
- 🧪 Learn how ArgoCD manages chart lifecycles in a safe testbed

---

## 🔄 GitHub CI Integration

The project includes a GitHub Actions workflow that automatically lints and renders all charts in the `charts/` directory on each pull request.

This ensures:
- Your Helm syntax is valid
- Templates render correctly without needing a cluster
- All charts are tested dynamically without hardcoding their names

This helps you catch issues early and keeps your infrastructure code safe to deploy.


---

## 📦 Chart Templates to Explore

You can use this framework to build and test:
- CI platforms (e.g., `arc-minio`)
- GitOps tools (e.g., `flux`, `tekton`, `argo-events`)
- Lightweight internal services

Just add your own subcharts under `charts/` and create matching ArgoCD `ApplicationSet` manifests in `argocd/applicationsets/`.

---

## 📜 License
MIT or your preferred license.
