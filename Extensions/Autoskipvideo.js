// START METADATA
// NAME: Auto Skip Video
// AUTHOR: khanhas
// DESCRIPTION: Auto skip video
// END METADATA

/// <reference path="../globals.d.ts" />

(function SkipVideo() {
    if (!Spicetify.Player.data) {
        setTimeout(SkipVideo, 2000);
        return;
    }
    Spicetify.Player.addEventListener("songchange", () => {
        //Ads are also video media type so I need to exclude them out.
        var isVideo =
            Spicetify.Player.data.track.metadata["media.type"] === "video" &&
            !(Spicetify.Player.data.track.metadata.is_advertisement === "true");
        if (isVideo) {
            Spicetify.Player.next();
        }
    });
})();
