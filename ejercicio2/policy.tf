# ===========================================
# Data source para la suscripción actual
# ===========================================
data "azurerm_subscription" "current" {}

# ===========================================
# Definir Policy Definition para tags obligatorios
# ===========================================
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-tags"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require Environment and Owner tags"
  description  = "Todos los recursos deben tener los tags Environment y Owner"

  policy_rule = <<POLICY
{
  "if": {
    "anyOf": [
      {
        "field": "tags.Environment",
        "exists": "false"
      },
      {
        "field": "tags.Owner",
        "exists": "false"
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
# Asignar la policy a nivel de suscripción
# ===========================================
resource "azurerm_subscription_policy_assignment" "require_tags_assignment" {
  name                 = "require-tags-assignment"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  description          = "Asignación de política para requerir tags 'Environment' y 'Owner'"
  display_name         = "Requerir tags obligatorios"

  location = "eastus" # <- esto es obligatorio cuando se asigna identity

  identity {
    type = "SystemAssigned"
  }
}

