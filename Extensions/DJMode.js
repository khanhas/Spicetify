// START METADATA
// NAME: DJ Mode
// AUTHOR: khanhas
// DESCRIPTION: All Play buttons will add tracks to queue, instead of play.
// END METADATA
(function DJMode(){

if (!chrome.localStorage || !chrome.addToQueue || !chrome.libURI) {
    setTimeout(DJMode, 200)
    return;
}

const isDJModeOn = chrome.localStorage.get("DJMode") === "true";

var menuEl = $("#profile-menu-container")

// Observing profile menu
var menuObserver = new MutationObserver(() => {
    const innerMenu = menuEl.find(".GlueMenu");
    innerMenu.html(
`<button class="GlueMenu__item${isDJModeOn ? " GlueMenu__item--checked" : ""}"
tabindex="-1" id="DJModeToggle">DJ Mode</button>${innerMenu.html()}`)
    $("#DJModeToggle").on("click", () => {
        chrome.localStorage.set("DJMode", `${!isDJModeOn}`)
        document.location.reload()
    })
})

menuObserver.observe(menuEl[0], {childList: true})

if (!isDJModeOn) {
    // Do nothing when DJ Mode is off
    return;
}
    

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
            console.log("%s is added to queue", uri);
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

        doc.find("").each(function() {
        })
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
        
    }

}

setInterval(findActiveIframeAndChangeButtonIntent, 1000)

})()
