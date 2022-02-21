---
title: Disable Window Screenshot Shadow on macOS
description: ""
date: 2022-02-21 10:12:00 +0700
tags: [Tips, New Mac setup]
---

An old tip found on [osxdaily.com](http://osxdaily.com/2011/05/23/disable-shadow-screen-shots-mac/). Copying it here since I'd like to have all the stuff I use when setting up a new mac machine in one place.

Screenshotting a window in macOS is simple: press `Cmd-Shift-4`, then `Space` and then select the window you'd like to make screenshot of. By default, macOS adds a window shadow on the screenshot which makes the resulting image bigger. I personally think this is unnecessary and prefer disabling the shadow on my screenshots. To do so, type these commands in your terminal of choice:

```
defaults write com.apple.screencapture disable-shadow -bool true
killall SystemUIServer
```
