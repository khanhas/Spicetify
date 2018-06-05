// START METADATA
// NAME: Christian Spotify
// AUTHOR: khanhas
// DESCRIPTION: Auto skip explicit songs. Toggle in Profile menu.
// END METADATA
(function ChristianSpotify() {
    const BUTTON_TEXT = "Christian mode";

    if (!chrome.localStorage) {
        setTimeout(ChristianSpotify, 200);
        return;
    }

    let ChristianMode = chrome.localStorage.get("ChristianMode") === "true";

    let menuEl = $("#GluePopoverMenu-container");

    // Observing profile menu
    let menuObserver = new MutationObserver(() => {
        const innerMenu = menuEl.find(".GlueMenu__root-items");
        innerMenu.prepend(
            `<div
    class="GlueMenuItem${ChristianMode ? " GlueMenuItemToggle--checked" : ""}"
    id="ChristianModeToggle"
    data-menu-item="christian-mode"
    role="menuitemradio"
    data-submenu="false"
    tabindex="-1"
    aria-checked="false"
>
  ${BUTTON_TEXT}
</div>`
        );

        const toggle = $("#ChristianModeToggle");

        toggle.on("click", () => {
            ChristianMode = !ChristianMode;
            chrome.localStorage.set(
                "ChristianMode",
                JSON.stringify(ChristianMode)
            );
            if (ChristianMode) {
                toggle.addClass("GlueMenuItemToggle--checked");
            } else {
                toggle.removeClass("GlueMenuItemToggle--checked");
            }
        });
    });

    menuObserver.observe(menuEl[0], { childList: true });

    chrome.player.addEventListener("songchange", () => {
        if (!chrome.playerData || !chrome.player) return;

        let isExplicit =
            ChristianMode &&
            chrome.playerData.track.metadata.is_explicit === "true";
        if (isExplicit) {
            chrome.player.next();
        }
    });
})();
