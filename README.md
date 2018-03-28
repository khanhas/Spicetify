![Logo](LOGO.svg)

[![GitHub release](https://img.shields.io/github/release/khanhas/Spicetify/all.svg?colorB=97CA00?label=version)](https://github.com/khanhas/Spicetify/releases/latest) [![Github All Releases](https://img.shields.io/github/downloads/khanhas/Spicetify/total.svg?colorB=97CA00)](https://github.com/khanhas/Spicetify/releases)  

## How to use
**1.** Download and install [**Rainmeter**](https://www.rainmeter.net/) (require version >= 4.1)  
**2.** Download and install rmskin package in [**release page**](https://github.com/khanhas/Spicetify/releases)  
**3.** Load Spicetify skin in Rainmeter Manage  
**4.** Choose **Backup** in skin UI to start backing up original Spotify files  
**5.** Pick color scheme, edit CSS then **Apply**  

**Note:** Only normal Spotify version is supported. Windows Store version is under a write permission required folder so I can't make it to work. Normal Spotify installer can be found in @Resource folder.  

![Demo1](https://i.imgur.com/xPh0bI3.png)

![Demo2](https://i.imgur.com/eiAPF6j.png)

## Themes
If you have multiple themes in Themes folder, click at back and next buttons to rotate through all of them. You also can create new theme and duplicate current theme instantly by using right mouse context menu.

![Demo3](https://i.imgur.com/B9NkBU0.png)


## How it works
Spotify UI is HTML/CSS and runs inside Chromium Embedded Framework<sup>[[1]](https://www.quora.com/How-is-JavaScript-used-within-the-Spotify-desktop-application-Is-it-packaged-up-and-run-locally-only-retrieving-the-assets-as-and-when-needed-What-JavaScript-VM-is-used)</sup>. All CSS files controlling element attributes and interaction are packed in SPA files (they basically are ZIP).  

These CSS files are extracted first then go through a preparation process that finds and replaces almost all colors with specific keywords.  

When user applies his/her own colors scheme, all keywords are replaced with actual colors value, both in hex and RRR,GGG,BBB format. 

After that, modded CSS and remaining files are transferred back to Spotify directory.

## Advanced customization
To sastify any web developer that has experience with CSS, **Inject CSS** option will allow you to customize your Spotify client even more. 

Choose **Edit CSS** button to open up user.css file. Find element class name and id in CSS files in @Resources\Extracted folder or enable Developer mode to be able to use DevTool and Inspect Element. 

You can use my CSS variables for colors instead of hard coding color value into CSS, so you can publish your Spotify theme and keep it customizable.
 
```
var(--modspotify_main_fg)
var(--modspotify_secondary_fg)
var(--modspotify_main_bg)
var(--modspotify_sidebar_and_player_bg)
var(--modspotify_cover_overlay_and_shadow)
var(--modspotify_indicator_fg_and_button_bg)
var(--modspotify_pressing_fg)
var(--modspotify_slider_bg)
var(--modspotify_sidebar_indicator_and_hover_button_bg)
var(--modspotify_scrollbar_fg_and_selected_row_bg)
var(--modspotify_pressing_button_fg)
var(--modspotify_pressing_button_bg)
var(--modspotify_selected_button)
var(--modspotify_miscellaneous_bg)
var(--modspotify_miscellaneous_hover_bg)
var(--modspotify_preserve_1)
```
Example:
```css
.button.button-green {
	color: var(--modspotify_secondary_fg)
}
```
This will change buttons text color to *Secondary FG* color you picked in the skin.

RRR,GGG,BBB format is also supported, use these variables:
```
var(--modspotify_rgb_main_fg)
var(--modspotify_rgb_secondary_fg)
var(--modspotify_rgb_main_bg)
var(--modspotify_rgb_sidebar_and_player_bg)
var(--modspotify_rgb_cover_overlay_and_shadow)
var(--modspotify_rgb_indicator_fg_and_button_bg)
var(--modspotify_rgb_pressing_fg)
var(--modspotify_rgb_slider_bg)
var(--modspotify_rgb_sidebar_indicator_and_hover_button_bg)
var(--modspotify_rgb_scrollbar_fg_and_selected_row_bg)
var(--modspotify_rgb_pressing_button_fg)
var(--modspotify_rgb_pressing_button_bg)
var(--modspotify_rgb_selected_button)
var(--modspotify_rgb_miscellaneous_bg)
var(--modspotify_rgb_miscellaneous_hover_bg)
var(--modspotify_rgb_preserve_1)
```
Example:
```css
.SearchInput__input {
	background-color: rgba(var(--modspotify_rgb_slider_bg), 0.5);
}
```
This will change search input background color to the same color as progress slider background but it has half opacity.

**Note:** I included in skin package my own CSS config. If you prefer original Spotify UI, clear user.css file or uncheck Inject CSS.  

## Extensions
Spicetify also allows you inject custom Javascript to support your theme or enhance your Spotify client functionalities. Just simply put .js file **Spicetify\Extentions** folder, activate it in Spicetify skin then Apply.
To organize scripts in skin easily, put a metadata section at top of each JS with this template:
```
// START METADATA
// NAME: Your script name
// AUTHOR: Your name
// DESCRIPTION: A little information about what it does
// END METADATA
```
Because every script is running in same enviroment so your variables/functions might conflict with global variables/functions or other scripts variables/functions. To prevent variables/functions leaking, wrap the whole script inside a function and run it immediately. Ex:

```
(function MyScript() {
	// do stuff //
})()
```

In script, you can use my functions and objects below to control player, get information:
### `chrome.player` functions
`chrome.player` | Param | Description
---|---|---
`.seek` | (*position*) | Seek track to *position*. *position* can be percentage (0 to 1) or milisecond
`.getProgressMs` | () | Return elapsed duration in milisecond.
`.getProgressPercent` | () | Return elapsed duration in percentage (0 to 1).
`.getDuration` | () | Return song total duration in milisecond.
`.skipForward` | ([*amount* = 15000]) | Seek to next *amount* of milisecond. *amount* is 15 second on default.
`.skipBack` | ([*amount* = 15000]) | Seek to previous *amount* of milisecond. *amount* is 15 second on default.
`.next` | () | Skip to next track.
`.back` | () | Skip to previous track.
`.togglePlay` | () | Toggle Play/Pause.
`.play` | () | Resume track.
`.pause` | () | Pause track.
`.isPlaying` | () | Return a boolean whether player is playing.
`.increaseVolume` | () | Increase a small amount of volume.
`.decreaseVolume` | () | Decrease a small amount of volume.
`.getVolume` | () | Return current volume level.
`.getMute` | () | Return mute state (`true`/`false`).
`.toggleMute` | () | Toggle Mute/No mute.
`.setMute` | (*boolean*) | Set mute state to `true` or `false`.
`.toggleShuffle` | () | Toggle Shuffle/No shuffle.
`.getShuffle` | () | Return current shuffle state (`true`/`false`).
`.setShuffle` | (*boolean*) | Set shuffle state to `true` or `false`.
`.toggleRepeat` | () | Toggle No repeat/Repeat all/Repeat one.
`.getShuffle` | () | Return current shuffle state (No repeat = `0`/Repeat all = `1`/Repeat one = `2`).
`.setShuffle` | (mode) | Set repeat mode `0` or `1` or `2`.
`.thumbUp` | () | Thumbup current track.
`.thumbDown` | () | Thumbdown current track.
`.getThumbUp` | () | Return track thumbup state (`true`/`false`).
`.getThumbDown` | () |  Return track thumbdown state (`true`/`false`).
`.addEventListener` | (*type*, *callback*) | Register a *type* listener on `chrome.player`. *callback* has to be a function.
`.removeEventListener` | (*type*, *callback*) | Unregister added event *type* listener.
`.dispatchEvent` | (*event*) | Dispatches an event at `chrome.player`. *event* has to be created by [Event constructor](https://developer.mozilla.org/en-US/docs/Web/API/Event/Event). `chrome.player` always dispatch an event with `"songchange"` type on default whenever player changes track.

### Objects:
Name | Description
--- | ---
`chrome.playerData` | Return current track data like uri, track name, artist, album, cover image uri, ...
`chrome.queue` | Return current queuing tracks and history.
`chrome.cosmosAPI` | Spotify cosmos API

### Functions:
Name | Param | Description
--- | --- | ---
`chrome.getAudioData` | (*callback*[, uri]) | Return current song audio data to *payload* and call *callback*(*payload*). You can specify a song *uri* to get that song audio data instead of current one.

## Credit
Thanks ![**actionless**](https://github.com/actionless) for his ![oomoxify](https://github.com/actionless/oomoxify/blob/master/oomoxify.sh) script that this skin is based on.
Thanks ![**tjhrulz**](https://github.com/tjhrulz) for his ![WebNowPlaying Browser Extension](https://github.com/tjhrulz/WebNowPlaying-BrowserExtension) and ![MessagePassing plugin](https://github.com/tjhrulz/MessagePassingForRainmeter).
