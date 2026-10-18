# Ansible Interview Q&A (based on this project)

**What is Ansible and why agentless?** Configuration management/automation tool that pushes changes over SSH using temporary modules. Nothing to install or maintain on targets, so a smaller attack surface and quick adoption.

**Ansible vs Terraform?** Terraform provisions infrastructure (declarative, state file). Ansible configures what runs on it (and can also provision). Here CloudFormation creates the servers and Ansible configures them.

**Push vs pull?** Ansible pushes from a control node. Puppet/Chef agents pull from a server.

**What is idempotency? How did you prove it?** Re-running yields no change. I ran playbooks twice and checked `changed=0`. Tasks like `command` are not idempotent unless guarded with `creates`, `changed_when`, or `stat`.

**Explain inventory, group_vars and precedence.** Inventory defines hosts/groups; `group_vars` attaches variables per group. Role defaults are lowest; extra vars (`-e`) win.

**What are handlers?** Tasks run once at the end of a play when notified by a changed task, e.g. reload nginx only if its config changed.

**Role vs playbook?** A playbook maps hosts to roles/tasks; a role is a reusable, standardized directory (tasks, defaults, templates, handlers, meta).

**How do you manage secrets?** Ansible Vault (`ansible-vault encrypt`), `no_log: true` on sensitive tasks, never commit secrets; in larger setups use HashiCorp Vault or AWS Secrets Manager lookups.

**How do you do zero-downtime updates?** `serial`, `max_fail_percentage`, health checks (`uri`), and load-balancer drain via `delegate_to`.

**`command` vs `shell` vs module?** Prefer modules (idempotent, structured). `command` has no shell features; `shell` does but is riskier.

**What is `become`?** Privilege escalation (sudo) per play or task.

**How do you test Ansible code?** `--syntax-check`, `--check --diff`, yamllint, ansible-lint, Molecule for role testing, CI (see `.github/workflows/ci.yml`).

**What are facts?** Data gathered by the `setup` module (OS, IPs, memory) available as `ansible_facts`. Disable with `gather_facts: false` for speed.

**Dynamic inventory?** Plugins (e.g. `amazon.aws.aws_ec2`) build inventory from the cloud API, grouped by tags - the next step beyond this project's static file.

**How would you scale to 500 servers?** Dynamic inventory, `forks`, SSH pipelining, mitigation of failures with `serial`, AWX/AAP for RBAC and scheduling.

**Tell me about a problem you debugged.** Lab 2 originally used `copy` and `lineinfile` on the same file; each run `copy` reset it and `lineinfile` re-added the line, so it reported changed forever. Fixed by giving each task its own file - a real idempotency bug found by running twice.
