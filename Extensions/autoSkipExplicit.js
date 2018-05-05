// START METADATA
// NAME: Christian Spotify
// AUTHOR: khanhas
// DESCRIPTION: Auto skip explicit songs. Toggle in Profile menu.
// END METADATA
'use strict';
(function ChristianSpotify() {

if (!chrome.localStorage) {
    setTimeout(ChristianSpotify, 200);
    return;
}

let ChristianMode = chrome.localStorage.get("ChristianMode") === "true";

let menuEl = $("#profile-menu-container");

// Observing profile menu
let menuObserver = new MutationObserver(() => {
    const innerMenu = menuEl.find(".GlueMenu");
    innerMenu.prepend(
`<button 
    class="GlueMenu__item${ChristianMode ? " GlueMenu__item--checked" : ""}"
    id="ChristianModeToggle" 
    data-menu-item="christian-mode" 
    role="menuitemradio" 
    data-submenu="false" 
    tabindex="-1" 
    aria-checked="false"
    >
        Christian mode
</button>
`)

    $("button#ChristianModeToggle").on("click", () => {
        ChristianMode = !ChristianMode
        chrome.localStorage.set("ChristianMode", JSON.stringify(ChristianMode));
    })
})

menuObserver.observe(menuEl[0], {childList: true})

chrome.player.addEventListener("songchange", () => {
    if (!chrome.playerData || !chrome.player) return;
    
    let isExplicit = ChristianMode && chrome.playerData.track.metadata.is_explicit === "true"
    if (isExplicit) {
        chrome.player.next();
    }
})

})()