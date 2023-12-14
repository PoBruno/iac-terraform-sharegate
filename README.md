
# IaC - Terraform - Azure - Sharegate Server

## Description
This module creates a Virtual Machine in Azure to be used as a Sharegate server.
Automatically creates a Virtual Machine, a Network Interface, a Public IP, a Network Security Group and a Virtual Network.
Automatically installs Sharegate on the Virtual Machine.

Set how many nodes you want to create and the size of the Virtual Machine.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| azurerm | >= 2.0.0 |

# Sample Usage

## Environment Variables

File terraform.tfvars contains the following environment variables:
    
```hcl
# Path: terraform.tfvars
# Compare this snippet from terraform.tfvars:
subscription_id = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
node_location   = "Brazil South"
resource_prefix = "srv-sharegate"
Environment     = "Development"
node_count      = 2
admin_username  = "XXXXXX"
admin_password  = "XXXXXX"
vm_size         = "Standard_D4s_v3" 
```

Set the evnironment variables with correct values


## Azure Login

- Azure login using the Azure CLI
- Set the subscription ID to use
    
```bash
az login
az account set --subscription="SUBSCRIPTION_ID"
az account show
```

## Terraform

#### Terraform Init

- The following command will initialize the Terraform working directory by downloading and installing any Terraform modules needed for this configuration.

```bash
terraform init
```

#### Terraform Plan

- The following command will create an execution plan.
- The execution plan shows what actions Terraform will take to create the resources defined in the configuration files.

```bash
terraform plan
```

#### Terraform Apply

- The following command will apply the changes required to reach the desired state of the configuration.
- This command will execute the actions proposed in a Terraform plan.

```bash
terraform apply
```
Note: The -auto-approve flag will skip interactive approval of plan before applying.

```bash
terraform apply -auto-approve
```

#### Terraform Apply - Auto Approve - Input Variables

- The following command will apply the changes required to reach the desired state of the configuration.

```bash
terraform apply -auto-approve `
    -var="admin_username=XXXXXX" `
    -var="admin_password=XXXXXX" `
    -var="vm_size=Standard_D4s_v3" `
    -var="node_count=2" `
    -var="node_location=Brazil South" `
    -var="resource_prefix=srv-sharegate" `
    -var="Environment=Development"
        
```

#### Terraform Destroy

- This command will destroy all resources created by this configuration.
- This command will not destroy resources created outside of Terraform.

```bash
terraform destroy -auto-approve
```

## Output

```bash
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

admin_password = XXXXXXXX
admin_username = XXXXXXXX
node_address   = [
]
node_name      = [
  "srv-sharegate-01",
  "srv-sharegate-02",
]
node_private_ip = [
    "XX.XX.XX.XX",
    "XX.XX.XX.XX",
]
node_public_ip = [
    "XX.XX.XX.XX",
    "XX.XX.XX.XX",
    ]

