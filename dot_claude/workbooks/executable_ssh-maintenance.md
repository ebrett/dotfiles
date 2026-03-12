# SSH & Git Config Maintenance Workbook

Use this when auditing or cleaning up SSH keys and git signing config — e.g. when retiring a service, offboarding a tool, or doing periodic hygiene.

## Tools needed
- `ssh-keygen` — remove known_hosts entries
- `chezmoi` — sync config changes back to dotfiles repo
- `curl https://ipinfo.io/<ip>` — identify unknown IPs
- `git config --list --show-origin` — audit git config sources
- `gpg --list-secret-keys` — verify GPG signing keys

---

## 1. Audit git signing config

```
git config --list --show-origin | grep -i "sign\|gpg\|format"
```

Check for:
- `gpg.ssh.program` pointing to 1Password or other removed tools → remove `[gpg "ssh"]` block if `gpg.format` is not `ssh`
- `user.signingkey` — confirm the key exists (`gpg --list-secret-keys`)
- `commit.gpgsign = true` — signing is active

Edit: `~/.local/share/chezmoi/private_dot_gitconfig`
Apply: `chezmoi apply ~/.gitconfig`

---

## 2. Audit SSH config

```
cat ~/.ssh/config
```

Check for:
- `IdentityAgent` pointing to removed tools (e.g. 1Password socket)
- `IdentityFile` entries referencing keys that no longer exist
- `Host` blocks for servers no longer in use

Edit: `~/.ssh/config` directly (it's age-encrypted in chezmoi)
Sync: `chezmoi re-add ~/.ssh/config` (re-encrypts and commits)

---

## 3. Audit SSH keys

```
ls ~/.ssh/*.pub
```

For each key beyond `id_ed25519`, ask:
- Is it referenced in `~/.ssh/config`?
- Is it referenced in any active project (`grep -r <keyname> ~/Code ~/Projects`)?
- When was it created (`ls -la ~/.ssh/<key>`)?

If stale: `rm ~/.ssh/<key> ~/.ssh/<key>.pub`
Then remove its `Host` block from `~/.ssh/config` and run `chezmoi re-add ~/.ssh/config`.

---

## 4. Audit known_hosts

```
cat ~/.ssh/known_hosts | awk '{print $1}' | sort -u
```

For unknown IPs: `curl -s https://ipinfo.io/<ip>` to identify.
Remove stale entries: `ssh-keygen -R <host>`

---

## 5. Test everything works

```
ssh -T git@github.com                          # GitHub auth
echo "test" | gpg --clearsign                  # GPG signing
git commit --allow-empty -m "test" && git log --show-signature -1  # end-to-end
```

---

## Deployment key lifecycle

**When starting a project with a remote server:**
1. `ssh-keygen -t ed25519 -f ~/.ssh/<project>_deploy -C "<project>-deploy"`
2. Add `Host` block to `~/.ssh/config`
3. `chezmoi re-add ~/.ssh/config`
4. Register public key on the server

**When ending the project:**
1. Revoke the key from the server
2. `rm ~/.ssh/<project>_deploy ~/.ssh/<project>_deploy.pub`
3. Remove the `Host` block from `~/.ssh/config`
4. `chezmoi re-add ~/.ssh/config`
5. `ssh-keygen -R <host>`
