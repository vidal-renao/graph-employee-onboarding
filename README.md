# Graph Employee Onboarding

PowerShell lab for validating employee lifecycle workflows before connecting them to Microsoft Graph.

**Status: dry-run simulation. Live Graph provisioning is not implemented.**

## What you can review

- Employee data read from CSV and required-attribute validation.
- Simulated user creation, group membership and license assignment.
- Timestamped logs and per-run CSV reports in `out/`.
- A separate offboarding simulation for account disable, session revocation and optional group/license removal.

## Run the onboarding simulation

From the repository root, with PowerShell 7 installed:

```powershell
pwsh -File ./src/Onboard-Employees.ps1 -CsvPath ./data/employees.sample.csv -Mode DryRun
```

Inspect the generated log and report in `out/`. Use the sample CSV to understand the expected input format.

The `Live` mode is a placeholder that exits without provisioning. The Graph helper modules are scaffolding; this repository does not create Microsoft 365 accounts or assign real licenses.

## Repository guide

| Path | Purpose |
|---|---|
| `src/Onboard-Employees.ps1` | Onboarding entry point |
| `src/Offboard-Employees.ps1` | Offboarding simulation |
| `data/employees.sample.csv` | Onboarding sample data |
| `data/offboarding.sample.csv` | Offboarding sample data |
| [Architecture](docs/architecture.md) | Design notes |

## Skills demonstrated

PowerShell scripting, input validation, identity lifecycle modeling, structured logging and operational reporting.

[Portfolio](https://vidal-pro-portfolio.vercel.app/en) · [LinkedIn](https://www.linkedin.com/in/vidalrenao/)
