---
capture_type: LEARNING
timestamp: 2026-02-06 13:16:45 GMT+7
auto_captured: true
tags: [auto-capture]
---

# Quick Learning: Task Completion

**Date:** 2026-02-06
**Auto-captured:** Yes

---

## Summary

N/A

## Analysis

N/A

## Actions Taken

N/A

## Results

N/A

## Current Status

N/A

## Next Steps

N/A

---

<details>
<summary>Full Response</summary>

━━━ **📚 LEARN** ━━━ 7/7

**What worked:**
- FirstPrinciples analysis revealed the database vs. file-centric difference
- Found Calibre's "Save to disk" feature for clean export
- Discovered YACReader Library auto-imports from folder structure

**Key insight:** Migration is simple because YACReader doesn't care about past organization - just point it at a folder and it imports everything.

**Metadata reality check:** Calibre metadata WON'T transfer (stored in database, not in CBR files), but YACReader can fetch fresh metadata from ComicVine automatically.

---

## 🗣️ PAI: Here's your complete migration guide from Calibre to YACReader Library

### **Phase 1: Preparation & Backup** (Safety First!)

**Step 1: Find your Calibre library location**
1. Open Calibre
2. Click any book
3. Look at the right panel → Click "Click to open" next to "Path"
4. This shows where Calibre stores your files

**OR** use Calibre's library switcher:
- Click "Library" button → "Switch/create library"
- Note the current library path

**Typical location on Mac:** `/Users/[yourname]/Calibre Library/`

**Step 2: Backup your Calibre library (CRITICAL)**
```bash
# Copy entire Calibre library folder to backup location
cp -r ~/Calibre\ Library ~/Desktop/Calibre_Backup_$(date +%Y%m%d)
```

This protects you if anything goes wrong.

---

### **Phase 2: Export Comics from Calibre**

You have **two options**:

#### **Option A: Calibre "Save to disk" (Recommended - Clean Export)**

1. Open Calibre
2. Select ALL comics (Cmd+A)
3. Right-click → "Save to disk"
4. Choose a new destination folder: `/Users/[yourname]/Comics/`
5. Configure output:
   - Template: `{authors}/{title}/{title} - {series_index}` 
   - OR simpler: `{title}/{title}`
6. Click "Save to disk"
7. Calibre exports all comics to the new location

**Result:** Clean folder structure based on metadata

#### **Option B: Direct Copy (Faster but messier structure)**

1. Find Calibre library location (from Phase 1)
2. Copy all comic files directly:
```bash
# Create new Comics folder
mkdir -p ~/Comics

# Copy everything from Calibre
cp -r ~/Calibre\ Library/* ~/Comics/
```

**Result:** Keeps Calibre's structure (may be messy)

---

### **Phase 3: Organize for YACReader (Optional but Recommended)**

YACReader works best with organized folders. **Recommended structure:**

```
Comics/
├── DC/
│   ├── Batman/
│   │   ├── Batman #001.cbr
│   │   ├── Batman #002.cbr
│   └── Superman/
├── Marvel/
│   ├── Spider-Man/
│   └── X-Men/
└── Independent/
    └── Strange Sports Stories/
        ├── Strange Sports Stories #001.cbr
        ├── Strange Sports Stories #002.cbr
        └── Strange Sports Stories #003.cbr
```

**You can:**
- Organize manually (drag and drop in Finder)
- Leave as-is and let YACReader import everything
- Organize gradually over time (YACReader updates when you add folders)

**Pro tip:** YACReader doesn't require perfect organization - it just makes browsing easier.

---

### **Phase 4: Create YACReader Library**

**Step 1: Install YACReader Library**
- If you installed YACReader earlier, you already have it
- It's the second app that comes with YACReader
- Look for "YACReaderLibrary" in your Applications folder

**Step 2: Create your library**
1. Open **YACReaderLibrary** (not YACReader)
2. Click "Create Library" or File → "Create Library"
3. Give it a name: "My Comics"
4. Choose location: Point it to `/Users/[yourname]/Comics/`
5. Click "Create"

**Step 3: Let it import**
- YACReader scans the folder and imports all comics
- This may take a few minutes depending on collection size
- You'll see comics appear in the library

