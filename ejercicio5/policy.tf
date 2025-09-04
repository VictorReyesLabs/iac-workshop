data "azurerm_subscription" "current" {}

resource "azurerm_policy_definition" "require_cmk" {
  name         = "require-cmk-storage"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Requerir CMK en Storage Accounts"
  description  = "Se asegura que todos los Storage Accounts usen customer-managed keys para cifrado."

  policy_rule = <<POLICY
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Storage/storageAccounts"
      },
      {
        "not": {
          "field": "Microsoft.Storage/storageAccounts/encryption.keySource",
          "equals": "Microsoft.Keyvault"
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

resource "azurerm_subscription_policy_assignment" "require_cmk_assignment" {
  name                 = "assign-require-cmk-storage"
  policy_definition_id = azurerm_policy_definition.require_cmk.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = "eastus"
}
