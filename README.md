# Movie Tracker

A minimal, responsive movie library that works as a static website. It keeps the current 644-item seed list, imports the screenshot watchlist, and saves edits in this browser. When Supabase is configured, email sign-in enables cloud storage across devices.

## Run the site

Open \`index.html\` or publish the folder with GitHub Pages. There is no build step. The Supabase client loads from jsDelivr only after cloud settings are filled in; without them, the site stays in device-only mode.

## Turn on cross-device sync

1. Create a Supabase project.
2. In that project's SQL Editor, run [supabase-schema.sql](./supabase-schema.sql).
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

- Older blank or unknown statuses migrate to **Plan to watch**. New movies also default to **Plan to watch**.
- The screenshot list adds 100 distinct titles to the **Next 3 months** collection. A title that already exists is not duplicated, and its current status is preserved; new entries are added as Plan to watch.
- Updates are saved in browser storage immediately, then synced when signed in and online. Returning to the page or switching back to it refreshes cloud data. Conflicts use the most recent update time.
- Removing a movie creates a hidden tombstone so another device does not restore it during sync.
- Import and export use CSV. The export includes stable IDs and the Next 3 months flag for easier backup and restore.

