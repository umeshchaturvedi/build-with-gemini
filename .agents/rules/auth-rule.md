---
trigger: always_on
---

# Authentication & Account Selection Rule

- **STRICT PROHIBITION**: NEVER use or authenticate with `chaturvedi.umesh@gmail.com` for any GCP service, API, gcloud CLI command, ADC, or tool invocation.
- **MANDATORY USER PROMPT**: ALWAYS prompt the user to select or confirm which account/identity to use for authentication and GCP project operations.
- **CONSISTENCY CHECK**: Verify that both `gcloud` CLI and Application Default Credentials (ADC) are bound to the approved student/lab account, never `chaturvedi.umesh@gmail.com`.
