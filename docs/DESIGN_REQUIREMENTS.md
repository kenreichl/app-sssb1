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



### 1.2 App Functions

For detailed UX requirements, see `docs/UX_REQUIREMENTS.md`

- Music on/off
- Smooth page turning like a book
- Simple text scroll block for interior spreads and back cover
- Text highlighting and autoscrolling when music is on



## 2. Overall Design Principles

- Design for best performance
- Design for backwards compatibility with older iOS and android devices
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
- Button placements are normalized to screen dimensions unless explicity specified in pixels

**Exit Button**

- Appears on all screens
- Exit button at top right corner of the screen, position normalized to coordinates of the device. This means:
  - While in portrait mode in the exit button will appear over the black background
  - While in landscape mode the exit button may appear over black background, over the artwork, or combination of both
- Exits the app; does not run in the background and does not resume where left off upon exit

**Forward and Backward Chevron Buttons**

- Forward chevron button appears on cover screen
- Forward and backward buttons appear on interior spread screens
- Backward only appears on back cover screen

**Restart Button -** Only appears on the back cover page

#### 3.2.2 Placement Details

1. Front cover
  1. Exit button - top right corner
  2. Next page cheveron button (pointing right) - 200 px above bottom edge of screen, right edge of button has 10 px gap to right edge of screen
  3. Music on/off button - center along horizontal axis of display in portrait, 200 px above bottom edge of screen.
2. Interior spreads
  1. Exit button - top right corner
  2. Next page chevron button (pointing right) - center along vertical axis, right edge of button has 10 px gap to right edge of screen
  3. Previous page chevron button (pointing left) - center along vertical axis, left edge of button has 10 px gap to left edge of screen
  4. Music on/off button - center along horizontal axis of display in landscape, 200 px above bottom edge of screen.
3. Back cover
  1. Exit button - top right corner
  2. Previous page chevron button (pointing left) - 200 px above bottom edge of screen, left edge of button has 10 px gap to left edge of screen
  3. Music on/off button, center along horizontal axis of display in portrait, 200 px above bottom edge of screen.
  4. Restart button or "back to cover" button - 200 px above bottom edge of screen, right edge of button has 10 px gap to right edge of screen



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

Restart Button

- circular, circle with circular arrow restart symbol



### 3.4 Transitions

Low latency, low overhead transitions design

#### 3.4.1 Page Turning

- page turning like a book
- page fold is along center of each interior spread
- page turning timing is consistent whether music is playing or not
- Allocate 1200 ms up to for page turning
- When turning pages from one interor spread to the next, or interior spread to the back cover, animate the text scroll block size change between spreads with different text scroll block size with a short AnimatedContainer (200–400 ms) during page turn



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



### 3.5 Scrolling Text Block Design

Sizable and child-friendly font

Lightweight text fade-scroll effect

Low opacity for text block background - text block goes on top of some of the artwork; artwork is still visible but text is the top layer with full opacity.

No visible border to the scroll block

### 3.6 Back Cover Scrolling Text Block Content Layout

Scrolling text block covers the majority of the back cover artwork, and has a layout of the following items

1. Obi Kanda Medicinals (the owner of the copywrite, owner of registered trademark for Sunny Side Songs and publisher of the book) logo, centered along horizontal axis at the top of the scroll block
2. About the Authors
  1. Photo of the author Ngonda Badila from `assets/images/photo-bio-ng.jpg`, circular crop, centered along horizontal axis, followed by author bio text from line 14 of `assets/data/text_cover_back.md`, left justified with 20 px margin from left and right border of scroll block
  2. Photo of the illustrator Ntangou Badila from `assets/images/photo-bio-nt.jpg`, circular crop, centered along horizontal axis, followed by illustrator bio text from line 16 of `assets/data/text_cover_back.md`, left justified with 20 px margin from left and right border of scroll block
3. Book information - lines 18 - 25 from `assets/data/text_cover_back.md`, left justified with 20 px margin from left and right border of scroll block

