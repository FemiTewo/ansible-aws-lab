# Ansible AWS Lab

![CI](https://github.com/FemiTewo/ansible-aws-lab/actions/workflows/ci.yml/badge.svg)

A hands-on Ansible project: a CloudFormation-built lab of **3 Ubuntu 22.04 servers**
(1 control node, 1 web, 1 database) configured entirely with Ansible - 8 progressive labs,
3 reusable roles, Vault for secrets, rolling updates, and CI linting.

```
 your PC (PowerShell + AWS CLI)
        |  CloudFormation
        v
 +-------------------- AWS VPC / one security group --------------------+
 |  control (Ansible)  --SSH-->  web1 (nginx)                           |
 |                     --SSH-->  db1  (PostgreSQL)                      |
 +----------------------------------------------------------------------+
```

## What you will learn
Inventory, ad-hoc commands, playbooks, idempotency, variables, loops, conditionals, facts,
templates (Jinja2), handlers, roles, error handling, Vault, tags, check/diff mode, rolling updates, linting + CI.

## Project layout
| Path | Purpose |
|---|---|
| `infra/lab.yaml` | CloudFormation template for the 3 servers |
| `scripts/` | `lab-up.ps1`, `lab-down.ps1`, `bootstrap-control.sh`, `make-inventory.sh` |
| `ansible.cfg` | Project defaults (user, key, inventory) |
| `inventory/` | Hosts, `group_vars` |
| `playbooks/01..08` | The 8 labs |
| `roles/` | `common`, `nginx`, `postgres` |
| `site.yml` | Capstone - builds everything with roles |
| `docs/` | `TUTORIAL.md`, `BREAK-FIX.md`, `INTERVIEW.md` |

## Quick start
1. **PC (PowerShell)**: `.\scripts\lab-up.ps1 -KeyName MyKeyPair3` and note the outputs.
2. Copy your key to the control node, SSH in, clone this repo, then follow **[docs/TUTORIAL.md](docs/TUTORIAL.md)**.
3. **When finished, always run `.\scripts\lab-down.ps1`** - the lab uses 3 instances and burns credits while it exists.

## Cost
3 x t3.micro for a few hours is pennies, but only if you delete the stack afterwards.

## Security notes
- `.pem` keys, `inventory/hosts.ini` and `vars/secrets.yml` are git-ignored. Never commit them.
- Lab database password defaults are for the lab only; real values go in Ansible Vault.
- Restrict SSH: pass `AllowedSshCidr=YOUR.IP/32` in the stack parameters.

## License
MIT
