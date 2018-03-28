// START METADATA
// NAME: Trashbin
// AUTHOR: khanhas
// DESCRIPTION: Throw songs to trashbin and never hear it again.
// END METADATA
(function TrashBin() {
    let list;
    let userHitBack = false;
    let trashIcon = $(".trashbin-icon")[0];
    let banSong = () => {return};

    const THROW_TEXT = "Throw To Trashbin";
    const UNTHROW_TEXT = "Take Out Of Trashbin";

    let observer = new MutationObserver(() => {
        UpdateIconPosition();
        UpdateIconColor();

        if (userHitBack) {
            userHitBack = false;
            return;
        }

        if (list.indexOf(chrome.playerData.track.uri) !== -1) {
            chrome.player.next();
        }
    });

    function Init() {
        if (!chrome.playerData || !chrome.player) {
            setTimeout(Init, 1000);
            return;
        }

        if (chrome.localStorage.get("TrashSongList") === null) {
            chrome.localStorage.set("TrashSongList", "[]")
        }

        list = JSON.parse(chrome.localStorage.get("TrashSongList"));

        if (!trashIcon) {
            var parent = $(".track-text-item")[0];
            var trashElement = document.createElement("button");
            trashElement.className = "trashbin-icon button button-icon-only spoticon-browse-active-16";
            trashElement.style.position = "absolute"
            trashElement.style.right = "0px"
            trashElement.style.top = "-6px"
            trashElement.style.transform = "scaleX(0.75)"
            trashElement.setAttribute("data-tooltip-text", THROW_TEXT);
            parent.append(trashElement)

            trashIcon = $(".trashbin-icon")[0];
        }

        trashIcon.addEventListener("click", () => {
            var uriIndex = list.indexOf(chrome.playerData.track.uri);

            banSong();

            if (uriIndex == -1) {
                list.push(chrome.playerData.track.uri);
                chrome.player.next()
            } else {
                list.splice(uriIndex, 1);
            }

            UpdateIconColor();

            chrome.localStorage.set("TrashSongList", JSON.stringify(list));
        });
        
        // Tracking when users hit previous button.
        // By doing that, user can return to threw song to take it out of trashbin.
        $("#player-button-previous").click(() => {
            userHitBack = true;
        })

        UpdateIconPosition();
        UpdateIconColor();

        //Song name in player bar
        var target = $(".track-text-item .inner-text-span a")[0] 
        observer.observe(target, {attributes: true})
    }

    // Change trash icon position based on playlist context
    // In normal playlists, track-text-item has one icon and its padding-left 
    // is 32px, just enough for one icon. By appending two-icons class, its 
    // padding-left is expanded to 64px.
    // In Discovery Weekly playlist, track-text-item has two icons: heart and ban.
    // Ban functionality is the kind of the same as our so instead of crowding 
    // that tiny zone with 3 icons, I hide Spotify's Ban button and replace it with
    // trash icon. Nevertheless, I still activate Ban button context menu whenever
    // user clicks at trash icon.
    function UpdateIconPosition() {
        var trackContainer = $(".track-text-item")[0]
        if (trackContainer.className.indexOf("two-icons") == -1) {
            trackContainer.classList.add("two-icons");
            trashIcon.style.right = "24px";
            return;
        }
        var banButton = $(".track-text-item .nowplaying-ban-button")[0]
        if (banButton.style.display !== "none") {
            banButton.style.visibility = "hidden";
            trashIcon.style.right = "0px";
            banSong = () => banButton.click();
        } else {
            banSong = () => {return};
        }
    }

    function UpdateIconColor() {
        if (chrome.playerData.track.metadata["is_advertisement"] == "true") {
            trashIcon.setAttribute("disabled", true);
            return;
        }
        trashIcon.removeAttribute("disabled");
        if (list.indexOf(chrome.playerData.track.uri) !== -1) {
            trashIcon.classList.add("active");
            trashIcon.setAttribute("data-tooltip-text", UNTHROW_TEXT);
        } else {
            trashIcon.classList.remove("active")
            trashIcon.setAttribute("data-tooltip-text", THROW_TEXT);
        }
    }

    Init();
})()