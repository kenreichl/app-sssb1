20261005_1740

Testing with an iPhone 13 mini on iOS 26.5.2 connected via usb to this computer, a macbook pro 13" 2020 (intel) on macOS 14.6.1 and using xcode 16.0

Referencing your previous response, here are the issues I had while going through steps:

1. Step A. item 3, I selected Trust and entered my passcode. Item 4, I do not see "Developer Mode" within Privacy & Security
2. Completed Step B. items 1 thru 7 and set Bundle Identifier to com.kenreichl.sunnysidesongs. Item 8, it shows my device but it says waiting to connect. When opening Xcode -> Widow -> Devices and Simulators, the window displays banner to turn on developer mode on the device.
3. Step C. item 2, I do not see Apple ID / developer certificate, only an option to add a VPN

20261005_2032

Running v1 of app o iPhone 13 mini on iOS 26.5.2 connected via usb to this computer, a macbook pro 13" 2020 (intel) on macOS 14.6.1 and using xcode 16.0

Review notes:

- audio played automatically except spread 1;
  - audio does not play automatically; tapping audio button to mute and again to unmute started the song
  - starting the book over by hitting return to start button on the last "back cover" spread and advancing to spread 1 from cover does not automatically start the song; in this case muting and unmuting audio button did not start the song as it did with first pass through the book
- audio does not play automatically for all tracks;
  - when testing another instance of running the app, the songs did not automatically start
  - sometimes toggling the audio button after scrolling the text box allowed for the song to start

- app exit button (circle with "x" inside at the top right corner of any spread does nothing; button animates when tapped but app does not exit to home screen
  - the app exit button on the back cover stopped the music but did not exit the app
- no text highlighting
- text scroll works properly
- page turning is clunky
  - initially entire spread moves left, then next spread appears and shifts spread back to center; to be changed to look like book page turn with fold at center of spread
- text scroll box boundaries need to get fixed; should be constant with respect to spread dimensions
  - first check with ipad simulator in relation to text box location on iphone
- spread artwork to be edited to look like book; split at middle

