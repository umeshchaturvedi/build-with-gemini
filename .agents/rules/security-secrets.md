---
trigger: always_on
---

# Secrets & Credential Protection Protocol

- **STRICT PROHIBITION**: NEVER stage, commit, or push any sensitive information to GitHub or any remote VCS repository under any circumstances.
- **RESTRICTED ASSETS INCLUDE**:
  - API keys, OAuth tokens, personal access tokens (PATs), bearer tokens, secret keys.
  - User credentials, plaintext usernames and passwords.
  - Service account keys (*.json), private keys (*.pem, *.key, id_rsa, id_ed25519).
  - Google Cloud credentials (credentials.db, access_tokens.db, application_default_credentials.json).
  - Environment and secret files (.env, .env.*, secrets.json, credentials.json).
- **PRE-COMMIT AUDIT**: Always verify git staged files and .gitignore before committing to ensure no sensitive artifacts or tokens are included.
