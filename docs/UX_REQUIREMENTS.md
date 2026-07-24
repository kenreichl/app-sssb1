# UX Requirements — Sunny Side Songs: Back to the Garden

## 1. Purpose

A simple children’s book app for mobile and tablet. Users read illustrated spreads and optionally listen to each song with lyric highlighting. UX must stay simple, child-friendly, and never leave the user without a clear next action.

## 2. App Structure (screen order)

1. **Cover** — book cover image
2. **Spreads 1–6** — one full-bleed PNG per spread (left half: decorative art + text block; right half: art only)
3. **End / back-matter** — simple last screen (credits or “The End”) so the user is not stranded after spread 6



## 3. Global Rules

- **Device Orientation:**
  - **Cover** - portrait
  - **Spreads 1-6** - landscape
  - **Back** - portrait
- **Page turning:** manual only (forward and back). No auto-advance when a song ends.
- **Music preference:** global for the whole session. Default = **ON**. Toggle on any spread updates the global preference and is used on all other spreads (forward or back).
- **Music preference persistence within session:** remembered while the app is open and persists across app relaunches.
- **One song at a time:** leaving a spread always stops that spread’s audio before the next screen plays anything.
- **No dead ends:** every screen must have a clear way forward and/or back (except cover, which only goes forward; end screen only goes back or to cover).
- Exit button on all screens



## 4. Cover Screen



### Display

- Front cover fit to device portrait `assets/images/artwork_cover_front.jpg`
- No lyric text block on cover.
- Music playback on cover by default, loops audio file 3 times:`assets/audio/00_cover_front_five_little_green_beens.mp3`
- Music on/off button - global setting



### Actions

- **Enter book:** tap forward control button; cheveron button.
- Cover is the start of the book; there is no “previous page” from cover.



### Exit / stuck prevention

- Cover must always allow entry into Spread 1.
- If cover image fails to load, show a simple fallback (title text + Continue) so the app is not blank/stuck.



### Music control (global state)

- Default at first launch: **On**.
- Toggling updates global music preference immediately.
- Visual state of the button always matches the global preference.



## 5. Spread Screens (1–6)



### Display

- Full-bleed spread artwork PNG.
- Overlay a **scrollable text block** on the left half using normalized coordinates from that spread’s `text_spreadN.md` frontmatter (`text_block: x, y, width, height`).
- Text comes from the markdown body (non-blank lines map to lyric line ids `l1…lN`).
- Stanza blank lines in the text file are preserved as visual spacing.



### Music control (per spread UI, global state)

- Each spread shows a **Music On/Off** control (large, easy to tap).
- Default at first launch: **On**.
- Toggling updates global music preference immediately.
- Visual state of the button always matches the global preference.



### Music On behavior

- When entering a spread with music **On**:
  - Autoplay that spread’s audio from the start.
  - Word-level text highlighting follows the timecode JSON for that spread.
  - Text block **auto-scrolls** so the currently highlighted line stays visible (typically near the middle or upper-middle of the text block).
- When music finishes naturally:
  - Highlighting stops / clears (or leaves last line softly emphasized — pick one and stick to it).
  - Auto-scroll stops.
  - User stays on the same spread (no auto page turn).
  - User can still manually scroll text and turn pages.
  - Music button remains On (preference unchanged). Replaying is optional (see Open Decisions).



### Music Off behavior

- No audio.
- No highlighting.
- Text block is manually scrollable only.
- Entering a spread with music Off does **not** start audio.



### Turning music Off while playing

- Stop audio immediately.
- Clear highlighting.
- Stop auto-scroll.
- Leave current scroll position as-is (do not jump to top).
- Preference becomes Off for the rest of the session (until toggled On again).



### Turning music On while on a spread

- Start that spread’s audio from the beginning (simple rule; avoids resume complexity).
- Resume highlighting + auto-scroll from the start of the song.



### Page turning while music is playing

- Stop current audio immediately.
- Clear highlighting on the page being left.
- Navigate to the new page.
- If global music is On on the new spread: autoplay new spread’s song from start.
- If global music is Off: show text only, no audio.



### Navigation

- Manual forward / back only with chevron buttons.
- Spread 1: Back returns to front Cover.
- Spread 6: Forward goes to back cover.
- Disable or hide the impossible direction so users can’t “press forever” with no effect and wonder if the app is frozen.
- Page-turn controls must remain usable even while audio is playing or text is scrolling.



### Text block interaction

