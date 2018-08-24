// START METADATA
// NAME: DJ Mode
// AUTHOR: khanhas
// DESCRIPTION: Queue only mode, Hide all controls. Toggles in Profile menu.
// END METADATA

/// <reference path="../globals.d.ts" />

(function DJMode() {
    if (!Spicetify.LocalStorage || !Spicetify.addToQueue || !Spicetify.LibURI) {
        setTimeout(DJMode, 200);
        return;
    }

    let DJSetting = JSON.parse(Spicetify.LocalStorage.get("DJMode"));
    if (!DJSetting || typeof DJSetting !== "object") {
        DJSetting = {
            enabled: false,
            hideControls: false,
        };
        Spicetify.LocalStorage.set("DJMode", JSON.stringify(DJSetting));
    }

    var menuEl = $("#PopoverMenu-container");

    // Observing profile menu
    var menuObserver = new MutationObserver(() => {
        const innerMenu = menuEl.find(".Menu__root-items");
        innerMenu.prepend(
            `<div
    class="MenuItem MenuItem--has-submenu"
    role="menuitem"
    data-submenu="true"
    tabindex="-1"
    aria-haspopup="true"
    aria-expanded="false"
    id="DJModeMenu"
>
    DJ Mode
    <div
        id="DJModeSubMenu"
        class="Menu Menu--is-submenu"
        role="menuitem"
        tabindex="-1"
    >
        <button class="MenuItem ${
            DJSetting.enabled ? "MenuItemToggle--checked MenuItem--is-active" : ""
        }"
            role="menuitem"
            data-submenu="false"
            tabindex="-1"
            id="DJModeToggle"
        >
                Enabled
        </button>
        <button
            class="MenuItem ${
                DJSetting.enabled && DJSetting.hideControls
                    ? "MenuItemToggle--checked MenuItem--is-active"
                    : ""
            }"
            role="menuitem"
            data-submenu="false"
            tabindex="-1"
            id="DJModeToggleControl"
        >
            Hide controls
        </button>
    </div>
</div>`
        );
        const menu = $("#DJModeMenu");
        menu.on("mouseover", () => {
            $("#DJModeSubMenu").addClass("open");
            $(".MenuItem").removeClass("selected");
            menu.addClass("selected");
        });
        menu.on("mouseleave", () => {
            $("#DJModeSubMenu").removeClass("open");
            menu.removeClass("selected");
        });

        $("#DJModeToggle").on("click", () => {
            DJSetting.enabled = !DJSetting.enabled;
            Spicetify.LocalStorage.set("DJMode", JSON.stringify(DJSetting));
            document.location.reload();
        });
        $("#DJModeToggleControl").on("click", () => {
            DJSetting.hideControls = !DJSetting.hideControls;
            showHideControl(DJSetting.hideControls);
            Spicetify.LocalStorage.set("DJMode", JSON.stringify(DJSetting));
            if (DJSetting.hideControls) {
                $("#DJModeToggleControl").addClass(
                    "MenuItemToggle--checked MenuItem--is-active"
                );
            } else {
                $("#DJModeToggleControl").removeClass(
                    "MenuItemToggle--checked MenuItem--is-active"
                );
            }
        });
    });

    menuObserver.observe(menuEl[0], { childList: true });

    if (!DJSetting.enabled) {
        // Do nothing when DJ Mode is off
        return;
    }

    const playerControl = $(".player-controls-container");
    const extraControl = $(".extra-controls-container");
    const nowPlayingAddButton = $(".view-player .nowplaying-add-button");

    const IFRAME_HIDE_ELEMENT_LIST =
        [
            '[data-ta-id="card-button-play"]',
            '[data-ta-id="card-button-add"]',
            '[data-ta-id="card-button-context-menu"]',
            "div.glue-page-header__buttons",
            "th.tl-more",
            ".tl-cell.tl-more",
            "th.tl-save",
            ".tl-cell.tl-save",
            "th.tl-feedback",
            ".tl-cell.tl-feedback",
            "th.tl-more",
            ".tl-cell.tl-more",
        ].join(",") + "{display: none !important}";

    const EMBEDDED_HIDE_ELEMENT_LIST =
        [
            "div.GlueHeader__buttons",
            '[data-ta-id="play-button"]',
            '[data-ta-id="card-button-add"]',
            '[data-ta-id="card-button-context-menu"]',
            '[data-ta-id="play-button"]',
            '[data-ta-id="ta-table-cell-add"]',
            '[data-ta-id="ta-table-cell-more"]',
            'th[aria-label=""]',
        ].join(",") + "{display: none !important}";

    function showHideControl(hide) {
        if (hide) {
            playerControl.hide();
            extraControl.hide();
            nowPlayingAddButton.hide();
        } else {
            playerControl.show();
            extraControl.show();
            nowPlayingAddButton.show();
        }
    }

    showHideControl(DJSetting.hideControls);

    function isValidURI(uri) {
        const uriType = Spicetify.LibURI.from(uri).type;
        if (
            !uri &&
            uriType !== "album" &&
            uriType !== "track" &&
            uriType !== "episode"
        ) {
            return false;
        }
        return true;
    }

    function addClickToQueue(button, uri) {
        button.on("click", function() {
            Spicetify.addToQueue(uri, () => {
                Spicetify.BridgeAPI.request("track_metadata", [uri], (e, p) => {
                    Spicetify.showNotification(
                        `${p.name} - ${p.artists[0].name} added to queue`
                    );
                });
            });
        });
    }

    function findActiveIframeAndChangeButtonIntent() {
        const activeIframe = $("iframe.active");
        if (activeIframe.length > 0) {
            var doc = activeIframe.contents();

            doc.find(
                ".tl-cell.tl-play, .tl-cell.tl-number, .tl-cell.tl-type"
            ).each(function() {
                var playButton = $(this).find(".button");
                if (playButton.attr("djmode-injected") === "true") {
                    return;
                }

                var songURI = $(this)
                    .parent()
                    .attr("data-uri");
                if (!isValidURI(songURI)) {
                    return;
                }

                // Remove all default interaction intent
                playButton.attr("data-button", "");
                playButton.attr("data-ta-id", "");
                playButton.attr("data-interaction-target", "");
                playButton.attr("data-interaction-intent", "");
                playButton.attr("data-log-click", "");

                playButton.attr("djmode-injected", "true");
                addClickToQueue(playButton, songURI);
            });

            if (DJSetting.hideControls) {
                addCSS(
                    doc,
                    "IframeDJModeHideControl",
                    IFRAME_HIDE_ELEMENT_LIST
                );
            } else {
                removeCSS(doc, "IframeDJModeHideControl");
            }
        }

        var embeddedApp = $(".embedded-app.active");
        if (embeddedApp.length > 0) {
            embeddedApp.find(".GlueTableCellTrackNumber").each(function() {
                var songURI = $(this)
                    .parent()
                    .attr("data-ta-uri");

                if (!isValidURI(songURI)) {
                    return;
                }

                $(this).on("mouseover", function() {
                    var playButton = $(this).find(
                        ".GlueTableCellTrackNumber__button-wrapper"
                    );
                    if (playButton.attr("djmode-injected") === "true") {
                        return;
                    }
                    playButton.html(
                        `<button
    type="button"
    class="button button-icon-with-stroke button-play">
</button>`
                    );
                    playButton.attr("djmode-injected", "true");

                    var newButton = $(this).find(".button");
                    addClickToQueue(newButton, songURI);
                });
            });

            if (DJSetting.hideControls) {
                addCSS(
                    $(document),
                    "EmbeddedDJModeHideControl",
                    EMBEDDED_HIDE_ELEMENT_LIST
                );
            } else {
                removeCSS($(document), "EmbeddedDJModeHideControl");
            }
        }
    }

    function addCSS(doc, id, text) {
        if (doc.find("head #" + id).length == 0) {
            const style = $(`<style/>`, { id, text });
            doc.find("head").append(style);
        }
    }

    function removeCSS(doc, id) {
        const found = doc.find("head #" + id);
        if (found.length > 0) {
            found.remove();
        }
    }

    setInterval(findActiveIframeAndChangeButtonIntent, 1000);
})();
