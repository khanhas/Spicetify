![Logo](LOGO.svg)

[![GitHub release](https://img.shields.io/github/release/khanhas/Spicetify/all.svg?colorB=97CA00?label=version)](https://github.com/khanhas/Spicetify/releases/latest) [![Github All Releases](https://img.shields.io/github/downloads/khanhas/Spicetify/total.svg?colorB=97CA00)](https://github.com/khanhas/Spicetify/releases)  

## How to use
**1.** Download and install [**Rainmeter**](https://www.rainmeter.net/) (require version >= 4.1)  
**2.** Download and install rmskin package in [**release page**](https://github.com/khanhas/Spicetify/releases)  
**3.** Load Spicetify skin in Rainmeter Manage  
**4.** Choose **Backup** in skin UI to start backing up original Spotify files  
**5.** Pick color scheme, edit CSS then **Apply**  

**Note:** Only normal Spotify version is supported. Windows Store version is under a write permission required folder so I can't make it to work. Normal Spotify installer can be found in @Resource folder.  

![Demo1](https://i.imgur.com/pXR5Pkb.png)

![Demo2](https://i.imgur.com/m3FjX6n.png)

## How it works
Spotify UI is HTML/CSS and runs inside Chromium Embedded Framework<sup>[[1]](https://www.quora.com/How-is-JavaScript-used-within-the-Spotify-desktop-application-Is-it-packaged-up-and-run-locally-only-retrieving-the-assets-as-and-when-needed-What-JavaScript-VM-is-used)</sup>. All CSS files controlling element attributes and interaction are packed in SPA files (they basically are ZIP).  

These CSS files are extracted first then go through a preparation process that finds and replaces almost all colors with specific keywords.  

When user applies his/her own colors scheme, all keywords are replaced with actual colors value, both in hex and RRR,GGG,BBB format. 

After that, modded CSS files are updated directly to Spotify's SPA package.

## Advanced customization
To sastify any web developer that has experience with CSS, **Inject CSS** option will allow you to customize your Spotify client even more. 

Choose **Edit CSS** button to open up user.css file. Find element class name and id in CSS files in @Resources\Extracted folder. 

You can use my internal keywords for colors instead of hard coding color value into CSS, so you can publish your Spotify theme and keep it customizable. Remember, hex value has to start with `#` and doesn't have alpha value. 
 
```
modspotify_main_fg
modspotify_secondary_fg
modspotify_main_bg
modspotify_sidebar_and_player_bg
modspotify_cover_overlay_and_shadow
modspotify_indicator_fg_and_button_bg
modspotify_pressing_fg
modspotify_slider_bg
modspotify_sidebar_indicator_and_hover_button_bg
modspotify_scrollbar_fg_and_selected_row_bg
modspotify_pressing_button_fg
modspotify_pressing_button_bg
modspotify_selected_button
modspotify_miscellaneous_bg
modspotify_miscellaneous_hover_bg
modspotify_preserve_1
```
Example:
```css
.button.button-green {
	color: #modspotify_secondary_fg
}
```
This will change buttons text color to *Secondary FG* color you picked in the skin.

RRR,GGG,BBB format is also supported, use these keywords:
```
modspotify_rgb_main_fg
modspotify_rgb_secondary_fg
modspotify_rgb_main_bg
modspotify_rgb_sidebar_and_player_bg
modspotify_rgb_cover_overlay_and_shadow
modspotify_rgb_indicator_fg_and_button_bg
modspotify_rgb_pressing_fg
modspotify_rgb_slider_bg
modspotify_rgb_sidebar_indicator_and_hover_button_bg
modspotify_rgb_scrollbar_fg_and_selected_row_bg
modspotify_rgb_pressing_button_fg
modspotify_rgb_pressing_button_bg
modspotify_rgb_selected_button
modspotify_rgb_miscellaneous_bg
modspotify_rgb_miscellaneous_hover_bg
modspotify_rgb_preserve_1
```
Example:
```css
.SearchInput__input {
	background-color: rgba(modspotify_rgb_slider_bg, 0.5);
}
```
This will change search input background color to the same color as progress slider background but it has half opacity.

**Note:** I included in skin package my own CSS config. If you prefer original Spotify UI, clear user.css file or uncheck Inject CSS.  

## Credit
Thanks ![**actionless**](https://github.com/actionless) for his ![oomoxify](https://github.com/actionless/oomoxify/blob/master/oomoxify.sh) script that this skin is based on.
