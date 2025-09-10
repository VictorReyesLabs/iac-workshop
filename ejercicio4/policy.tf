# ===========================================
# Data source para la suscripción actual
# ===========================================
data "azurerm_subscription" "current" {}

# ===========================================
# Policy Definition: tamaños de VM permitidos
# ===========================================
resource "azurerm_policy_definition" "allowed_vm_sizes" {
  name         = "allowed-vm-sizes-${random_string.suffix.result}"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Solo se permiten tamaños de VM específicos ${random_string.suffix.result}"

  policy_rule = <<POLICY
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Compute/virtualMachines"
      },
      {
        "not": {
          "field": "Microsoft.Compute/virtualMachines/sku.name",
          "in": ["Standard_B1s", "Standard_B2s"]
        }
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
POLICY
}

# ===========================================
# Asignación de la policy
# ===========================================
resource "azurerm_subscription_policy_assignment" "allowed_vm_sizes_assignment" {
  name                 = "assign-allowed-vm-sizes-${random_string.suffix.result}"
  policy_definition_id = azurerm_policy_definition.allowed_vm_sizes.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = var.location
}
