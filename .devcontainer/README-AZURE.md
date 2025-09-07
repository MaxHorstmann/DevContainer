# Azure Resource Setup

This dev container automatically creates required Azure resources when it starts.

## How it works

1. **Automatic**: The script runs every time the dev container starts
2. **Idempotent**: If resources already exist, it skips creation (fast)
3. **Safe**: Only creates resources if you're logged in to Azure

## Setup Process

### First Time Setup

```bash
# Login to Azure (one time only)
az login
```

After logging in, restart your dev container or run:

```bash
.devcontainer/setup-azure-resources.sh
```

### What Gets Created

- Resource Group: `rg-devcontainer-dev`
- Storage Account: `stdevcontainer001`
- Blob Containers: `dev-uploads`, `dev-temp`, `dev-logs`
- Auto-updates your `appsettings.Development.json`

## Requirements

This dev container requires Azure Storage for development. You must be logged in to Azure for storage functionality to work.

If you're not logged in to Azure, the script will skip resource creation and storage features will not be available.

## Cleanup

To remove all Azure resources:

```bash
az group delete --name rg-devcontainer-dev --yes --no-wait
```

## Cost

- Storage Account uses Standard_LRS (cheapest tier)
- Minimal cost for development workloads
- Delete when not needed to avoid charges
