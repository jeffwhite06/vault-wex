# Provides access to Application Kubernetes and IAM roles.

# Read shared KV secrets
path "secret/+/shared/*" {
  capabilities = ["read", "list"]
}

# Read entity environment secrets
path "secret/+/{{identity.entity.metadata.environment}}/*" {
  capabilities = ["read", "list"] 
}