node_size      = [
  "Standard_D4s_v3",
  "Standard_D4s_v3",
]
node_subnet_id = [
  "/subscriptions/XXXXXXXX-/virtualNetworks/vnet-sharegate/subnets/subnet-sharegate",
  "/subscriptions/XXXXXXXX-/virtualNetworks/vnet-sharegate/subnets/subnet-sharegate",
]
node_vm_id     = [
  "/subscriptions/XXXXXXXX.Compute/virtualMachines/srv-sharegate-01",
  "/subscriptions/XXXXXXXX.Compute/virtualMachines/srv-sharegate-02",
]
```

## SSH Connection

```bash
ssh user@PublicIP
```
## Module arguments

The following arguments are supported:

* `name` - (Required) Specifies the name of the virtual machine. Changing this forces a new resource to be created.
* `resource_group_name` - (Required) The name of the resource group in which to create the virtual machine.
* `location` - (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
* `vm_name` - (Required) The name of the virtual machine.
* `vm_size` - (Required) Specifies the size of the virtual machine. Changing this forces a new resource to be created. See also Azure VM Sizes.
* `admin_username` - (Required) The administrator username to use for the VM.
* `admin_password` - (Required) The administrator password to use for the VM.
* `subnet_id` - (Required) The ID of the subnet to which to attach the VM.
* `tags` - (Optional) A mapping of tags to assign to the resource.

## Module outputs

The following outputs are exported:

* `vm_id` - The ID of the virtual machine.
* `vm_name` - The name of the virtual machine.
* `vm_size` - The size of the virtual machine.
* `vm_os_simple` - The operating system of the virtual machine.
* `vm_os_publisher` - The publisher of the operating system of the virtual machine.
* `vm_os_offer` - The offer of the operating system of the virtual machine.
* `vm_os_sku` - The SKU of the operating system of the virtual machine.
* `vm_os_version` - The version of the operating system of the virtual machine.
* `vm_computer_name` - The computer name of the virtual machine.
* `vm_admin_username` - The administrator username of the virtual machine.
* `vm_network_interface_ids` - The IDs of network interfaces associated with the virtual machine.
* `vm_power_state` - The power state of the virtual machine.
* `vm_provisioning_state` - The provisioning state of the virtual machine.
* `vm_storage_image_reference_id` - The ID of the storage image reference of the virtual machine.
* `vm_storage_os_disk_id` - The ID of the storage OS disk of the virtual machine.
* `vm_storage_data_disk_ids` - The IDs of the storage data disks of the virtual machine.
* `vm_os_disk_id` - The ID of the OS disk of the virtual machine.
* `vm_data_disk_ids` - The IDs of the data disks of the virtual machine.
* `vm_identity_ids` - The identity of the virtual machine.
* `vm_zones` - The availability zones of the virtual machine.
* `vm_plan_name` - The name of the virtual machine.
* `vm_plan_product` - The product of the virtual machine.
* `vm_plan_publisher` - The publisher of the virtual machine.
* `vm_plan_promotion_code` - The promotion code of the virtual machine.
* `vm_plan_version` - The version of the virtual machine.
* `vm_license_type` - Specifies that the image or disk that is being used was licensed on-premises. This element is only used for images that contain the Windows Server operating system.
* `vm_host_id` - Specifies the ID which uniquely identifies a Virtual Machine hosted on a dedicated physical server.
* `vm_proximity_placement_group_id` - Specifies the ID of the proximity placement group the virtual machine is in.


## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password | The administrator password to use for the VM. | `string` | n/a | yes |
| admin\_username | The administrator username to use for the VM. | `string` | n/a | yes |
| environment | The environment name. | `string` | n/a | yes |
| location | Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| node\_count | The number of nodes to create. | `number` | n/a | yes |
| node\_location | The location where the nodes will be created. | `string` | n/a | yes |
| node\_size | Specifies the size of the virtual machine. Changing this forces a new resource to be created. See also Azure VM Sizes. | `string` | n/a | yes |
| resource\_prefix | The prefix for the resources. | `string` | n/a | yes |
| subscription\_id | The subscription ID to use. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resource. | `map(string)` | n/a | yes |
| vm\_name | The name of the virtual machine. | `string` | n/a | yes |
| vm\_size | Specifies the size of the virtual machine. Changing this forces a new resource to be created. See also Azure VM Sizes. | `string` | n/a | yes |
| subnet\_id | The ID of the subnet to which to attach the VM. | `string` | n/a | yes |

# Outputs

| Name | Description |
|------|-------------|
| admin\_password | The administrator password to use for the VM. |
| admin\_username | The administrator username to use for the VM. |
| node\_address | The public IP address of the nodes. |
| node\_name | The name of the nodes. |
| node\_private\_ip | The private IP address of the nodes. |
| node\_public\_ip | The public IP address of the nodes. |
| node\_size | The size of the nodes. |
| node\_subnet\_id | The ID of the subnet to which to attach the VM. |
| node\_vm\_id | The ID of the nodes. |


