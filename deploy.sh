#!/usr/bin/env bash
#
# Deploy this quiz as a FRESH public GitHub repo with GitHub Pages, from YOUR machine.
#
# Requirements on your machine:
#   - git and the GitHub CLI (gh), authenticated:  gh auth status   (if not:  gh auth login)
#   - Run this script from inside this folder (where index.html lives)
#
# Usage:
#   ./deploy.sh                 # repo name defaults to m365-copilot-quiz
#   ./deploy.sh my-repo-name    # use a custom repo name
#
# It creates the repo, pushes the files, enables Pages (main / root),
# writes quiz-links.txt with the real URLs, and prints the live link.
#
set -euo pipefail

REPO="${1:-m365-copilot-quiz}"
OWNER="$(gh api user --jq .login)"
SLUG="${OWNER}/${REPO}"
echo "==> Account: ${OWNER}   Repo: ${REPO}"

# 1. Git init + commit
[ -d .git ] || git init -q
git add -A
git commit -q -m "Microsoft 365 Copilot quiz (static site)" || echo "   (nothing new to commit)"
git branch -M main

# 2. Create the repo if needed, then push
if gh repo view "${SLUG}" >/dev/null 2>&1; then
  echo "==> Repo ${SLUG} already exists; pushing"
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/${SLUG}.git"
  git push -u origin main
else
  echo "==> Creating public repo ${SLUG}"
  gh repo create "${REPO}" --public --source=. --remote=origin --push
fi

# 3. Enable GitHub Pages (branch: main, path: /)
echo "==> Enabling GitHub Pages (main / root)"
if gh api "repos/${SLUG}/pages" >/dev/null 2>&1; then
  gh api -X PUT  "repos/${SLUG}/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 || true
else
  gh api -X POST "repos/${SLUG}/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 \
    || gh api -X POST "repos/${SLUG}/pages" -f build_type=legacy -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 || true
fi

# 4. Resolve the live URL and (re)write quiz-links.txt
BASE="$(gh api "repos/${SLUG}/pages" --jq .html_url 2>/dev/null || echo "https://${OWNER}.github.io/${REPO}/")"
BASE="${BASE%/}/"
{
  echo "Microsoft 365 Copilot Quiz — links for students"
  echo "================================================"
  echo "Public site, no login required for anyone."
  echo ""
  echo "MAIN LINK (all 7 modules / landing page):"
  echo "  ${BASE}"
  echo ""
  echo "DIRECT LINK PER MODULE (opens that quiz straight away):"
  echo "  Module 1 — Copilot Foundations, Work IQ & Choosing the Right Model   ${BASE}?m=1"
  echo "  Module 2 — Copilot Chat & Effective Prompting                        ${BASE}?m=2"
  echo "  Module 3 — Copilot in Outlook & Teams                                ${BASE}?m=3"
  echo "  Module 4 — Copilot in Excel & the Analyst Agent                      ${BASE}?m=4"
  echo "  Module 5 — Copilot in Word & PowerPoint                              ${BASE}?m=5"
  echo "  Module 6 — Agents & Management Dashboards                            ${BASE}?m=6"
  echo "  Module 7 — Responsible AI & Governance                               ${BASE}?m=7"
  echo ""
  echo "Each module has 6 questions (single-choice and multiple-choice). 42 total."
  echo "Content sourced from official Microsoft documentation."
} > quiz-links.txt

echo
echo "======================================================================"
echo " Live (allow ~1 minute for the first Pages build):"
echo "   ${BASE}"
echo " Per-module links written to quiz-links.txt (?m=1 … ?m=7)"
echo "======================================================================"
