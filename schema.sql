-- ============================================================
-- FRIENDSHIP BRACELET APP — DATABASE SCHEMA
-- Run this whole file in Supabase: Project > SQL Editor > New Query > Run
-- ============================================================

-- ---------- PROFILES ----------
-- One row per user, linked to Supabase's built-in auth.users table.
-- We can't add columns directly to auth.users, so we make our own
-- "profiles" table that mirrors it.
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  avatar_url text,
  created_at timestamp with time zone default now()
);

-- When someone signs up, automatically create their profile row.
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username)
  values (new.id, new.raw_user_meta_data->>'username');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------- TUTORIALS ----------
-- A shared library of bracelet tutorials. Any logged-in user can add one.
create table tutorials (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  difficulty text check (difficulty in ('easy', 'medium', 'hard')),
  image_url text,
  link text, -- optional: URL to a video or pattern guide
  created_by uuid references profiles(id),
  created_at timestamp with time zone default now()
);

-- ---------- USER TUTORIAL STATUS ----------
-- Tracks each user's personal relationship to each tutorial:
-- not_started / in_progress / completed, plus rating + comment
-- (rating and comment only make sense once completed).
create table tutorial_status (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade not null,
  tutorial_id uuid references tutorials(id) on delete cascade not null,
  status text check (status in ('not_started', 'in_progress', 'completed')) default 'not_started',
  rating int check (rating between 1 and 5),
  comment text,
  updated_at timestamp with time zone default now(),
  unique (user_id, tutorial_id) -- one status row per user per tutorial
);

-- ---------- BRACELETS (photos users made) ----------
create table bracelets (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade not null,
  photo_url text not null,
  caption text,
  tutorial_id uuid references tutorials(id), -- optional link back to the tutorial used
  created_at timestamp with time zone default now()
);

-- ---------- FRIENDSHIPS ----------
-- One row per friend request. status: pending -> accepted.
-- user_id = who sent the request, friend_id = who received it.
create table friendships (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade not null,
  friend_id uuid references profiles(id) on delete cascade not null,
  status text check (status in ('pending', 'accepted')) default 'pending',
  created_at timestamp with time zone default now(),
  unique (user_id, friend_id)
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- This is what keeps users from reading/editing each other's private data.
-- Without this, anyone with your public API key could read everything.
-- ============================================================

alter table profiles enable row level security;
alter table tutorials enable row level security;
alter table tutorial_status enable row level security;
alter table bracelets enable row level security;
alter table friendships enable row level security;

-- Profiles: everyone can view profiles (needed to find friends),
-- but you can only edit your own.
create policy "Profiles are viewable by everyone" on profiles
  for select using (true);
create policy "Users can update own profile" on profiles
  for update using (auth.uid() = id);

-- Tutorials: everyone can view; any logged-in user can add one.
create policy "Tutorials are viewable by everyone" on tutorials
  for select using (true);
create policy "Logged-in users can add tutorials" on tutorials
  for insert with check (auth.uid() = created_by);

-- Tutorial status: users can only see/edit their OWN status rows.
create policy "Users can view own tutorial status" on tutorial_status
  for select using (auth.uid() = user_id);
create policy "Users can insert own tutorial status" on tutorial_status
  for insert with check (auth.uid() = user_id);
create policy "Users can update own tutorial status" on tutorial_status
  for update using (auth.uid() = user_id);

-- Bracelets: everyone can view (so friends can see your photos),
-- but only you can add/edit your own.
create policy "Bracelets are viewable by everyone" on bracelets
  for select using (true);
create policy "Users can insert own bracelets" on bracelets
  for insert with check (auth.uid() = user_id);
create policy "Users can delete own bracelets" on bracelets
  for delete using (auth.uid() = user_id);

-- Friendships: you can see a request if you sent it or received it.
create policy "Users can view own friendships" on friendships
  for select using (auth.uid() = user_id or auth.uid() = friend_id);
create policy "Users can send friend requests" on friendships
  for insert with check (auth.uid() = user_id);
create policy "Users can respond to requests sent to them" on friendships
  for update using (auth.uid() = friend_id);

-- ============================================================
-- STORAGE (for bracelet photos)
-- Run this too — it creates a public bucket called "bracelet-photos".
-- ============================================================
insert into storage.buckets (id, name, public) values ('bracelet-photos', 'bracelet-photos', true);

create policy "Anyone can view bracelet photos" on storage.objects
  for select using (bucket_id = 'bracelet-photos');
create policy "Logged-in users can upload bracelet photos" on storage.objects
  for insert with check (bucket_id = 'bracelet-photos' and auth.role() = 'authenticated');
