# Ansible deployment on Ubuntu 26.04

Use this guide to prepare `ansible-ubuntu` for a linked FO/BO pair and, optionally,
compare it with a manually installed pair on the same server. Manual installation
commands are in the [linked FO/BO guide](INSTALL.ubuntu2604-fo-bo.md); the
[standalone FO guide](INSTALL.ubuntu2604.md) is independent of this setup.

**The current playbook needs the adaptations below before this layout can be
used. The example names are deployment targets, not existing inventory variables.**

## 1. Plan the two pairs

| Application | Domain | Application directory | Database user | Common database | Office database |
|---|---|---|---|---|---|
| Manual BO | `bo-manual.example.com` | `/var/lib/monarc/manual-bo` | `manual_bo` | `manual_common` | `manual_master` |
| Manual FO | `fo-manual.example.com` | `/var/lib/monarc/manual-fo` | `manual_fo` | `manual_common` | `manual_cli` |
| Ansible BO | `bo-ansible.example.com` | `/var/lib/monarc/ansible-bo` | `ansible_bo` | `ansible_common` | `ansible_master` |
| Ansible FO | `fo-ansible.example.com` | `/var/lib/monarc/ansible-fo` | `ansible_fo` | `ansible_common` | `ansible_cli` |

Each pair shares its own common database. The two pairs must not share database
credentials or mutable application directories. Apache serves all four DNS names
on HTTPS port 443; database and statistics listeners remain private.

Prepare the FO and BO artifacts once, following
[artifact preparation](INSTALL.ubuntu2604-fo-bo.md#2-prepare-the-release-artifacts-on-a-build-machine),
and use the exact same archive/checksum for the corresponding office in both
pairs. Keep the deployment source separate from local development source links.

## 2. Keep the fresh-server test reproducible

Take a VM/provider snapshot before preparing the manual pair. Deploying the
Ansible pair afterwards tests coexistence and application deployment, but does
not prove Ansible installs every dependency on a fresh OS. Also run Ansible on
a second clean VM or restore the baseline snapshot after preserving the manual
installation evidence.

Both pairs on one server share its OS and Apache process identity. This is a
deployment comparison, not isolation between untrusted tenants.

## 3. Adapt the existing roles

The checked-in `ansible-ubuntu` roles currently assume one BO, fixed paths and
`monarc_common`/`monarc_master` names. Its FO role also disables enabled Apache
sites outside its client list. Inventory overrides alone cannot provide the
four-site layout safely.

Before running it on this server, adapt and test:

1. The Ubuntu 26.04 signed PHP repository and explicit PHP 8.4 packages.
2. A maintained Ansible/Python combination and explicitly pinned collections;
   replace the repository's old Ansible 4.7 dependency constraint.
3. Per-pair application paths, database names/users, credentials, vhost names,
   logs, writable directories and optional statistics resources from the matrix.
4. Release URLs **and SHA-256 checksums** pointing to the same artifacts used
   manually; do not rely on the old default `v2.14.1` values or “latest”.
5. Download tasks that also run when no HTTP proxy is configured.
6. MariaDB local socket administration, without exposing its bind address or
   assuming `/etc/mysql/debian.cnf` contains usable credentials.
7. Vhost cleanup limited to Ansible-owned sites; it must preserve both manual sites.
8. BO-first database bootstrap/migrations, followed by the matching FO; initial
   seeds and bootstrap imports run only for genuinely new schemas.
9. Secrets in Ansible Vault, protected templates and `no_log` for secret-bearing
   operations. Avoid `--diff` for secret configuration unless explicitly suppressed.
10. Handlers that run `apache2ctl configtest` before reload, plus backup/restore
    and interrupted-upgrade behavior.
11. SSH host-key verification: the current `ansible.cfg` disables it. Verify the
    server fingerprint through a trusted channel, populate the controller's
    `known_hosts`, and enable host-key checking before deployment.

Use one actual inventory host for this one server and model the pair as data;
do not pretend it is four independent machines to work around fixed role names.
Keep host package configuration shared and application resources explicit.

## 4. Deploy and compare

After those changes, the deployment sequence is: connectivity test, syntax check,
check mode where supported, deploy only the Ansible pair, functional validation,
then a second run that makes no unintended changes. Recheck both manual sites
after every Ansible run. A successful second pair on this server still needs the
fresh-OS Ansible test described in section 2.

Once the role adaptations are complete, use your prepared test inventory for
non-mutating checks from the configuration machine. Replace
`../inventory/test-server` with its actual path:

```bash
cd ansible-ubuntu/playbook
export ANSIBLE_HOST_KEY_CHECKING=True
ansible-inventory -i ../inventory/test-server --graph
ansible -i ../inventory/test-server all --user ansible -m ansible.builtin.ping
ansible-playbook -i ../inventory/test-server monarc.yaml --syntax-check
```

Supply your Vault identity/password option if the inventory is encrypted.
Then exercise check mode with the required privilege escalation settings before
applying the deployment to the isolated test pair. Check mode cannot prove that
SQL migrations or first-install initialization will succeed; the real deployment
and a second idempotence run remain required. Keep this inventory separate from
production inventory and omit `--diff` when it could reveal secrets.

The current roles are not certified for this layout by this guide. Adapting them
is a separate implementation step; do not execute the existing full playbook as
if the names in the matrix were already supported variables.

For an optional statistics service, use separate PostgreSQL databases/users,
service accounts, tokens and listeners for the pairs: `127.0.0.1:5005` for manual
and `127.0.0.1:5006` for Ansible. Apply the same pinned service build to both.

See [ansible-ubuntu](https://github.com/monarc-project/ansible-ubuntu) and the
[Ansible support matrix](https://docs.ansible.com/projects/ansible-core/devel/reference_appendices/release_and_maintenance.html)
when selecting the controller, managed-node Python and collection versions.
