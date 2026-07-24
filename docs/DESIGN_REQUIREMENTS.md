# Design Requirements — Sunny Side Songs: Back to the Garden

A simple children’s book app for mobile and tablet. Users read illustrated spreads and optionally listen to each song with lyric highlighting. UX must stay simple, child-friendly.

This document specifies overall design and style, for complimentary UX requirements see `docs/UX_REQUIREMENTS.md`. Both of the documents are to be used for building a plan to build v1 of the app.

This book app is adapted from a print book and has music with lyrics for each interior spread. Use the current project ~/Programming/sssb/app-sssb1 and remote github repository [https://github.com/kenreichl/app-sssb1](https://github.com/kenreichl/app-sssb1)

## 1. Description



### 1.1 Interface Structure

1. Front cover
2. Interior spreads:
  1. 6 interior spreads numbered 1, 2, 3, 4, 5, 6.
  2. Interior spread or spread is defined as the book open in landscape orientation where the left half has artwork and text (as pages 1, 3, 5, 7, 9, 11), right half has only artwork (as pages 2, 4, 6, 8, 10, 12).
  3. Each spread artwork is a single png file; a single image for left page and right page
3. Back cover



### 1.2 App Functions and Features

For detailed UX requirements, see `docs/UX_REQUIREMENTS.md`

- Music on/off
- Smooth page turning like a book
- Simple text scroll block for interior spreads and back cover
- Text highlighting and autoscrolling when music is on
- Exit button - exits the app - returns to the OS home / backgrounds the app (Android `moveTaskToBack`; iOS system initiates programmatic kill).
- No status bar or hide status bar for v1 build



## 2. Overall Design Principles

- Design for best performance
- Design for backwards compatibility with older iOS and android devices (iOS 12+, Android API 26+)
- Design for least number of failure modes, or failure points, and operatures with no maintenance
- App is updatable
- There will be more children’s book apps with music by the creator entity Sunny Side Songs
- App is self contained; does not need mobile network or wifi to function
- Use responsive layout (MediaQuery + LayoutBuilder) so it scales to any device
- All generated code and configuration files where possible, should have comments explaining what each line is or what it does. While the app is a product for future sale, the comments to be geared towards someone who has experience building code bases, but not experience with app building
- Bonus feature but not necessary for initial build: collect user usage data automatically, as available. Do not need to collect location data. Usage data examples:
  - App usage time counter
  - App launch counter
  - App functionality usage like music on or off
  - App OS platform
  - Device type: mobile or tablet
  - In the case of music on, play time counter, total plays counter for each song
  - Any other usage information that can be used to improve the app
- Future in-app purchase first product to order the board book printed in the USA; takes the user to the square checkout page, in-app, to order the physical version of the book.



## 3. Interface Design



### 3.1 Artwork Placement

Artwork placement on the device screen

1. Front cover - fit artwork to screen, centered along veritical axis, portrait orientation
2. Interior spreads - fit artwork to screen, centered along veritical axis, landscape orientation
3. Back cover - fit artwork to screen, centered along veritical axis, portrait orientation

This will yield blank space above and below the artwork borders - use black background

### 3.2 Button Placement



#### 3.2.1 Global Rules

- All buttons are on the "top layer"; buttons can be over the artwork, background or combination both
- Buttons cannot overlap on another
- Button placements are normalized to safe zone dimensions

**Exit Button**

- Appears on all screens
- Exit button at top right corner of the screen, position normalized to coordinates of the device. This means:
  - While in portrait mode in the exit button will appear over the black background
  - While in landscape mode the exit button may appear over black background, over the artwork, or combination of both

**Forward and Backward Chevron Buttons**

- Forward chevron button appears on cover screen
- Forward and backward buttons appear on interior spread screens
- Backward only appears on back cover screen



#### 3.2.2 Placement (normalized to safe area)

Shared:

- buttonDiameter = max(48, 0.09 * shortestSide)
- edgeGap = max(8, 0.02 * shortestSide)
- bottomBandY = 1.0 - (edgeGap + buttonDiameter) / safeHeight (i.e. buttons sit in a bottom band, one diameter + gap above safe bottom)

Front cover (portrait):

- Exit: top-right of safe area (gap = edgeGap)
- Forward chevron: right side, vertical center of safe area
- Music: horizontal center, at bottomBandY

Interior spreads (landscape):

- Exit: top-right of safe area
- Forward / back chevrons: vertical center, left/right with edgeGap
- Music: horizontal center, at bottomBandY

Back cover (portrait):

- Exit: top-right
- Back chevron: left, at bottomBandY
- Music: horizontal center, at bottomBandY
- Restart (back to cover): right, at bottomBandY



### 3.3 Button Designs

Sizable buttons for kids, normalized to size of the device display. Overall consistent styling across the different buttons; transparent background and low opacity to show what's behind it if there is artwork behind the button.

Exit Button

- circular, circle with X inside
- Gray colors

Foward/Backward Chevron Buttons

- circular, circle with chevron inside
- Chevron is transparent
- Fill area (inside circle, outside chevron) is a translucent and/or transparent blur/distortion effect of image underneith

Music On/Off Button

- circular, using speaker symbol for music on, and speaker symbol crossed out for music off

Restart (Back to Cover) Button

- circular, circle with circular arrow restart symbol



### 3.4 Transitions

Low latency, low overhead transitions design

#### 3.4.1 Page Turning

- page turning like a book
- page fold is along center of each interior spread with soft curl illusion < 1200 ms
- page turning timing is consistent whether music is playing or not
- Allocate 1200 ms up to for page turning
- When turning pages from one interor spread to the next, animate the text scroll block size change between spreads with different text scroll block size with a short AnimatedContainer (200–400 ms) during page turn
- When turning pages from front cover to first interior spread - when forward page turn is pressed:
  - all other buttons disappear
  - start the fade out cover image to black (200 ms)
  - After fade out of cover image, immediately start fade in first interior spread (spread 1) (200 ms) from black, in landscape orientation
  - lock landscape and accept temporary sideways holding
- When turning pages from spread 6 to back cover - when forward page turn is pressed:
  - all other buttons disappear
  - start the fade to black of spread 6 image and text block (200 ms)
  - After fade out of spread 6, begin fade in of back cover image in portrait and scroll block (200 ms)
  - lock portrait and accept temporary sideways holding
- When turning pages from spread1 to cover, or back cover to spread 6:
  - mirror the fade-via-black pattern (200 ms out / 200 ms in) and set orientation at the start of the fade-in target
- When restarting book from back cover to front cover
  - all other buttons disappear
  - start the fade to black of back cover image and text block (200 ms)
  - After fade out of back cover, begin fade in of front cover image (200 ms)
  - No change in device orientation for this transition



#### 3.4.2 Music Start and Fade Out

When music is turned on:

- Cover - music starts 200 ms after app is opened and initialized
- Interior spreads - music starts 50 ms after page turn is completed
- Back cover - music starts 50 ms after page turn is completed

Music effects from user actions while music is playing:

- Front cover - when forward chevron button is pressed, music fade out starts while page is turning. Music from front cover is faded out by the end of the page transition, and before the start of the music from the next spread.
- Interior spreads - 
  - if page turn (forward or backward) is initiated while the song is playing, begin the fade out of the song to be  completed by the completion of the page turn and before start of the song from the spread user turned to.
  - Edge case - the page turn is initiated during the last 1200 ms of the song - do not do a fade out effect.
- Globally while music is playing
  - Exit button pressed causes music to fade out over 1 second, then initiate exit out of app



### 3.5 Scrolling Text Block Design

Sizable and child-friendly font

Lightweight text fade-scroll effect

`#FFFFFF` at 10% for text block background - text block goes on top of some of the artwork; artwork is still visible but text is the top layer with full opacity.

No visible border to the scroll block

### 3.6 Back Cover Scrolling Text Block Content Layout

Scrolling text block covers the majority of the back cover artwork, and has a layout of the following items. Inside `text_cover_back.md` body, content is keyed by section headings:

- `## author_bio` → author photo + bio
- `## illustrator_bio` → illustrator photo + bio
- `## book_info` → title/credits/copyright/ISBN lines
Layout order in the scroll block:

1. Logo (`logo` from frontmatter), horizontally centered
2. Author photo + `author_bio` text with circular crop 0.28 * text_block.width, horizontally centered
3. Illustrator photo + `illustrator_bio` text with circular crop 0.28 * text_block.width, horizontally centered
4. `book_info` block

Text insets: 0.05 of text_block width (instead of hard 20 px), left/right.

### 3.7 Typography & Highlighting

Typography:

- Font family: Nunito (or system rounded sans if custom font not bundled yet)
- Lyric body: 18–22 sp on phone, 24–28 sp on tablet (use LayoutBuilder breakpoint, e.g. shortestSide >= 600)
- Weight: regular for inactive text; bold for active word
- Color: near-black (#1A1A1A) on light text-block wash
- Line height: 1.35

Highlighting (music On only):

- Active word: bold + accent color warm green #2E7D32
- Inactive words: default lyric color
- Optional: current line background wash at 8–12% opacity
- When music Off or song ended: all text returns to default style



### 3.8 Touch Targets & Safe Areas

Minimum tap size

- Circular control diameter: max(48, 0.09 * shortestSide)
- Padding of max(8, 0.02 * shortestSide)
- Hit target may be larger than visible icon (use Padding / minimumSize)
- All button offsets are measured from the safe-area inset edges (MediaQuery.padding), not the physical screen edge
- Text blocks stay inside the artwork’s fitted rect; buttons may sit in letterbox (black) or over art, but never under the system notch/home bar

