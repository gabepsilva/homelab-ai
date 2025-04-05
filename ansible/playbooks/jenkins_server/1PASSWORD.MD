# 1Password Integration

## Jenkins Integration

Jenkins uses the 1Password CLI with a service account token for accessing secrets. The token is stored in the environment variable:

```
OP_SERVICE_ACCOUNT_TOKEN
```

This allows Jenkins to securely access required credentials and secrets without manual intervention.

## Local Development Setup

For local development:

1. Install the 1Password desktop application
2. Enable CLI integration in the 1Password desktop app:
   - Open 1Password settings
   - Navigate to the Developer section
   - Enable the CLI integration option

## Security Constraints

For security reasons, 1Password CLI is restricted to only read secrets from the designated "DevVault". This limitation ensures proper isolation of development secrets from production credentials.
