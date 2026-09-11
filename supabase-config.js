// ============================================================
// SUPABASE CLIENT SETUP
// Every page loads this file first to connect to your Supabase project.
//
// Fill in YOUR values below. Find them in Supabase:
// Project Settings > API > "Project URL" and "anon public" key.
// The anon key is SAFE to expose in frontend code — that's what it's for.
// (Security is enforced by the Row Level Security rules in schema.sql.)
// ============================================================

const SUPABASE_URL = "https://ioziffmcyttyeevifztd.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlvemlmZm1jeXR0eWVldmlmenRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg4ODIwNTcsImV4cCI6MjEwNDQ1ODA1N30.-Qi3SwJrOxLEuCq9svQnXRo4DkRy9aFW8XjaFTYTiHI";

// Creates one shared client that every page's script can use.
// (supabase-js is loaded from a CDN link in each HTML file's <head>.)
window.supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
// Helper: redirect to login.html if nobody is signed in.
// Call this at the top of every page except login.html.
async function requireLogin() {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) {
    window.location.href = "login.html";
    return null;
  }
  return session.user;
}
