# Microsoft 365 Copilot Quiz

A short, self-contained quiz that checks understanding of **Microsoft 365 Copilot** features,
organized to match the 7 teaching modules of the *M365 Copilot for Finance, Audit & GRC*
course. The questions are about **how each Copilot feature works** (not finance/audit
scenarios), so they stay useful for any learner.

Pure static HTML, CSS, and vanilla JavaScript — no build step, no framework, no server. It runs
directly from GitHub Pages. All content is sourced from **official Microsoft documentation**
(learn.microsoft.com and support.microsoft.com), and every question links back to its source.

## Live site

After you deploy (see **Deploy** below), the site is at `https://<OWNER>.github.io/<REPO>/`:

- **All quizzes:** `https://<OWNER>.github.io/<REPO>/`
- **A single module directly:** add `?m=<number>`, e.g. `…/?m=4` opens the Excel & Analyst
  agent quiz. See `quiz-links.txt` for the full list (the deploy script fills in your real URL).

## Deploy (fresh GitHub repo + Pages)

On your machine, with the GitHub CLI authenticated (`gh auth status`), from inside this folder:

```bash
./deploy.sh                 # creates repo "m365-copilot-quiz"
# or:  ./deploy.sh my-name  # choose the repo name
```

It creates a public repo, pushes the files, enables Pages (main / root), writes `quiz-links.txt`
with your real URLs, and prints the live link. (Prefer the UI? Create a public repo, push these
files to `main`, then Settings → Pages → Source: Deploy from a branch → `main` / `/root`.)

No sign-in is required for anyone. The name a learner types is kept in a JavaScript variable for
the quiz only; it is never stored, cookied, or sent anywhere.

## The 7 modules

1. Copilot Foundations, Work IQ & Choosing the Right Model
2. Copilot Chat & Effective Prompting
3. Copilot in Outlook & Teams
4. Copilot in Excel & the Analyst Agent
5. Copilot in Word & PowerPoint (Create, Brand Kit)
6. Agents & Management Dashboards (Agent Builder)
7. Responsible AI & Governance

Each module has 6 questions (42 total): single-choice and multiple-choice ("Select all that
apply").

## Project layout

```
index.html            The whole UI (landing, name entry, quiz, result screens)
style.css             All styling (light theme, responsive, reduced-motion aware)
app.js                All logic (routing, grading, result, image export)
quiz-links.txt        The main link plus a direct link for each module
data/
  modules.json        The manifest: the modules shown on the landing page
  module1.json …      One file per module, holding that module's questions
  module7.json
```

The only external dependency is **html2canvas** (via CDN), used to render the result card as a
downloadable PNG.

## Editing questions (no JavaScript required)

Edit the JSON in `data/`. Each question looks like:

```json
{
  "id": "m1q1",
  "type": "single",
  "question": "…",
  "options": ["…", "…", "…", "…"],
  "correct": [0],
  "explanation": "Why the right answer is right.",
  "source": "https://learn.microsoft.com/…"
}
```

- `type` is `single` (one correct answer) or `multi` (two or more; shown as "Select all that
  apply"). `correct` is an array of **zero-based** option indices.
- To add a module, create `data/module8.json` and add one entry to `modules` in
  `data/modules.json` — no code changes.

## Running locally

```bash
python3 -m http.server 8098
# then open http://localhost:8098/
```

> Practice quiz for learning. Not affiliated with or endorsed by Microsoft; uses no Microsoft
> logos or trademarked assets.
