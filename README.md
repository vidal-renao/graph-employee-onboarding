# Graph Employee Onboarding (Dry-Run)

Enterprise-style automation project for employee onboarding using Microsoft Graph.

## Purpose
This repository demonstrates how employee onboarding can be automated in a
corporate IT environment following best practices:
- GitHub as single source of truth
- Structured PowerShell scripts
- Dry-run execution before production
- CI with GitHub Actions

## What this project does
- Reads employee data from CSV files
- Validates required attributes
- Simulates:
  - User creation
  - Group membership assignment
  - License assignment
- Generates execution logs and reports

## Why dry-run
In real companies, identity automation is validated and reviewed before touching
production systems.  
This project follows the same approach by default.

## Technology stack
- PowerShell 7
- GitHub
- GitHub Actions
- Microsoft Graph (simulated)

## Project status
Work in progress – onboarding logic and CI pipeline will be added incrementally.
