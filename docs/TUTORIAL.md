# Ansible Hands-On Tutorial

Do the steps in order. Each lab builds on the last. Commands marked **PC** run in PowerShell on your
Windows machine; **CONTROL** means on the control node over SSH.

---
## Part 0 - Concepts (5 min)
- **Ansible is agentless**: the control node connects over SSH and runs small Python modules on targets.
- **Inventory**: the list of servers, grouped (`web`, `db`).
- **Playbook**: YAML describing the *desired state*. **Task** = one module call. **Module** = unit of work (apt, copy, service...).
- **Idempotent**: running twice changes nothing the second time. `changed=0` on a re-run is the goal.
- **Handler**: a task that runs only when notified by a change (e.g. reload nginx after config change).
- **Role**: a reusable folder bundle of tasks/templates/defaults/handlers.

## Part 1 - Build the lab
**PC**
```powershell
cd ansible-aws-lab
.\scripts\lab-up.ps1 -KeyName MyKeyPair3
```
Note `ControlPublicIp`, `WebPrivateIp`, `DbPrivateIp`.

Copy your key to the control node and connect:
```powershell
scp -i $HOME\MyKeyPair3.pem $HOME\MyKeyPair3.pem ubuntu@<ControlPublicIp>:~/lab.pem
ssh -i $HOME\MyKeyPair3.pem ubuntu@<ControlPublicIp>
```
(Replace `<ControlPublicIp>` with the real IP - no angle brackets.)

**CONTROL**
```bash
mkdir -p ~/.ssh && mv ~/lab.pem ~/.ssh/lab.pem && chmod 600 ~/.ssh/lab.pem
git clone https://github.com/FemiTewo/ansible-aws-lab.git && cd ansible-aws-lab
./scripts/bootstrap-control.sh
./scripts/make-inventory.sh WEB_PRIVATE_IP DB_PRIVATE_IP
```

## Part 2 - Ad-hoc commands
```bash
ansible all -m ping                     # (all = every host in inventory)
ansible lab -m command -a "uptime"
ansible lab -m setup -a "filter=ansible_distribution*"
ansible web -b -m apt -a "name=tree state=present"   # -b = become root
ansible-inventory --graph
```
Expected: `pong` from web1 and db1. **If ping fails**, see BREAK-FIX.md #1.

## Lab 1 - Facts and debug
`ansible-playbook playbooks/01_facts_and_adhoc.yml`
Learn: gather_facts, `debug`, `register`, `changed_when: false`.

## Lab 2 - Packages, users, files
`ansible-playbook playbooks/02_packages_users_files.yml` - **run it twice**.
Run 1 shows `changed`; run 2 shows `changed=0`. That is idempotency.
Try `--check --diff` to preview changes without applying.

## Lab 3 - A service, the plain way
`ansible-playbook playbooks/03_nginx_basic.yml`, then `curl http://WEB_PRIVATE_IP`.
Also open `http://WEB_PUBLIC_IP` in a browser (port 80 is open in the security group).
Learn: apt + copy + service + handler.

## Lab 4 - Variables, loops, conditionals
`ansible-playbook playbooks/04_variables_loops_conditionals.yml`
Learn: `loop`, `when`, `register`, `stat`, `group_names`, facts-driven logic.
Variable precedence (low to high): role defaults < group_vars < play vars < `-e` extra vars. Try `-e "users_to_create=[]"`.

## Lab 5 - Templates
`ansible-playbook playbooks/05_templates_and_handlers.yml`
Edit `nginx_site_title` in `inventory/group_vars/web.yml`, re-run: only the page changes and nginx reloads once.

## Lab 6 - Handling failure
`ansible-playbook playbooks/06_error_handling_blocks.yml`
Learn: `block/rescue/always`, `failed_when`, `changed_when`, `wait_for`.

## Lab 7 - Ansible Vault
```bash
cp vars/secrets.example.yml vars/secrets.yml
nano vars/secrets.yml                    # set a real password
ansible-vault encrypt vars/secrets.yml   # choose a vault password
cat vars/secrets.yml                     # now unreadable
ansible-playbook playbooks/07_vault_secrets.yml --ask-vault-pass
```
Other commands: `ansible-vault edit|view|rekey vars/secrets.yml`. Verify the DB:
`ssh DB_PRIVATE_IP "sudo -u postgres psql -c '\l'"`.

## Lab 8 - Rolling updates, tags, check mode
```bash
ansible-playbook playbooks/08_rolling_update_tags.yml --check --diff
ansible-playbook playbooks/08_rolling_update_tags.yml --tags packages
ansible-playbook playbooks/08_rolling_update_tags.yml --limit web1
```
`serial: 1` updates one host at a time; `max_fail_percentage: 0` stops the rollout on the first failure.

## Capstone - Roles
```bash
ansible-playbook site.yml -e @vars/secrets.yml --ask-vault-pass
ansible-playbook site.yml -e @vars/secrets.yml --ask-vault-pass   # second run: changed=0
curl http://WEB_PRIVATE_IP
```
`-e @vars/secrets.yml` loads your encrypted password file (Lab 7) so the database user keeps its vault password. Without it the `postgres` role falls back to a lab-only default.
Read `roles/nginx/` to see how the Lab 3 and Lab 5 logic became reusable. Roles use
prefixed variable names (`nginx_port`) so they never collide.

## Useful commands cheat sheet
| Task | Command |
|---|---|
| Syntax check | `ansible-playbook --syntax-check site.yml` |
| Dry run | `--check --diff` |
| One host | `--limit web1` |
| Verbose | `-v`, `-vvv` |
| Start at a task | `--start-at-task "Install nginx"` |
| List tasks | `--list-tasks` |
| Docs for a module | `ansible-doc ansible.builtin.copy` |
| Create a role skeleton | `ansible-galaxy role init myrole` |

## Cleanup (do not skip)
Exit SSH, then on **PC**: `.\scripts\lab-down.ps1`

## Push this project to GitHub (PC)
Create an empty repo named `ansible-aws-lab` on github.com first, then:
```powershell
cd ansible-aws-lab
git init
git add .
git status          # confirm no .pem or secrets.yml is listed
git commit -m "Ansible AWS lab"
git branch -M main
git remote add origin https://github.com/FemiTewo/ansible-aws-lab.git
git push -u origin main
```

## Challenges
1. Add a `redis` role and install it on `db`.
2. Add a UFW firewall task to `common` (allow 22 first or you lock yourself out).
3. Use `with_fileglob` or `loop` to deploy several config files.
4. Turn `site.yml` into one that takes `-e env=prod` and changes the site title.
