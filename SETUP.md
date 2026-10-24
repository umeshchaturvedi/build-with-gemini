# 🛠️ Setup Plan — build-with-gemini (Windows, local machine)

> Visual version: open [`docs/setup-plan.html`](docs/setup-plan.html) in a browser
> (interactive checklist + dependency diagram, progress is saved locally).

The upstream [lab guide](https://cszhu.github.io/build-with-gemini/) assumes the
pre-built **Linux / Qwiklabs** workstation. This guide adapts it for a **personal
Windows machine + your own GCP project**, and groups the work into **waves**.
Everything inside a wave can run **in parallel** (separate terminals / tabs);
a wave only starts when the items it depends on are done.

```
W1 Install ─┬─ gcloud ──────► W2 auth ──► W3 project+APIs ──► W4 infra ─┐
            ├─ Python + uv ─► W2 agents-cli ─┐                          │
            ├─ Node.js ──────────────────────┴► W3 agents-cli setup ─► W4 restart AGY
            ├─ Git + gh                                                 │
            └─ Brainstorm brief (AGY) ─────────────────────────────┐    ▼
                                                                   └► W5 Preflight ► W6 Scaffold
W7 Features (parallel) ► W8 Local test ► W9 Deploy* ► W10 Frontend ‖ Demo ► W11 Publish
                                                     * only when you explicitly ask
```

> [!WARNING]
> **Path gotcha:** this workspace lives under
> `D:\wspace\AI\Build & Deploy Production Ready AI Agents\`. The `&` and spaces
> break `.cmd` shims on Windows (`npx.cmd`, `npm.cmd`, some `uv` scripts) and must
> always be quoted in PowerShell. If the Firebase MCP or `npx` fails to start,
> clone/move the repo to a simple path such as `D:\wspace\build-with-gemini`.

---

## Wave 1 — Install toolchain (5 parallel lanes)

Open one PowerShell window per lane. (Windows Installer allows one MSI at a time,
so an MSI may briefly wait on another — that's normal.)

| Lane | Command | Why |
|---|---|---|
| **A · gcloud** | `winget install -e --id Google.CloudSDK` | auth, APIs, IAM, deploy |
| **B · Python + uv** | `winget install -e --id astral-sh.uv` then `uv python install 3.12` | ADK / agents-cli need Python 3.11+ |
| **C · Node.js** | `winget install -e --id OpenJS.NodeJS.LTS` | Firebase MCP (`npx`), agents-cli skill install, Playwright (`record-demo`) |
| **D · Git + GitHub** | `winget install -e --id Git.Git; winget install -e --id GitHub.cli` | final `publish-to-github` step |
| **E · Design (no deps)** | In Antigravity: *"Help me pick my agent project"* | runs `pick-your-agent-project` → writes `project_brief.md` |

> [!TIP]
> Lane **E** is pure brainstorming — start it right away and let the installs run
> in the background. It's the biggest time saver in the whole plan.

Restart your terminals after Wave 1 so the new `PATH` entries are picked up.

## Wave 2 — Authenticate & install CLI (parallel)

| Lane | Needs | Command |
|---|---|---|
| **A · gcloud auth** | A | `gcloud auth login` then `gcloud auth application-default login` (**both** are required — missing ADC is the #1 cause of 403s) |
| **B · agents-cli** | B | `uv tool install google-agents-cli` → `agents-cli --version` |
| **D · GitHub auth** | D | `gh auth login` |

## Wave 3 — Project & skills (parallel)

**Lane A — pin project + enable APIs** (needs Wave 2 A):

```powershell
$env:GOOGLE_CLOUD_PROJECT = "<your-project-id>"      # the ID, not the number
[Environment]::SetEnvironmentVariable("GOOGLE_CLOUD_PROJECT", $env:GOOGLE_CLOUD_PROJECT, "User")
gcloud config set project $env:GOOGLE_CLOUD_PROJECT
gcloud auth application-default set-quota-project $env:GOOGLE_CLOUD_PROJECT

# One call enables all APIs concurrently
gcloud services enable aiplatform.googleapis.com firestore.googleapis.com `
  storage.googleapis.com run.googleapis.com cloudbuild.googleapis.com `
  artifactregistry.googleapis.com developerknowledge.googleapis.com `
  cloudresourcemanager.googleapis.com
```

Billing must be enabled on the project. On a personal project the ID will **not**
contain `qwiklabs` — ignore that heuristic in the troubleshoot skill.

**Lane B+C — register agents-cli skills with Antigravity** (needs Wave 2 B + Node):

```powershell
agents-cli setup --skip-auth
```

## Wave 4 — Infrastructure & AGY reload (4 parallel lanes)

```powershell
# Lane 1 — IAM for your user
$me = gcloud config get-value account
gcloud projects add-iam-policy-binding $env:GOOGLE_CLOUD_PROJECT `
  --member="user:$me" --role="roles/aiplatform.user"

# Lane 2 — Firestore (default) DB (Native mode)
gcloud firestore databases create --location=nam5

# Lane 3 — Cloud Storage bucket for generated images / RAG docs
gcloud storage buckets create "gs://$env:GOOGLE_CLOUD_PROJECT-assets" --location=us-central1
```

**Lane 4 — Reload Antigravity:** fully restart AGY, open the `build-with-gemini`
folder, then run `/skills` (expect workshop skills **and** `google-agents-cli-*`)
and `/mcp` (expect `firebase` + `google-developer-knowledge`).

> [!NOTE]
> If the `firebase` MCP fails to start on Windows, change `"command": "npx"` to
> `"command": "npx.cmd"` in `.agents/mcp_config.json` (and see the path warning above).

## Wave 5 — Preflight gate 🚦

In Antigravity: **"Verify my setup."** (`troubleshoot-lab-setup`). Expected:

- ✅ AGY signed in with the same Google account as `gcloud auth list`
- ✅ Project pinned · ✅ gcloud + ADC · ✅ aiplatform API · ✅ `roles/aiplatform.user`
- ✅ `google-agents-cli-*` skills loaded
- ⏭️ **Skip check 6** (URL-open shim) — it only applies to the Linux Selkie desktop.

## Wave 6 — Scaffold (needs Wave 5 **and** `project_brief.md`)

In AGY: *"Scaffold my agent with agents-cli from project_brief.md."*
Always run ADK through the project venv: `uv run adk web --port 8080 --allow_origins "*" --reload_agents`
(bare `adk` uses the wrong interpreter).

## Wave 7 — Feature tracks (parallel, each touches different files)

| Track | Skill | Notes |
|---|---|---|
| 🧠 Memory | `setup-memory-bank` | PreloadMemoryTool + callback; deploy does **not** wire memory for you |
| 🗄️ Data + tools | ADK function tools + Firestore | pin Firestore by **project ID**, seed in the same project you deploy to |
| 📚 Grounding | `build-rag` | serverless RAG corpus; expose retrieval as a plain function tool |
| 🪟 UI cards | `enable-a2ui` | display-only in `adk web` |
| 🎨 Images | image tool + GCS bucket | public bucket URL; needs `storage.objectAdmin` once deployed |

> [!TIP]
> To parallelize with AGY, run each track in its own agent conversation and merge.
> Memory and A2UI both add callbacks to `agent.py` — merge those two carefully.

## Wave 8 — Local test

`uv run adk web …` or `agents-cli run`. Fix locally; **don't redeploy to test**
(see `.agents/rules/deploying.md`).

## Wave 9 — Deploy *(only when you explicitly ask)*

`agents-cli deploy`, then grant the Reasoning Engine service account its data roles:

```powershell
$num = gcloud projects describe $env:GOOGLE_CLOUD_PROJECT --format="value(projectNumber)"
$sa  = "serviceAccount:service-$num@gcp-sa-aiplatform-re.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding $env:GOOGLE_CLOUD_PROJECT --member=$sa --role="roles/datastore.user"
gcloud storage buckets add-iam-policy-binding "gs://$env:GOOGLE_CLOUD_PROJECT-assets" --member=$sa --role="roles/storage.objectAdmin"
```

## Wave 10 — Ship the face (parallel)

| Lane | Skill | Notes |
|---|---|---|
| 🌐 Frontend | `build-agent-frontend` | FastAPI A2A proxy → Cloud Run; grant the Cloud Run SA `roles/aiplatform.user` |
| 🎬 Demo | `record-demo` | can record against the ADK Playground (port 8000) without waiting for the frontend |

## Wave 11 — Publish

`publish-to-github` → push to your GitHub and submit the gallery form.

---

### Critical path

`gcloud install → auth (+ADC) → project + APIs → infra/IAM → preflight → scaffold → features → local test → deploy → frontend → publish`

Everything else (uv/Node/Git installs, the brief, agents-cli skills, demo
recording) runs alongside it.
