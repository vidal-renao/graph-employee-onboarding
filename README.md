# Graph Employee Onboarding (Dry-Run)

Enterprise-style employee onboarding automation using Microsoft Graph (simulated).  
This project is designed like a corporate IT automation repo: structured scripts, dry-run safety, logging, reporting, and CI pipelines.

## What it does
- Reads employee data from a CSV file
- Validates required attributes
- Simulates onboarding actions (dry-run):
  - User creation
  - Group assignment
  - License assignment
- Produces per-run outputs:
  - Log file (`out/onboarding-YYYYMMDD-HHMMSS.log`)
  - CSV report (`out/onboarding-report-YYYYMMDD-HHMMSS.csv`)

## Why dry-run
In real companies, identity automation is validated and reviewed before touching production systems.  
This repository follows that approach by default.

## Repository structure
