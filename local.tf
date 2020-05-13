locals {
    rg_name="${var.prefix}-rg"

    vm_publicip="${var.prefix}-ip"
    vm_name="${var.prefix}-vm"
    vm_disk="${var.prefix}-disk"
    vm_nsg="${var.prefix}-nsg"
    vm_ipconfig="${var.prefix}-in-config"
    vm_nic="${var.prefix}-in-nic"

    storage_container_name="scripts"

    vnet_name="${var.prefix}-vnet"
    vnet_iprange="10.0.0.0/24"
    vm_subnet="vm"
    vm_subnet_iprange="10.0.0.0/24"

}