# Break / Fix Scenarios
Break it on purpose, read the error, fix it. This is how troubleshooting skill is built.

| # | Break it | Symptom | Fix |
|---|---|---|---|
| 1 | Wrong `private_key_file` or `chmod 644 ~/.ssh/lab.pem` | `UNREACHABLE ... Permission denied (publickey)` / bad permissions | `chmod 600 ~/.ssh/lab.pem`, confirm path in `ansible.cfg` |
| 2 | Change `remote_user` to `ec2-user` | `Permission denied (publickey)` | Ubuntu AMIs use `ubuntu` |
| 3 | Typo a host IP in `hosts.ini` | `UNREACHABLE ... timed out` | Fix IP; test with `ansible all -m ping` |
| 4 | Remove `become: true` from an apt task | `Permission denied` / `are you root?` | Add `become: true` |
| 5 | Bad YAML indent | `ERROR! We were unable to read ... as YAML` | `yamllint .` and `--syntax-check` |
| 6 | Misspell a module (`ansible.builtin.aptt`) | `couldn't resolve module/action` | Fix name; `ansible-doc -l` |
| 7 | Use a variable that is not defined | `'x' is undefined` | Define in vars/group_vars or use `default()` |
| 8 | Break nginx config in the template (remove a `;`) | `nginx -t` task fails, site stays on the old config | Fix template; validation protects production |
| 9 | Run Lab 7 without creating `vars/secrets.yml` | `Could not find or access vars/secrets.yml` | Follow Lab 7 steps |
| 10 | Forget `--ask-vault-pass` | `Attempting to decrypt but no vault secrets found` | Add the flag or `--vault-password-file` |
| 11 | Security group blocks port 80 | `curl` from your PC hangs | Reopen port 80 in `lab.yaml` and update the stack |
| 12 | Stop sshd on a managed host | `UNREACHABLE` for that host only | Use EC2 console / recreate; always keep a way back |

Debug toolbox: `-vvv`, `ansible-inventory --list`, `ansible HOST -m setup`, `ssh -vvv`, `--step`, `--start-at-task`.