- Always scrollable (finger scroll).
- When music is On and auto-scrolling:
  - If the user manually scrolls, temporarily pause auto-scroll for a short grace period 2 seconds), then resume following the active lyric



## 6. End Screen



### Display

- Back cover fit to device portrait `assets/images/artwork_cover_back.jpg`
- Text scroll box
- Soft return path to cover.



### Actions

- Back → Spread 6
- “Back to Cover” button
- No forward navigation beyond this screen



## 7. Audio Lifecycle Rules (critical for hangups)


| Event                                                   | Required behavior                                               |
| ------------------------------------------------------- | --------------------------------------------------------------- |
| Leave spread                                            | Stop that spread’s audio                                        |
| Enter spread (music On)                                 | Play that spread’s track from 0:00                              |
| Enter spread (music Off)                                | No audio                                                        |
| Song ends                                               | Stay on spread; stop highlighting/auto-scroll                   |
| App backgrounded / interrupted (call, headphone unplug) | Stop audio; do not leave UI in a half-playing highlighted state |
| Audio file missing / fails                              | Silent fallback; keep reading/navigation working                |
| Rapid page flips                                        | Cancel previous audio start; never overlap two songs            |




## 8. Visual / Interaction Simplicity

- Large tap targets for music and page controls.
- Minimal chrome: cover art, spread art, text block, music toggle, page controls.
- No complex menus in v1.
- Landscape is the primary orientation for spreads (book layout). If portrait is allowed
- Phone and tablet: same UX; layout scales; text block uses normalized coordinates.



## 9. States That Must Never Trap the User

1. **Cover with no tap target** → always have Open/forward.
2. **Music On but audio fails** → reading still works; toggle still works; no infinite spinner.
3. **Highlight waiting forever** → if no active word/line, show plain text; never block UI.
4. **Auto-scroll fighting user forever with no way to turn pages** → page controls always available outside text block.
5. **Overlapping songs after fast flips** → single audio owner; previous always cancelled.
6. **Loading forever** → soft timeouts; fallback UI; navigation still possible.



## 10. Data Inputs (for implementers)

Per spread `N` (1–6):

- Artwork: `assets/images/artwork_spreadN.png`
- Text + layout: `assets/data/text_spreadN.md` (YAML frontmatter + lyric body)
- Timecode: `assets/data/timecode_spreadN.json` (hybrid line/word timings; line ids `l1…` map to non-blank text lines)
- Audio: path from frontmatter (e.g. `01_henrietta.mp3` in `assets/audio/`)

Cover:

- Cover image asset `assets/images/artwork_cover_front.jpg`
- Audio: `assets/audio/00_cover_front_five_little_green_beans.mp3`

Back cover:

- Back cover image asset `assets/images/artwork_cover_back.jpg`
- Obi Kanda Medicinals logo `assets/images/logo_cover_back.png`
- Book description text `assets/data/text_cover_back.md` that consists of:
  - Author bio for Ngonda Badila
  - Illustrator bio for Ntangou Badila
  - Book information
- Photo of book author Ngonda Badila at `assets/images/photo_bio_ng.jpg`
- Photo of book illustrator Ntangou Badila at `assets/images/photo_bio_nt.jpg`



## 11. Acceptance Criteria (UX)

- Open app → see cover.
- From cover → can reach Spread 1.
- Can move forward/back through all spreads without getting stuck.
- Music defaults On; cover audio plays automatically.
- While in the cover or back cover, turning music Off stops audio
- While in any spread:
  - With music On, turning music Off stops audio + highlighting; later spreads stay silent until turned On.
  - With music Off, turning music on starts audio and lyric highlighting from the beginning
  - After songs ends, replay button appears, stay silent until replay button pressed or page turn to next spread
- Turning music On later starts the current spread’s song and stays On when navigating.
- While in any spread:
  - With music On, lyrics highlight in sync and text block keeps the active line visible.
  - With music Off, lyrics are readable and manually scrollable with no highlight.
  - Song end does not force a page turn.
- Leaving a spread always stops its song.
- While in the cover, after song loop count ends stay silent
- While in the back cover, after song ends stay silent
- App remains usable if audio or a single image fails.
- Remeber music preference across app relaunches.
- Start book from beginning across app relaunches

---



## Notes: Gaps This Spec Closes

The biggest hangup risks were not the happy path, but edges:

- how to leave the cover
- what happens after the last spread
- stopping audio on page change
- song-end behavior (no auto page turn)
- music toggle mid-play
- audio failure / interruption
- page-turn vs text-scroll gesture conflict
- disabled nav at first/last page so nothing feels frozen

