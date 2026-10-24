---
trigger: always_on
---

# Multi-Lab Qwiklabs & Account Protocol

- **DYNAMIC LAB ACCOUNT & PROJECT**: Each Qwiklabs lab provides a temporary student username (`student-xx-xxxx@qwiklabs.net`) and a temporary GCP project ID (`qwiklabs-gcp-xx-xxxxxxxxxxxx`). NEVER assume or reuse past credentials.
- **ALWAYS ASK**: ALWAYS explicitly prompt the user for the **current student username** and **current GCP project ID** before running any GCP operation, gcloud command, ADC setup, or agent deployment.
- **CLEAR CACHE ON START**: At the start of an AGY session or when switching labs, clear old tokens and cached credentials (`credentials.db`, `access_tokens.db`, and `application_default_credentials.json`) and unset old `core/account` and `core/project` settings to avoid expired token errors.
- **STRICT PROHIBITION**: NEVER use or authenticate with `chaturvedi.umesh@gmail.com` under any circumstance.
