// START METADATA
// NAME: DJ Mode
// AUTHOR: khanhas
// DESCRIPTION: Queue only mode, Hide all controls. Toggles in Profile menu.
// END METADATA
(function DJMode(){

if (!chrome.localStorage || !chrome.addToQueue || !chrome.libURI) {
    setTimeout(DJMode, 200)
    return;
}

let DJSetting = JSON.parse(chrome.localStorage.get("DJMode"));
if (!DJSetting || typeof(DJSetting) !== 'object') {
    DJSetting = {
        enabled: false,
        hideControls: false,
    }
    chrome.localStorage.set("DJMode", JSON.stringify(DJSetting));
}

var menuEl = $("#profile-menu-container");

// Observing profile menu
var menuObserver = new MutationObserver(() => {
    const innerMenu = menuEl.find(".GlueMenu");
    innerMenu.prepend(
`<div 
    class="GlueMenu__item GlueMenu__item--has-submenu" 
    role="menuitem" 
    data-submenu="true" 
    tabindex="-1" 
    aria-haspopup="true" 
    aria-expanded="false"
    id="DJModeMenu">
        DJ Mode
    <div id="DJModeSubMenu" class="GlueMenu GlueMenu--submenu GlueMenu--submenu-left" 
        role="menu" 
        tabindex="-1">
        <button class="GlueMenu__item${DJSetting.enabled ? " GlueMenu__item--checked" : ""}" 
            role="menuitem" 
            data-submenu="false" 
            tabindex="-1" id="DJModeToggle">
                Enabled
        </button>
        <button class="GlueMenu__item${DJSetting.enabled && DJSetting.hideControls ? " GlueMenu__item--checked" : ""}" 
            role="menuitem" 
            data-submenu="false"
            tabindex="-1" id="DJModeToggleControl">
                Hide controls
        </button>
    </div>
</div>
`)
    $("#DJModeMenu").on("mouseover", () => {
        $("#DJModeSubMenu").addClass("open")
    });
    $("#DJModeMenu").on("mouseleave", () => {
        $("#DJModeSubMenu").removeClass("open")
    })
    $("#DJModeToggle").on("click", () => {
        DJSetting.enabled = !DJSetting.enabled;
        chrome.localStorage.set("DJMode", JSON.stringify(DJSetting));
        document.location.reload();
    })
    $("#DJModeToggleControl").on("click", () => {
        DJSetting.hideControls = !DJSetting.hideControls;
        showHideControl(DJSetting.hideControls)
        chrome.localStorage.set("DJMode", JSON.stringify(DJSetting));
    })
})

menuObserver.observe(menuEl[0], {childList: true})

if (!DJSetting.enabled) {
    // Do nothing when DJ Mode is off
    return;
}

const playerControl = $(".player-controls-container");
const extraControl = $(".extra-controls-container");

function showHideControl(hide) {
    if (hide) {
        playerControl.hide();
        extraControl.hide();
    } else {
        playerControl.show();
        extraControl.show();
    }
}

showHideControl(DJSetting.hideControls);

function isValidURI(uri) {
    const uriType = chrome.libURI.from(uri).type;
    if (!uri && uriType !== "album" && uriType !== "track" && uriType !== "episode") {
        return false;
    }
    return true;
}

function addClickToQueue(button, uri) {
    button.on("click", function() {
        chrome.addToQueue(uri, () => {
            chrome.bridgeAPI.request("track_metadata", [uri], (e, p) => {
                chrome.showNotification(`${p.name} - ${p.artists[0].name} added to queue`)
            })
        });
    })
}

function findActiveIframeAndChangeButtonIntent() {
    const activeIframe = $("iframe.active")
        if (activeIframe.length > 0) {
            var doc = activeIframe.contents()

        doc.find(".tl-cell.tl-play, .tl-cell.tl-number, .tl-cell.tl-type").each(function () {
            var playButton = $( this ).find('.button')
            if (playButton.attr("djmode-injected") === "true") {
                return;
            }
            
            var songURI = $( this ).parent().attr("data-uri");
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
            addClickToQueue(playButton, songURI)
        })

        if (DJSetting.hideControls) {
            doc.find('[data-ta-id="card-button-play"], [data-ta-id="card-button-add"], [data-ta-id="card-button-context-menu"], [data-ta-id="page-header-button-play"]').hide();
        } else {
            doc.find('[data-ta-id="card-button-play"], [data-ta-id="card-button-add"], [data-ta-id="card-button-context-menu"], [data-ta-id="page-header-button-play"]').show();
        }
        
    }
    
    var embeddedApp = $(".embedded-app.active");
    if (embeddedApp.length > 0){
        embeddedApp.find(".GlueTableCellTrackNumber").each(function() {
            var songURI = $( this ).parent().attr("data-ta-uri")

            if (!isValidURI(songURI)) {
                return;
            }
            
            $( this ).on("mouseover", function() {
                var playButton = $( this ).find('.GlueTableCellTrackNumber__button-wrapper')
                if (playButton.attr("djmode-injected") === "true") {
                    return;
                }
                playButton.html(
`<button 
    type="button" 
    class="button button-icon-with-stroke button-play">
</button>`);
                playButton.attr("djmode-injected", "true");
                
                var newButton = $( this ).find(".button");
                addClickToQueue(newButton, songURI);
            });
        })

        if (DJSetting.hideControls) {
            embeddedApp.find('[data-ta-id="play-button"], [data-ta-id="card-button-add"], [data-ta-id="card-button-context-menu"], [data-ta-id="play-button"]').hide();
        } else {
            embeddedApp.find('[data-ta-id="card-button-play"], [data-ta-id="card-button-add"], [data-ta-id="card-button-context-menu"], [data-ta-id="play-button"]').show();
        }
    }

}

setInterval(findActiveIframeAndChangeButtonIntent, 1000)

})()
