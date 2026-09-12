# Bracelet Buddies — Setup Guide

A website where users log in, save/rate friendship bracelet tutorials,
post photos of bracelets they've made, and add friends.

**Stack:** plain HTML/CSS/JS (no build tools needed) + Supabase (auth, database, photo storage) + GitHub Pages (free hosting).

Files:
- `schema.sql` — run once in Supabase to create your database
- `supabase-config.js` — your connection keys (shared by every page)
- `style.css` — shared styling
- `index.html` — sign up / log in
- `dashboard.html` — home feed of friends' recent bracelets
- `tutorials.html` — browse/add tutorials, track status, rate & comment
- `my-bracelets.html` — upload & view your bracelet photos
- `friends.html` — search users, send/accept friend requests

---

## Step 1: Create your Supabase project

1. Go to [supabase.com](https://supabase.com) and sign up (free tier is plenty).
2. Click **New Project**. Pick a name and a database password (save this password somewhere).
3. Wait ~2 minutes for it to finish setting up.

## Step 2: Set up the database

1. In your Supabase project, click **SQL Editor** in the left sidebar.
2. Click **New Query**.
3. Open `schema.sql` from this project, copy the whole thing, paste it in, and click **Run**.
4. Check **Table Editor** in the sidebar — you should see `profiles`, `tutorials`, `tutorial_status`, `bracelets`, and `friendships`.
5. Check **Storage** in the sidebar — you should see a `bracelet-photos` bucket.

## Step 3: Connect your code to Supabase

1. In Supabase, go to **Project Settings** (gear icon) > **API**.
2. Copy the **Project URL** and the **anon public** key.
3. Open `supabase-config.js` in VS Code and paste them in:
   ```js
   const SUPABASE_URL = "https://your-actual-project-id.supabase.co";
   const SUPABASE_ANON_KEY = "your-actual-anon-key";
   ```
4. By default, Supabase requires email confirmation before login works. For easier testing, go to **Authentication > Providers > Email** and toggle **off** "Confirm email" (you can turn it back on later for production).

## Step 4: Run it locally in VS Code

1. Open the `bracelet-app` folder in VS Code.
2. Install the **Live Server** extension (search it in the Extensions panel).
3. Right-click `index.html` and choose **Open with Live Server**.
4. Your browser opens the site. Sign up with an email/password, then explore.

You now have a fully working app running on your computer.

## Step 5: Push to GitHub

1. In VS Code, open the built-in terminal (**Terminal > New Terminal**).
2. Run:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Bracelet Buddies"
   ```
3. Create a new empty repository on [github.com](https://github.com/new) (don't check "add README" — you already have one).
4. GitHub will show you commands like these — run them in your terminal:
   ```bash
   git remote add origin https://github.com/YOUR-USERNAME/bracelet-app.git
   git branch -M main
   git push -u origin main
   ```

## Step 6: Deploy for free with GitHub Pages

1. On your repo's GitHub page, click **Settings > Pages**.
2. Under **Source**, choose **Deploy from a branch**, branch = `main`, folder = `/ (root)`. Save.
3. Wait a minute, then your site will be live at:
   `https://YOUR-USERNAME.github.io/bracelet-app/login.html`
4. Share that link with friends so they can sign up too.

---

## How the status/rating system works

Each user has their own private row per tutorial in `tutorial_status`
(not_started / in_progress / completed). Changing the dropdown on the
Tutorials page saves instantly. Once a tutorial is marked **completed**,
a rating (1–5 for ease) and comment box appear and save separately.
Nobody else can see or edit your status rows — that's enforced by the
Row Level Security policies in `schema.sql`, not just the app code.

## Ideas for what to build next

- Show the average ease rating + everyone's comments on each tutorial (currently ratings are private to each user — you'd query all `tutorial_status` rows for a tutorial and show community averages).
- Let users comment on each other's bracelet photos.
- Add an avatar upload on a profile page (the `avatar_url` column is already in the schema, unused).
- Add push/email notifications for friend requests.

## Troubleshooting

- **"row-level security policy" error when inserting** — make sure you ran the *entire* `schema.sql`, including the `create policy` lines at the bottom.
- **Blank page / console errors about `supabase is not defined`** — check that `supabase-config.js` is loaded *after* the Supabase CDN `<script>` tag in the HTML `<head>`, and that you filled in your real URL/key.
- **Photo upload fails** — check that the `bracelet-photos` bucket exists in Supabase Storage and that its policies ran (bottom of `schema.sql`).
