#!/bin/bash

# File: scripts/init-chart.sh
# Usage:
#   ./scripts/init-chart.sh <chart-name> [<repo-owner>] [<repo-name>]
#
# Example:
#   ./scripts/init-chart.sh arc-minio my-org helm-chart-devlab

set -euo pipefail

# Helper
show_help() {
  echo "Usage: $0 <chart-name> [<repo-owner>] [<repo-name>]"
  echo "\nArguments:"
  echo "  chart-name    Required. Name of the new chart (e.g. arc-minio)"
  echo "  repo-owner    Optional. GitHub organization or username"
  echo "  repo-name     Optional. GitHub repo name"
  exit 1
}

# Read arguments
CHART_NAME="${1:-}"
REPO_OWNER="${2:-}" 
REPO_NAME="${3:-}"

if [ -z "$CHART_NAME" ]; then
  show_help
fi

if [ -z "$REPO_OWNER" ]; then
  read -p "GitHub repo owner (e.g. your-org): " REPO_OWNER
fi

if [ -z "$REPO_NAME" ]; then
  read -p "GitHub repo name (e.g. helm-chart-devlab): " REPO_NAME
fi

CHART_PATH="charts/$CHART_NAME"
APPSET_PATH="argocd/applicationsets/${CHART_NAME}.yaml"
TEMPLATE_PATH="argocd/applicationsets/template.yaml"

# Step 1: Scaffold Helm chart
if [ -d "$CHART_PATH" ]; then
  echo "Chart $CHART_NAME already exists at $CHART_PATH. Skipping Helm create."
else
  helm create "$CHART_PATH"
  echo "✅ Created Helm chart: $CHART_PATH"
fi

# Step 2: Create ApplicationSet from template.yaml, preserving Go templating
if [ -f "$APPSET_PATH" ]; then
  echo "ApplicationSet already exists at $APPSET_PATH. Skipping copy."
else
  TEMPLATE=$(<"$TEMPLATE_PATH")
  TEMPLATE_ESCAPED=$(echo "$TEMPLATE" | sed \
    -e "s|<your-chart-name>|$CHART_NAME|g" \
    -e "s|<your-org>|$REPO_OWNER|g" \
    -e "s|<your-repo>|$REPO_NAME|g")

  echo "$TEMPLATE_ESCAPED" > "$APPSET_PATH"
  echo "📄 Created ApplicationSet at: $APPSET_PATH"
fi

# Step 3: Reminder
echo -e "\n🎉 Chart '$CHART_NAME' initialized."
echo "✔ Repo: $REPO_OWNER/$REPO_NAME"
echo "✔ Chart path: $CHART_PATH"
echo "✔ ApplicationSet: $APPSET_PATH"
echo "Edit as needed and apply via: kubectl apply -f $APPSET_PATH"
