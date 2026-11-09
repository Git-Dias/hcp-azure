# HCP Azure

A practice project for working with **HCP Terraform**, **GitHub** and **Azure** together. GitHub holds the code and runs the workflows, HCP Terraform runs the plans and applies, and Azure hosts the resources.

## How changes reach Azure

Changes move through three branches, and Terraform only runs at the last two:

| Step | Branch | What HCP Terraform does |
|---|---|---|
| 1. Develop | `staging` | Nothing |
| 2. Preview | Pull request into `homol` | Runs a speculative plan and comments the result on the pull request |
| 3. Deploy | Merge into `main` | Runs a new plan and, if it succeeds, applies it |

Merging into `homol` and opening a pull request into `main` don't start any runs.

## Lab layout

Each service lives in its own module under `modules/` (`network`, `storage`, `bot`, `vm_linux`, `vmss_linux`). The Key Vault is the exception: it's declared directly in `main.tf` with literal values, so the IaC scanner can evaluate it without resolving module variables.

- **What gets provisioned:** turn modules on or off with the `enable_*` flags in `lab.auto.tfvars`. The VM and the VMSS need `enable_network = true`.
- **Pass or fail:** by default every resource is compliant. To make one fail a rule, change the value shown in the `# FAIL:` comment next to that line in `main.tf`.