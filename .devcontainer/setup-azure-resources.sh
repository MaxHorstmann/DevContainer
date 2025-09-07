#!/bin/bash

# Idempotent Azure Resource Setup for Dev Container
# This script creates required Azure resources and exits quickly if they already exist

set -e

# Configuration
RESOURCE_GROUP_NAME="rg-devcontainer-dev"
STORAGE_ACCOUNT_NAME="stdevcontainer001"  # Fixed name for consistency
LOCATION="eastus"
SKU="Standard_LRS"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if Azure CLI is available
check_azure_cli() {
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI not found. Make sure it's installed in the dev container."
        return 1
    fi
    return 0
}

# Function to check if logged in to Azure
check_azure_login() {
    if ! az account show > /dev/null 2>&1; then
        log_warning "Not logged in to Azure. Azure Storage will not be available."
        log_info "To enable Azure Storage, run: az login"
        return 1
    fi
    return 0
}

# Function to check if resource group exists
check_resource_group() {
    if az group show --name "$RESOURCE_GROUP_NAME" > /dev/null 2>&1; then
        log_info "Resource group '$RESOURCE_GROUP_NAME' already exists"
        return 0
    fi
    return 1
}

# Function to create resource group
create_resource_group() {
    log_info "Creating resource group '$RESOURCE_GROUP_NAME'..."
    az group create \
        --name "$RESOURCE_GROUP_NAME" \
        --location "$LOCATION" \
        --output none
    log_success "Resource group created"
}

# Function to check if storage account exists
check_storage_account() {
    if az storage account show --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP_NAME" > /dev/null 2>&1; then
        log_info "Storage account '$STORAGE_ACCOUNT_NAME' already exists"
        return 0
    fi
    return 1
}

# Function to create storage account
create_storage_account() {
    log_info "Creating storage account '$STORAGE_ACCOUNT_NAME'..."
    az storage account create \
        --name "$STORAGE_ACCOUNT_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --location "$LOCATION" \
        --sku "$SKU" \
        --kind StorageV2 \
        --access-tier Hot \
        --output none
    log_success "Storage account created"
}

# Function to setup storage containers
setup_storage_containers() {
    local connection_string
    connection_string=$(az storage account show-connection-string \
        --name "$STORAGE_ACCOUNT_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --query connectionString \
        --output tsv)

    # Create containers if they don't exist
    local containers=("dev-uploads" "dev-temp" "dev-logs")
    
    for container in "${containers[@]}"; do
        if ! az storage container show \
            --name "$container" \
            --connection-string "$connection_string" > /dev/null 2>&1; then
            log_info "Creating container '$container'..."
            az storage container create \
                --name "$container" \
                --connection-string "$connection_string" \
                --public-access off \
                --output none
        else
            log_info "Container '$container' already exists"
        fi
    done
}

# Function to update appsettings
update_appsettings() {
    local connection_string
    connection_string=$(az storage account show-connection-string \
        --name "$STORAGE_ACCOUNT_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --query connectionString \
        --output tsv)

    local appsettings_file="/workspaces/DevContainer/HelloWorldApi/appsettings.Development.json"
    
    if [[ -f "$appsettings_file" ]]; then
        # Check if AzureStorage section already exists
        if ! grep -q "AzureStorage" "$appsettings_file"; then
            log_info "Adding Azure Storage configuration to appsettings.Development.json..."
            
            # Create a temporary file with the updated configuration
            local temp_file=$(mktemp)
            jq --arg conn_str "$connection_string" '. + {"AzureStorage": {"ConnectionString": $conn_str}}' "$appsettings_file" > "$temp_file"
            mv "$temp_file" "$appsettings_file"
            
            log_success "Configuration updated"
        else
            log_info "Azure Storage configuration already exists in appsettings"
        fi
    fi
}

# Main execution
main() {
    log_info "Starting idempotent Azure resource setup..."
    
    # Check prerequisites
    if ! check_azure_cli; then
        exit 1
    fi
    
    if ! check_azure_login; then
        log_info "Azure Storage is not available (not logged in)"
        exit 0
    fi
    
    # Setup resources idempotently
    if ! check_resource_group; then
        create_resource_group
    fi
    
    if ! check_storage_account; then
        create_storage_account
    fi
    
    setup_storage_containers
    update_appsettings
    
    log_success "Azure resources are ready!"
    log_info "Storage Account: $STORAGE_ACCOUNT_NAME"
    log_info "Resource Group: $RESOURCE_GROUP_NAME"
    
    # Show cleanup command
    echo ""
    log_info "To cleanup all resources later:"
    echo "az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait"
}

# Run main function
main "$@"
