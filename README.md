# SillyTavern Traygent
Companion app to [SillyTavern](https://github.com/SillyTavern/SillyTavern) that tucks it into your system tray. No windows, no fuss.

## Installation
1. Download `SillyTavernTraygent.exe` from [Releases](https://github.com/cheatfreak47/SillyTavern-Traygent/releases)
2. Drop it in your SillyTavern folder (same place as `Start.bat`)
3. Run it - icon appears in system tray
4. *(Optional)* Right-click > Create shortcut to place on:
   - Desktop
   - Start menu folder (`%APPDATA%\Microsoft\Windows\Start Menu\Programs`)
   - Pin to Taskbar/Start

## Features
- Tucks SillyTavern into your systemtray instead of an active console window
- Right clicking the tray icon offers the option of opening the webpage, restarting the server, or closing the server
- Opens SillyTavern in browser if you accidentally launch twice or double click the tray icon
- Properly kills background processes when exiting
- Config-free single-file operation

## Build Instructions
1. Install [AutoHotkey 1.1](https://www.autohotkey.com/download/ahk-install.exe)
2. Clone this repo: `git clone https://github.com/cheatfreak47/SillyTavern-Traygent.git`
3. Run the script with `--build`
