// START METADATA
// NAME: Auto Skip Video
// AUTHOR: khanhas
// DESCRIPTION: Auto skip video
// END METADATA
(function SkipVideo() {
    if (!chrome.playerData || !chrome.player) {
        setTimeout(SkipVideo, 2000);
        return;
    }
    chrome.player.addEventListener("songchange", () => {
        //Ads are also video media type so I need to exclude them out.
        var isVideo = chrome.playerData.track.metadata["media.type"]==="video"
            && !(chrome.playerData.track.metadata.is_advertisement==="true")
        if (isVideo) {
            chrome.player.next();
        }
    })
})()