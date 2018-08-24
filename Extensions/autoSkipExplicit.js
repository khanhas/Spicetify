// START METADATA
// NAME: Christian Spotify
// AUTHOR: khanhas
// DESCRIPTION: Auto skip explicit songs. Toggle in Profile menu.
// END METADATA

/// <reference path="../globals.d.ts" />

(function ChristianSpotify() {
    const BUTTON_TEXT = "Christian mode";

    if (!Spicetify.LocalStorage) {
        setTimeout(ChristianSpotify, 200);
        return;
    }

    let ChristianMode = Spicetify.LocalStorage.get("ChristianMode") === "true";

    let menuEl = $("#PopoverMenu-container");

    // Observing profile menu
    let menuObserver = new MutationObserver(() => {
        const innerMenu = menuEl.find(".Menu__root-items");
        innerMenu.prepend(
            `<div
    class="MenuItem${ChristianMode ? " MenuItemToggle--checked MenuItem--is-active" : ""}"
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
            Spicetify.LocalStorage.set(
                "ChristianMode",
                JSON.stringify(ChristianMode)
            );
            if (ChristianMode) {
                toggle.addClass("MenuItemToggle--checked MenuItem--is-active");
            } else {
                toggle.removeClass("MenuItemToggle--checked MenuItem--is-active");
            }
        });
    });

    menuObserver.observe(menuEl[0], { childList: true });

    Spicetify.Player.addEventListener("songchange", () => {
        if (!Spicetify.Player.data) return;

        let isExplicit =
            ChristianMode &&
            Spicetify.Player.data.track.metadata.is_explicit === "true";
        if (isExplicit) {
            Spicetify.Player.next();
        }
    });
})();
