// START METADATA
// NAME: Christian Spotify
// AUTHOR: khanhas
// DESCRIPTION: Auto skip explicit songs
// END METADATA
'use strict';
(function ChristianSpotify() {
    chrome.player.addEventListener("songchange", () => {
        if (!chrome.playerData || !chrome.player) return;
        
        var isExplicit = chrome.playerData.track.metadata.is_explicit === "true"
        if (isExplicit) {
            chrome.player.next();
        }
    })
})()