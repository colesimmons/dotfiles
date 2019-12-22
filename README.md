- [Installation](#installation)
- [Settings](#settings)
  - [SSD-specific tweaks](#ssd-specific-tweaks)
  - [General System Changes](#general-system-changes)
  - [Security](#security)
  - [Trackpad, mouse, keyboard, Bluetooth accessories, and input](#trackpad-mouse-keyboard-bluetooth-accessories-and-input)
  - [Configuring the Screen](#configuring-the-screen)
  - [Finder Configs](#finder-configs)
  - [Dock & Dashboard](#dock--dashboard)
  - [Configuring Safari & WebKit](#configuring-safari--webkit)
  - [Spotlight](#spotlight)
  - [iTerm2](#iterm2)
  - [Time Machine](#time-machine)
  - [Activity Monitor](#activity-monitor)
  - [Address Book, Dashboard, iCal, TextEdit, and Disk Utility](#address-book-dashboard-ical-textedit-and-disk-utility)
  - [Mac App Store](#mac-app-store)
  - [Messages](#messages)
- [Software Installation](#software-installation)
  - [Utilities](#utilities)
  - [Apps](#apps)
  - [NPM Global Modules](#npm-global-modules)

# Installation

```bash
git clone --recurse-submodules https://github.com/atomantic/dotfiles ~/.dotfiles
cd ~/.dotfiles;
# run this using terminal (not iTerm, lest iTerm settings get discarded on exit)
./install.sh
```

> Note: running install.sh is idempotent. You can run it again and again as you add new features or software to the scripts! I'll regularly add new configurations so keep an eye on this repo as it grows and optimizes.

TODO after:
* When it finishes, open iTerm and press `Command & ,` to open preferences. Under Profiles > Colors, select "Load Presets" and choose the `Solarized Dark Patch` scheme. If it isn't there for some reason, import it from `~/.dotfiles/configs`.
* Select the `Roboto Mono` font for ASCII and `SourceCodePro+Powerline+Awesome` font for non-ASCII.
* "Reuse previous session's directory" from iTerm > Profiles > General
* Reboot before fast key repeat will be enabled
* Install BetterSnapTool, Highland, Logic, Numbers, and Pages via App Store
* Remap Caps-Lock to ESC in System Preferences > Keyboard
* Set Touch Bar to use "Expanded Control Strip" in System Preferences > Keyboard
* Disable alert sound in System Preferences > Sound
* Disable "Automatically adjust brightness" in System Preferences > Display
* Set desktop background in System Preferences > Desktop & Screen Saver
* Change default browser to Firefox in System Preferences > General
* Disable Messages notifications in System Preferences > Notifications
* In Firefox, set "Home Content" settings, DuckDuckGo as default in "Search", set "Privacy and Security" options, allow Dashlane in private windows
* Configure f.lux



# Settings
This project changes a number of settings and configures software on MacOS.

## SSD-specific tweaks
- Disable local Time Machine snapshots
- Disable hibernation (speeds up entering sleep mode)
- Remove the sleep image file to save disk space

## General System Changes
- Disable the sound effects on boot
- Menu bar: disable transparency
- Menu bar: hide the Time Machine, Volume, User, and Bluetooth icons
- Set highlight color to green
- Set sidebar icon size to medium
- Always show scrollbars
- Increase window resize speed for Cocoa applications
- Expand save panel by default
- Expand print panel by default
- allow 'locate' command
- Set standby delay to 24 hours (default is 1 hour)
- Save to disk (not to iCloud) by default
- Automatically quit printer app once the print jobs complete
- Disable the “Are you sure you want to open this application?” dialog
- Remove duplicates in the “Open With” menu (also see 'lscleanup' alias)
- Display ASCII control characters using caret notation in standard text views
- Disable automatic termination of inactive apps
- Disable the crash reporter
- Set Help Viewer windows to non-floating mode
- Reveal IP, hostname, OS, etc. when clicking clock in login window
- Restart automatically if the computer freezes
- Never go into computer sleep mode
- Disable smart dashes as they’re annoying when typing code

## Security
- Enable firewall
- Enable firewall stealth mode (no response to ICMP / ping requests)
- Disable remote apple events
- Disable wake-on modem
- Disable wake-on LAN
- Disable guest account login

## Trackpad, mouse, keyboard, Bluetooth accessories, and input
- Trackpad: enable tap to click for this user and for the login screen
- Trackpad: map bottom right corner to right-click
- Disable “natural” (Lion-style) scrolling
- Increase sound quality for Bluetooth headphones/headsets
- Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
- Use scroll gesture with the Ctrl (^) modifier key to zoom
- Follow the keyboard focus while zoomed in
- Disable press-and-hold for keys in favor of key repeat
- Set a blazingly fast keyboard repeat rate:
- Set language and text formats (english/US)

## Configuring the Screen
- Require password immediately after sleep or screen saver begins
- Save screenshots to the desktop
- Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
- Disable shadow in screenshots
- Enable subpixel font rendering on non-Apple LCDs
- Enable HiDPI display modes (requires restart)

## Finder Configs
- Keep folders on top when sorting by name (Sierra only)
- Allow quitting via ⌘ + Q; doing so will also hide desktop icons
- Disable window animations and Get Info animations
- Set Desktop as the default location for new Finder windows
- Show hidden files by default
- Show all filename extensions
- Show status bar
- Show path bar
- Allow text selection in Quick Look
- Display full POSIX path as Finder window title
- When performing a search, search the current folder by default
- Disable the warning when changing a file extension
- Enable spring loading for directories
- Remove the spring loading delay for directories
- Avoid creating .DS_Store files on network volumes
- Disable disk image verification
- Automatically open a new Finder window when a volume is mounted
- Use list view in all Finder windows by default
- Disable the warning before emptying the Trash
- Empty Trash securely by default
- Enable AirDrop over Ethernet and on unsupported Macs running Lion
- Show the ~/Library folder
- Expand the following File Info panes: “General”, “Open with”, and “Sharing & Permissions”

## Dock & Dashboard
- Enable highlight hover effect for the grid view of a stack (Dock)
- Set the icon size of Dock items to 36 pixels
- Change minimize/maximize window effect to scale
- Minimize windows into their application’s icon
- Enable spring loading for all Dock items
- Show indicator lights for open applications in the Dock
- Don’t animate opening applications from the Dock
- Speed up Mission Control animations
- Don’t group windows by application in Mission Control
- Disable Dashboard
- Don’t show Dashboard as a Space
- Don’t automatically rearrange Spaces based on most recent use
- Remove the auto-hiding Dock delay
- Remove the animation when hiding/showing the Dock
- Automatically hide and show the Dock
- Make Dock icons of hidden applications translucent
- Make Dock more transparent
- Reset Launchpad, but keep the desktop wallpaper intact

## Configuring Safari & WebKit
- Set Safari’s home page to ‘about:blank’ for faster loading
- Prevent Safari from opening ‘safe’ files automatically after downloading
- Allow hitting the Backspace key to go to the previous page in history
- Hide Safari’s bookmarks bar by default
- Hide Safari’s sidebar in Top Sites
- Disable Safari’s thumbnail cache for History and Top Sites
- Enable Safari’s debug menu
- Make Safari’s search banners default to Contains instead of Starts With
- Remove useless icons from Safari’s bookmarks bar
- Enable the Develop menu and the Web Inspector in Safari
- Add a context menu item for showing the Web Inspector in web views

## Spotlight
- Disable Spotlight indexing for any volume that gets mounted and has not yet been indexed
- Change indexing order and disable some file types from being indexed
- Load new settings before rebuilding the index
- Make sure indexing is enabled for the main volume

## iTerm2
- Installing the Solarized Dark theme for iTerm
- Don’t display the annoying prompt when quitting iTerm
- Hide tab title bars
- Set system-wide hotkey to show/hide iterm with ctrl+tick ( `^` + \`)
- Set normal font to Hack 12pt
- Set non-ascii font to Roboto Mono for Powerline 12pt

## Time Machine
- Prevent Time Machine from prompting to use new hard drives as backup volume
- Disable local Time Machine backups

## Activity Monitor
- Show the main window when launching Activity Monitor
- Visualize CPU usage in the Activity Monitor Dock icon
- Show all processes in Activity Monitor
- Sort Activity Monitor results by CPU usage

## Address Book, Dashboard, iCal, TextEdit, and Disk Utility
- Enable the debug menu in Address Book
- Enable Dashboard dev mode (allows keeping widgets on the desktop)
- Use plain text mode for new TextEdit documents
- Open and save files as UTF-8 in TextEdit
- Enable the debug menu in Disk Utility

## Mac App Store
- Enable the WebKit Developer Tools in the Mac App Store
- Enable Debug Menu in the Mac App Store

## Messages
- Disable automatic emoji substitution (i.e. use plain text smileys)
- Disable smart quotes as it’s annoying for messages that contain code
- Disable continuous spell checking

# Software Installation

homebrew, fontconfig, git, ruby (latest), nvm (node + npm), and zsh (latest) are all installed inside the `install.sh` as foundational software for running this project.
Additional software is configured in `config.js` and can be customized in your own fork/branch (you can change everything in your own fork/brance).
The following is the software that I have set as default:

## Utilities

* ack
* ag
* coreutils
* dos2unix
* findutils
* fortune
* gawk
* gifsicle
* gnupg
* gnu-sed
* homebrew/dupes/grep
* httpie
* imagemagick (only if gitshots enabled)
* imagesnap (only if gitshots enabled)
* jq
* mas
* moreutils
* neovim
* nmap
* openconnect
* reattach-to-user-namespace
* homebrew/dupes/screen
* tmux
* tree
* ttyrec
* vim --override-system-vi
* watch
* wget --enable-iri

## Apps

* Dashlane
* Docker
* Firefox Developer Edition
* Flux
* Google Chrome
* Google Cloud SDK
* ireadfast
* ITerm2
* NordVPN
* Oni
* Postman
* Sketch
* Slack
* Spotify
* TablePlus
* Telegram
* The Unarchiver
* Transmission
* VLC
* Zoom

## NPM Global Modules
* npm-check
* trash
* vtop
* elm
