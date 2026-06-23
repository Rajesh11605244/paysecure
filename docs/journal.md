# PaySecure Build Journal

A running log of what broke during this build and how it was fixed. This is
deliberately kept honest and specific — vague entries like "fixed a bug" are
useless in an interview. Good entries name the exact error and the exact fix.

---

## Week 1

### Issue: `kind` command not found
**Symptom:** `command 'kind' not found` when trying to create the cluster.
**Cause:** `kind` isn't in Ubuntu's apt repos — it has to be downloaded
directly from the GitHub release binary.
**Fix:** Downloaded the binary with `curl`, made it executable with
`chmod +x`, moved it to `/usr/local/bin`.

### Issue: `cluster-config.yaml: No such file or directory`
**Symptom:** `kind create cluster` failed saying the config file didn't exist,
even after I thought I'd created it.
**Cause:** I was already `cd`-ed into `infra/kind/`, then referenced the path
`infra/kind/cluster-config.yaml` again on top of that — Git/shell looked for
a doubly-nested path that didn't exist.
**Fix:** Ran `pwd` to confirm location, `cd`-ed back to the repo root, then
re-ran the file creation with the path relative to root.
**Lesson:** Always run `pwd` before any file-creation command when the
folder structure has more than one level.

### Issue: Docker daemon not running
**Symptom:** `Cannot connect to the Docker daemon at
unix:///home/rajesh/.docker/desktop/docker.sock`
**Cause:** Docker Desktop was installed but not actually launched.
**Fix:** Started Docker Desktop, waited ~30s for the daemon to come up,
verified with `docker ps` before retrying `kind create cluster`.

---

## Week 2

### Issue: Docker build failed — "no such file or directory" for Dockerfile
**Symptom:** `failed to read dockerfile: open .../Dockerfile: no such file
or directory`, followed by a failed `docker run` ("pull access denied").
**Cause:** The Dockerfile hadn't actually been created in the service
folder yet — the build never had anything to read.
**Fix:** Verified with `ls -la` that no `Dockerfile` existed, created it,
re-ran `docker build`.
**Lesson:** A failed build silently means a failed run downstream — always
check the build step succeeded before troubleshooting the run step.

### Issue: `git push` — "src refspec main does not match any"
**Symptom:** Push rejected, local `main` branch not recognized.
**Cause:** No commit had been made yet, so no branch existed locally.
**Fix:** Ran `git add .` and `git commit` first, confirmed with
`git branch` that `main` now existed, then pushed.

### Issue: GitHub authentication failed (password auth)
**Symptom:** `Invalid username or token. Password authentication is not
supported for Git operations.`
**Cause:** GitHub deprecated password auth for git operations in 2021.
**Fix:** Generated a Personal Access Token (Settings > Developer settings >
Personal access tokens), used it as the password when prompted, then ran
`git config --global credential.helper store` so it's cached going forward.

### Issue: Push rejected — divergent histories
**Symptom:** `! [rejected] main -> main (fetch first)`, then later
`fatal: Need to specify how to reconcile divergent branches.`
**Cause:** GitHub auto-created an "Initial commit" (README) when the repo
was created, giving the remote a commit history unrelated to my local repo.
**Fix:** `git pull origin main --no-rebase --allow-unrelated-histories`,
resolved the merge commit message, confirmed `git status` was clean, then
pushed successfully.
**Lesson:** Leave "Add a README" unchecked when creating an empty GitHub
repo for a project that already has local commits — avoids this entirely.

### Issue: ArgoCD "Cluster URL is required"
**Symptom:** New Application form wouldn't submit, citing a required but
empty Cluster URL field.
**Cause:** Didn't realize ArgoCD needs an explicit (if fixed/internal) URL
even when deploying to the same cluster it runs on.
**Fix:** Used the standard internal address `https://kubernetes.default.svc`,
which always refers to "the cluster ArgoCD is currently running inside."
*
