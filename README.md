# Movie Tracker

A minimal, responsive movie library that works as a static website. It keeps the current 644-item seed list and the screenshot watchlist, saves edits in this browser, and can sync across devices through Supabase.

## Sections

- **All movies** — search, filter by status, change status inline, edit details, and rate titles.
- **Next 3 months** — a curated list from the screenshots. Matching titles are not duplicated, and their current statuses are preserved.
- **Top 10 favorites** — star titles from any list, up to ten at a time. Use the arrows beside a favorite to rank it.
- **Highest rated** — every movie with a rating, sorted from highest to lowest. This view shows the full ranked list in one continuous scroll; it is not limited to ten.

Blank or unknown old statuses migrate to **Plan to watch**, and newly added movies default to **Plan to watch**. There is no Unsorted category.

## Run the site

Open \`index.html\` or publish the folder with GitHub Pages. There is no build step. The Supabase client loads from jsDelivr only after cloud settings are filled in; without them, the site stays in device-only mode.

## Turn on cross-device sync

1. Create a Supabase project.
2. In that project's SQL Editor, run [supabase-schema.sql](./supabase-schema.sql). If you already ran the earlier schema, run the updated file again to add favorite ranking.
3. In **Project Settings → API Keys**, copy the Project URL and **publishable** key. Put them in [supabase-config.js](./supabase-config.js):
   \`\`\`js
   window.MOVIE_TRACKER_CONFIG = {
     supabaseUrl: "https://YOUR_PROJECT.supabase.co",
     publishableKey: "sb_publishable_..."
   };
   \`\`\`
4. In Supabase Auth URL Configuration, set the Site URL to the published site address and allow that URL as a redirect.
5. Publish the updated files. Open the updated site on the device that has your current movie list, choose **Sync settings**, and sign in by email. The first sync uploads the list in that browser. On another device, open the same hosted site and use the same email address.

The frontend key is public by design. Do not put a Supabase secret or service-role key in the website; the SQL enables Row Level Security and limits movie rows to their signed-in owner.

## Data behavior

- Updates are saved in browser storage immediately, then synced when signed in and online. Returning to the page or switching back to it refreshes cloud data. Conflicts use the most recent update time.
- Removing a movie creates a hidden tombstone so another device does not restore it during sync.
- CSV export includes stable IDs, the Next 3 months flag, and favorite rank for backup and restore.