**Step 4: Update library when needed**
- If you add more comics later, press **'U'** to update
- YACReader finds new comics automatically

---

### **Phase 5: Fetch Metadata (Restore Organization)**

**Good news:** You don't need to manually re-enter metadata!

**Step 1: Connect to ComicVine**
1. Get a free ComicVine API key: [ComicVine.com](https://comicvine.gamespot.com/api/)
2. In YACReaderLibrary: Preferences → "ComicVine"
3. Enter your API key

**Step 2: Auto-fetch metadata**
1. Select comics (or select all)
2. Right-click → "Get info from Comic Vine"
3. YACReader matches based on file names
4. Review matches, click "OK"
5. Metadata downloads automatically

**What you get:**
- Cover images
- Series information
- Issue numbers
- Writer/Artist credits
- Publication dates

---

### **Phase 6: Test Before Deleting Calibre**

**IMPORTANT: Don't delete Calibre library yet!**

**Test checklist:**
- ✅ All comics imported to YACReader Library?
- ✅ Can you read comics with YACReader?
- ✅ Folder organization makes sense?
- ✅ Metadata looks good (if you fetched from ComicVine)?

**Use both systems for a week:**
- Keep Calibre as backup
- Use YACReader as primary reader
- Make sure you're happy with the migration

**After you're confident:**
```bash
# Optional: Delete Calibre library (ONLY after thorough testing)
rm -rf ~/Calibre\ Library
```

**Keep the backup** on your Desktop for another month just in case.

---

### **Phase 7: iPad Sync (Bonus)**

**If you want comics on iPad:**

**Option 1: YACReader iOS app**
1. Install [YACReader iOS](https://apps.apple.com/app/yacreader-comic-reader/id635717885)
2. Import comics via:
   - iTunes File Sharing
   - Cloud services (Dropbox, Google Drive)
   - YACReader Library Server (advanced)

**Option 2: Stick with Chunky**
1. Keep Chunky on iPad (it's better anyway)
2. Use Files app to sync comics to iPad
3. Import to Chunky from Files

---

### **Quick Reference Summary**

**Migration in 5 steps:**
1. ✅ **Backup Calibre library** → Copy entire folder to Desktop
2. ✅ **Export comics** → Use "Save to disk" to new `/Comics/` folder
3. ✅ **Create YACReader Library** → Point at `/Comics/` folder
4. ✅ **Fetch metadata** → Use ComicVine integration
5. ✅ **Test thoroughly** → Use both systems for a week before deleting Calibre

**Time estimate:**
- Small library (< 100 comics): 30 minutes
- Medium library (100-500): 1-2 hours
- Large library (500+): 2-4 hours (mostly waiting for imports)

---

### **Metadata Reality Check**

**What you'll lose:**
- Custom Calibre tags
- Custom Calibre metadata fields
- Reading progress from Calibre

**What you'll gain:**
- ComicVine metadata (often better than manual entry)
- Cover images
- Series grouping
- Reading lists in YACReader

**Bottom line:** If you weren't using Calibre's advanced features heavily, you won't miss much.

---

### **Troubleshooting**

**Problem: YACReader not seeing some comics**
- Check file format (CBR, CBZ supported; RAR files need unrar installed)
- Press 'U' to update library
- Check file permissions

**Problem: Comics in weird order**
- YACReader sorts by filename
- Rename files with leading zeros: `#001`, `#002`, not `#1`, `#2`

**Problem: No metadata from ComicVine**
- Check API key is entered correctly
- Make sure filenames include series name and issue number
- ComicVine has rate limits - wait between batches

---

**Sources:**
- [Calibre "Save to disk" documentation](https://manual.calibre-ebook.com/faq.html)
- [How to Find Calibre Library Location](https://www.epubor.com/calibre-library-location.html)
- [YACReader Library Best Practices - Forum](https://www.yacreader.com/forum/support-windows/143-yacreader-library-best-practice)
- [How do you organize your library? - YACReader Forum](https://www.yacreader.com/forum/questions-to-the-users/2604-how-do-you-organize-your-library)
- [EmbedComicMetadata Plugin](https://github.com/dickloraine/EmbedComicMetadata)
- [YACReader Support](https://www.yacreader.com/support)

Let me know when you're ready to start, and I can walk you through each phase step-by-step!

</details>
