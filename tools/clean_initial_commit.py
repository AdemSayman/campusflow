"""Create initial commit without Co-authored-by trailers. Run from repo root."""
import os
import subprocess
import sys
from pathlib import Path

repo = Path(__file__).resolve().parents[1]
git = r"C:\Program Files\Git\cmd\git.exe"
msg_file = repo / ".git" / "COMMITMSG"

os.chdir(repo)

subprocess.check_call([git, "add", "-A"], cwd=repo)

msg_file.write_text(
    "Initial Flutter project scaffold for CampusFlow.\n\n"
    "Include product docs and Firebase-aware gitignore so Adem and Kirwe "
    "can start from a clean greenfield repo.\n",
    encoding="utf-8",
)

env = os.environ.copy()
env.update(
    {
        "GIT_AUTHOR_NAME": "AdemSayman",
        "GIT_AUTHOR_EMAIL": "ademsayman5454@gmail.com",
        "GIT_COMMITTER_NAME": "AdemSayman",
        "GIT_COMMITTER_EMAIL": "ademsayman5454@gmail.com",
    }
)

# Use commit-tree so no prepare-commit-msg / Cursor trailer injection.
tree = subprocess.check_output(
    [git, "write-tree"], cwd=repo, env=env, text=True
).strip()
commit = subprocess.check_output(
    [git, "commit-tree", tree, "-F", str(msg_file)],
    cwd=repo,
    env=env,
    text=True,
).strip()
subprocess.check_call([git, "update-ref", "refs/heads/main", commit], cwd=repo, env=env)
subprocess.check_call([git, "symbolic-ref", "HEAD", "refs/heads/main"], cwd=repo, env=env)

log = subprocess.check_output(
    [git, "log", "-1", "--format=full"], cwd=repo, env=env, text=True
)
print(log)
if "Co-authored-by" in log or "cursoragent" in log.lower():
    print("FAILED: Cursor attribution still present", file=sys.stderr)
    sys.exit(1)
print("OK:", commit)
