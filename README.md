

# IaC - Nodes Sharegate Azure VMs
Bruno Gomes - [GitHub](https://www.github.com/pobruno) - [LinkedIn](https://www.linkedin.com/in/brunopoleza/) - [Microsoft](https://learn.microsoft.com/en-us/users/brunopoleza/)

---

### Descrição 

Este módulo cria uma Máquina Virtual no Azure para ser usada como servidor Sharegate.Ele provisiona automaticamente uma Máquina Virtual, uma Interface de Rede, um IP Público, um Grupo de Segurança de Rede e uma Rede Virtual. Além disso, instala o Sharegate na Máquina Virtual.

Defina quantos nós deseja criar e o tamanho da Máquina Virtual.  

### Requisitos  

| Nome | Versão |
|------|---------| 
| terraform | >= 0.12.0 | 
| azurerm | >= 2.0.0 |  

# Tutorial 

## Variáveis de Ambiente  

O arquivo `terraform.tfvars` contém as seguintes variáveis de ambiente:<br>
- Defina as variáveis de ambiente com os valores corretos.     

```hcl # Caminho: terraform.tfvars 
# Compare este trecho de terraform.tfvars: 
subscription_id = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
node_location   = "Brazil South"
resource_prefix = "srv-sharegate"
Environment     = "Development"
node_count      = 2
admin_username  = "XXXXXX"
admin_password  = "XXXXXX"
vm_size         = "Standard_D4s_v3" 

tags = {
  project     = "MigrationProject"
  access      = "terraform"
  environment = "development"
  application = "sharegate"
}

windows_image_reference = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2019-Datacenter"
  version   = "latest"
}

```


## Login no Azure

- Login no Azure usando o Azure CLI
- Defina o ID da assinatura a ser utilizado


```Shell
az login az account set --subscription="SUBSCRIPTION_ID" az account show
```

## Terraform

#### Terraform Init

- O comando a seguir inicializará o diretório de trabalho do Terraform, baixando e instalando quaisquer módulos do Terraform necessários para esta configuração.

```Shell
terraform init
```

#### Terraform Plan

- O comando a seguir criará um plano de execução.
- O plano de execução mostra quais ações o Terraform realizará para criar os recursos definidos nos arquivos de configuração.

```Shell
terraform plan
```

#### Terraform Apply

- O comando a seguir aplicará as alterações necessárias para alcançar o estado desejado da configuração.
- Este comando executará as ações propostas em um plano do Terraform.

**Observação:** _A flag `-auto-approve` ignorará a aprovação interativa do plano antes da aplicação._

```Shell
terraform apply -auto-approve
```

#### Terraform Apply - Auto Approve - Variáveis de Entrada

- O comando a seguir aplicará as alterações necessárias para alcançar o estado desejado da configuração.


```Shell
terraform apply -auto-approve `    
-var="admin_username=XXXXXX" `    
-var="admin_password=XXXXXX" `     
-var="vm_size=Standard_D4s_v3" `     
-var="node_count=2" `     
-var="node_location=Brazil South" `     
-var="resource_prefix=srv-sharegate" `     
-var="Environment=Development"``
-var="subscription_id=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
-var="tags={project="MigrationProject",access="terraform",environment="development",application="sharegate"}" `
-var="windows_image_reference={publisher="MicrosoftWindowsServer",offer="WindowsServer",sku="2019-Datacenter",version="latest"}"
```

#### Terraform Destroy

- Este comando destruirá todos os recursos criados por esta configuração.
- Este comando não destruirá recursos criados fora do Terraform.

```Shell
terraform destroy -auto-approve
```


## Conexão SSH

```Shell
ssh user@PublicIP
```

## Argumentos do Módulo

Os seguintes argumentos são suportados:

- `name` - (Obrigatório) Especifica o nome da máquina virtual. Alterar isso forçará a criação de um novo recurso.
- `resource_group_name` - (Obrigatório) O nome do grupo de recursos no qual criar a máquina virtual.
- `location` - (Obrigatório) Especifica a localização do Azure suportada onde o recurso existe. Alterar isso forçará a criação de um novo recurso.
- `vm_name` - (Obrigatório) O nome da máquina virtual.
- `vm_size` - (Obrigatório) Especifica o tamanho da máquina virtual. Alterar isso forçará a criação de um novo recurso. Consulte também os tamanhos de VM do Azure.
- `admin_username` - (Obrigatório) O nome de usuário do administrador para usar na VM.
- `admin_password` - (Obrigatório) A senha do administrador para usar na VM.
- `subnet_id` - (Obrigatório) O ID da sub-rede à qual anexar a VM.
- `tags` - (Opcional) Um mapeamento de tags para atribuir ao recurso.

## Saídas do Módulo

As seguintes saídas são exportadas:

- `vm_id` - O ID da máquina virtual.
- `vm_name` - O nome da máquina virtual.
- `vm_size` - O tamanho da máquina virtual.
- `vm_os_simple` - O sistema operacional da máquina virtual.
- `vm_os_publisher` - O editor do sistema operacional da máquina virtual.
- `vm_os_offer` - A oferta do sistema operacional da máquina virtual.
- `vm_os_sku` - O SKU do sistema operacional da máquina virtual.
- `vm_os_version` - A versão do sistema operacional da máquina virtual.
- `vm_computer_name` - O nome do computador da máquina virtual.
- `vm_admin_username` - O nome de usuário do administrador da máquina virtual.
- `vm_network_interface_ids` - Os IDs das interfaces de rede associadas à máquina virtual.
- `vm_power_state` - O estado de energia da máquina virtual.
- `vm_provisioning_state` - O estado de provisionamento da máquina virtual.
- `vm_storage_image_reference_id` - O ID da referência de imagem de armazenamento da máquina virtual.
- `vm_storage_os_disk_id` - O ID do disco OS de armazenamento da máquina virtual.
- `vm_storage_data_disk_ids` - Os IDs dos discos de dados de armazenamento da máquina virtual.
- `vm_os_disk` - O disco OS da máquina virtual.

## Inputs

|Nome|Descrição|Tipo|Padrão|Obrigatório|
|---|---|---|---|---|
|admin_password|A senha do administrador para usar na VM.|string|n/a|sim|
|admin_username|O nome de usuário do administrador para usar na VM.|string|n/a|sim|
|environment|O nome do ambiente.|string|n/a|sim|
|location|Especifica a localização do Azure suportada onde o recurso existe. Alterar isso forçará a criação de um novo recurso.|string|n/a|sim|
|node_count|O número de nós a serem criados.|number|n/a|sim|
|node_location|O local onde os nós serão criados.|string|n/a|sim|
|node_size|Especifica o tamanho da máquina virtual. Alterar isso forçará a criação de um novo recurso. Consulte também os tamanhos de VM do Azure.|string|n/a|sim|
|resource_prefix|O prefixo para os recursos.|string|n/a|sim|
|subscription_id|O ID da assinatura a ser utilizado.|string|n/a|sim|
|tags|Um mapeamento de tags para atribuir ao recurso.|map(string)|n/a|sim|
|vm_name|O nome da máquina virtual.|string|n/a|sim|
|vm_size|Especifica o tamanho da máquina virtual. Alterar isso forçará a criação de um novo recurso. Consulte também os tamanhos de VM do Azure.|string|n/a|sim|
|subnet_id|O ID da sub-rede à qual anexar a VM.|string|n/a|sim|

# Saídas

|Nome|Descrição|
|---|---|
|admin_password|A senha do administrador para usar na VM.|
|admin_username|O nome de usuário do administrador para usar na VM.|
|node_address|O endereço IP público dos nós.|
|node_name|O nome dos nós.|
||O endereço IP privado dos nós.|
|node_public_ip|O endereço IP público dos nós.|
|node_size|O tamanho dos nós.|
|node_subnet_id|O ID da sub-rede à qual anexar a VM.|
|node_vm_id|O ID dos nós.|


## Licença

MIT



## Referências

- [Terraform](https://www.terraform.io/)
- [Azure](https://azure.microsoft.com/pt-br/)
- [Sharegate](https://www.sharegate.com/)
- [Terraform Azure Virtual Machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine)
- [Terraform Azure Virtual Machine Data Disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment)
- [Terraform Azure Virtual Machine Extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension)
- [Terraform Azure Virtual Machine Network Interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)
- [Terraform Azure Virtual Machine Network Interface Security Group Association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association)
- [Terraform Azure Virtual Machine Public IP](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)
- [Terraform Azure Virtual Machine Scale Set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set)
- [Terraform Azure Virtual Machine Scale Set Extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension)
- [Terraform Azure Virtual Machine Scale Set Network Interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_network_interface)
- [Terraform Azure Virtual Machine Scale Set Public IP](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_public_ip)
- [Terraform Azure Virtual Machine Scale Set Virtual Machine Extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_virtual_machine_extension)






