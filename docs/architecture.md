# Architecture

This repository follows an enterprise-style automation layout: input data is separated from code, execution is safe by default (dry-run), and outputs are stored for traceability.

## High-level flow (Dry-Run)

```mermaid
flowchart TD
  A[Employee CSV\n(data/employees.sample.csv)] --> B[Onboarding Script\n(src/Onboard-Employees.ps1)]
  B --> C{Validate required fields}
  C -- OK --> D[Simulate actions\n(DRY-RUN)]
  C -- FAILED --> E[Log error + mark FAILED]
  D --> F[Write logs\n(out/onboarding-*.log)]
  D --> G[Write report\n(out/onboarding-report-*.csv)]
  E --> F
  E --> G
