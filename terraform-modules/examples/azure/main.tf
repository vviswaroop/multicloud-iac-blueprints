# Azure Terraform Example: Production-Ready Enterprise Application
# This example demonstrates a complete Azure infrastructure setup using all modules

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azuread" {}

# Data sources for current client configuration
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# Generate random password for SQL Server
resource "random_password" "sql_password" {
  length  = 16
  special = true
}

# Generate SSH key pair for VMs
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.environment}-${var.project}-rg"
  location = var.location
  tags     = var.tags
}

# Create Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.environment}-${var.project}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Create VNet with multiple subnets
module "vnet" {
  source = "../../azure/vnet"

  name                = "${var.environment}-${var.project}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space

  subnets = {
    web = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql", "Microsoft.KeyVault"]
    }
    app = {
      address_prefixes  = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql", "Microsoft.KeyVault"]
    }
    data = {
      address_prefixes  = ["10.0.3.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
    aks = {
      address_prefixes  = ["10.0.4.0/22"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    gateway = {
      address_prefixes = ["10.0.8.0/27"]
    }
    bastion = {
      address_prefixes = ["10.0.9.0/27"]
    }
  }

  network_security_groups = {
    web = {
      security_rules = [
        {
          name                       = "AllowHTTPS"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowHTTP"
          priority                   = 1002
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowSSH"
          priority                   = 1003
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.0.9.0/27"
          destination_address_prefix = "*"
        }
      ]
    }
    app = {
      security_rules = [
        {
          name                       = "AllowAppPorts"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "10.0.1.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowSSH"
          priority                   = 1002
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.0.9.0/27"
          destination_address_prefix = "*"
        }
      ]
    }
    data = {
      security_rules = [
        {
          name                       = "AllowSQL"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.0.2.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowSSH"
          priority                   = 1002
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.0.9.0/27"
          destination_address_prefix = "*"
        }
      ]
    }
    aks = {
      security_rules = [
        {
          name                       = "AllowKubernetesAPI"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }

  subnet_nsg_associations = {
    web  = "web"
    app  = "app"
    data = "data"
    aks  = "aks"
  }

  tags = var.tags
}

# Create Azure Bastion for secure access
resource "azurerm_public_ip" "bastion" {
  name                = "${var.environment}-${var.project}-bastion-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "main" {
  name                = "${var.environment}-${var.project}-bastion"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.vnet.subnet_ids["bastion"]
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

# Create Storage Account for application data and backups
module "storage" {
  source = "../../azure/storage"

  name                = replace("${var.environment}${var.project}storage", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  account_tier        = "Standard"
  account_replication_type = "GRS"
  
  containers = [
    {
      name                  = "app-data"
      container_access_type = "private"
    },
    {
      name                  = "backups"
      container_access_type = "private"
    },
    {
      name                  = "logs"
      container_access_type = "private"
    }
  ]

  file_shares = [
    {
      name  = "shared-content"
      quota = 5120
    }
  ]

  network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [
      module.vnet.subnet_ids["web"],
      module.vnet.subnet_ids["app"],
      module.vnet.subnet_ids["data"],
      module.vnet.subnet_ids["aks"]
    ]
  }

  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
    delete_retention_policy = {
      days = 30
    }
    container_delete_retention_policy = {
      days = 30
    }
  }

  tags = var.tags
}

# Create Application Gateway for load balancing
resource "azurerm_public_ip" "app_gateway" {
  name                = "${var.environment}-${var.project}-appgw-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "main" {
  name                = "${var.environment}-${var.project}-appgw"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = module.vnet.subnet_ids["gateway"]
  }

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  frontend_port {
    name = "frontend-port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 1
  }

  tags = var.tags
}

# Create SQL Server and Database
module "sql" {
  source = "../../azure/sql"

  server_name                   = "${var.environment}-${var.project}-sql"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  administrator_login          = var.sql_admin_username
  administrator_login_password = random_password.sql_password.result
  minimum_tls_version          = "1.2"
  public_network_access_enabled = false

  azuread_administrator = {
    login_username = data.azuread_client_config.current.display_name
    object_id      = data.azuread_client_config.current.object_id
    tenant_id      = data.azuread_client_config.current.tenant_id
  }

  databases = {
    app_db = {
      sku_name        = "S2"
      max_size_gb     = 250
      zone_redundant  = false
      storage_account_type = "Geo"
      transparent_data_encryption_enabled = true
      
      threat_detection_policy = {
        state                      = "Enabled"
        email_account_admins       = true
        email_addresses            = [var.admin_email]
        retention_days             = 30
      }
      
      short_term_retention_policy = {
        retention_days = 35
      }
      
      long_term_retention_policy = {
        weekly_retention  = "P4W"
        monthly_retention = "P12M"
        yearly_retention  = "P5Y"
        week_of_year      = 1
      }
    }
  }

  virtual_network_rules = {
    web_subnet = {
      subnet_id = module.vnet.subnet_ids["web"]
    }
    app_subnet = {
      subnet_id = module.vnet.subnet_ids["app"]
    }
    data_subnet = {
      subnet_id = module.vnet.subnet_ids["data"]
    }
  }

  security_alert_policy = {
    state                      = "Enabled"
    email_account_admins       = true
    email_addresses            = [var.admin_email]
    retention_days             = 30
  }

  tags = var.tags

  depends_on = [module.vnet]
}

# Create AKS cluster for containerized applications
module "aks" {
  source = "../../azure/aks"

  cluster_name        = "${var.environment}-${var.project}-aks"
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix         = "${var.environment}-${var.project}"
  kubernetes_version = var.kubernetes_version
  sku_tier          = "Paid"
  
  private_cluster_enabled = true
  private_dns_zone_id    = "System"

  default_node_pool = {
    name                = "system"
    node_count          = 3
    vm_size             = "Standard_D4s_v3"
    vnet_subnet_id      = module.vnet.subnet_ids["aks"]
    availability_zones  = ["1", "2", "3"]
    enable_auto_scaling = true
    min_count          = 3
    max_count          = 10
    max_pods           = 110
    os_disk_size_gb    = 128
    os_disk_type       = "Managed"
    only_critical_addons_enabled = true
    
    upgrade_settings = {
      max_surge = "33%"
    }
  }

  additional_node_pools = {
    user = {
      vm_size             = "Standard_D4s_v3"
      node_count          = 2
      availability_zones  = ["1", "2", "3"]
      enable_auto_scaling = true
      min_count          = 2
      max_count          = 20
      max_pods           = 110
      mode               = "User"
      os_disk_size_gb    = 128
      vnet_subnet_id     = module.vnet.subnet_ids["aks"]
      
      upgrade_settings = {
        max_surge = "33%"
      }
    }
  }

  identity = {
    type = "SystemAssigned"
  }

  linux_profile = {
    admin_username = "azureuser"
    ssh_key        = tls_private_key.ssh.public_key_openssh
  }

  network_profile = {
    network_plugin     = "azure"
    network_policy     = "azure"
    dns_service_ip     = "10.0.0.10"
    service_cidr       = "10.0.0.0/16"
    load_balancer_sku  = "standard"
  }

  api_server_access_profile = {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  azure_policy_enabled = true
  
  oms_agent = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  ingress_application_gateway = {
    gateway_id = azurerm_application_gateway.main.id
  }

  key_vault_secrets_provider = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  auto_scaler_profile = {
    balance_similar_node_groups = false
    expander                   = "random"
    max_graceful_termination_sec = "600"
    max_node_provisioning_time = "15m"
    max_unready_nodes         = 3
    max_unready_percentage    = 45
    new_pod_scale_up_delay    = "10s"
    scale_down_delay_after_add = "10m"
    scale_down_delay_after_delete = "10s"
    scale_down_delay_after_failure = "3m"
    scan_interval             = "10s"
    scale_down_unneeded      = "10m"
    scale_down_unready       = "20m"
    scale_down_utilization_threshold = "0.5"
  }

  workload_identity_enabled = true
  oidc_issuer_enabled      = true
  image_cleaner_enabled    = true
  image_cleaner_interval_hours = 24

  tags = var.tags

  depends_on = [module.vnet, azurerm_application_gateway.main]
}

# Create VMs for legacy applications
module "web_vm" {
  source = "../../azure/vm"

  name                = "${var.environment}-${var.project}-web"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vm_size             = "Standard_D2s_v3"
  
  admin_username = "azureuser"
  disable_password_authentication = true
  ssh_public_key = tls_private_key.ssh.public_key_openssh
  
  subnet_id = module.vnet.subnet_ids["web"]
  network_security_group_id = module.vnet.network_security_group_ids["web"]
  
  create_public_ip = false
  zone            = "1"
  
  identity = {
    type = "SystemAssigned"
  }

  boot_diagnostics = {
    storage_account_uri = module.storage.primary_blob_endpoint
  }

  custom_data = base64encode(templatefile("${path.module}/scripts/web-init.sh", {
    storage_account_name = module.storage.storage_account_name
  }))

  extensions = {
    monitoring = {
      publisher            = "Microsoft.Azure.Monitor"
      type                = "AzureMonitorLinuxAgent"
      type_handler_version = "1.0"
    }
  }

  tags = var.tags

  depends_on = [module.vnet, module.storage]
}

module "app_vm" {
  source = "../../azure/vm"

  name                = "${var.environment}-${var.project}-app"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vm_size             = "Standard_D4s_v3"
  
  admin_username = "azureuser"
  disable_password_authentication = true
  ssh_public_key = tls_private_key.ssh.public_key_openssh
  
  subnet_id = module.vnet.subnet_ids["app"]
  network_security_group_id = module.vnet.network_security_group_ids["app"]
  
  create_public_ip = false
  zone            = "2"
  
  identity = {
    type = "SystemAssigned"
  }

  boot_diagnostics = {
    storage_account_uri = module.storage.primary_blob_endpoint
  }

  custom_data = base64encode(templatefile("${path.module}/scripts/app-init.sh", {
    storage_account_name = module.storage.storage_account_name
    sql_server_name     = module.sql.sql_server_name
  }))

  extensions = {
    monitoring = {
      publisher            = "Microsoft.Azure.Monitor"
      type                = "AzureMonitorLinuxAgent"
      type_handler_version = "1.0"
    }
  }

  tags = var.tags

  depends_on = [module.vnet, module.storage, module.sql]
}

# Create RBAC assignments for proper access control
module "rbac" {
  source = "../../azure/rbac"

  # Create service principals for applications
  service_principals = {
    app_service_principal = {
      display_name = "${var.environment}-${var.project}-app-sp"
      description  = "Service Principal for ${var.project} application"
      password = {
        display_name = "App Password"
        end_date     = "2025-12-31T23:59:59Z"
      }
    }
    monitoring_service_principal = {
      display_name = "${var.environment}-${var.project}-monitoring-sp"
      description  = "Service Principal for monitoring services"
      password = {
        display_name = "Monitoring Password"
        end_date     = "2025-12-31T23:59:59Z"
      }
    }
  }

  # Create Azure AD groups for role-based access
  groups = {
    developers = {
      display_name     = "${var.environment}-${var.project}-developers"
      description      = "Developers group for ${var.project}"
      security_enabled = true
      members          = var.developer_user_ids
    }
    operators = {
      display_name     = "${var.environment}-${var.project}-operators"
      description      = "Operations team for ${var.project}"
      security_enabled = true
      members          = var.operator_user_ids
    }
  }

  # Role assignments for different resources
  role_assignments = concat(
    # AKS cluster access
    [
      {
        principal_id         = module.rbac.group_ids["developers"]
        role_definition_name = "Azure Kubernetes Service Cluster User Role"
        scope               = module.aks.cluster_id
      },
      {
        principal_id         = module.rbac.group_ids["operators"]
        role_definition_name = "Azure Kubernetes Service RBAC Admin"
        scope               = module.aks.cluster_id
      }
    ],
    # Storage account access
    [
      {
        principal_id         = module.web_vm.vm_identity[0].principal_id
        role_definition_name = "Storage Blob Data Reader"
        scope               = module.storage.storage_account_id
      },
      {
        principal_id         = module.app_vm.vm_identity[0].principal_id
        role_definition_name = "Storage Blob Data Contributor"
        scope               = module.storage.storage_account_id
      }
    ],
    # SQL Server access
    [
      {
        principal_id         = module.rbac.group_ids["developers"]
        role_definition_name = "SQL DB Contributor"
        scope               = module.sql.sql_server_id
      }
    ]
  )

  tags = var.tags

  depends_on = [module.aks, module.storage, module.sql, module.web_vm, module.app_vm]
}

# Create Key Vault for secrets management
resource "azurerm_key_vault" "main" {
  name                = "${var.environment}-${var.project}-kv"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    virtual_network_subnet_ids = [
      module.vnet.subnet_ids["web"],
      module.vnet.subnet_ids["app"],
      module.vnet.subnet_ids["aks"]
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
    ]

    certificate_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers"
    ]
  }

  tags = var.tags
}

# Store SQL password in Key Vault
resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-admin-password"
  value        = random_password.sql_password.result
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags
}

# Store SSH private key in Key Vault
resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-private-key"
  value        = tls_private_key.ssh.private_key_pem
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags
}