// START METADATA
// NAME: Trashbin
// AUTHOR: khanhas
// DESCRIPTION: Throw songs to trashbin and never hear it again.
// END METADATA
(function TrashBin() {
    /*
        On default, trash songs list is saved in chrome.localStorage but 
        everything will be cleaned if Spotify is uninstalled.
        So instead of collecting trash songs again, you can use JsonBin
        service to store your list, which is totally free and fast. Go to website 
        https://jsonbin.io/ , create a blank json:
    
        {} 
    
        and hit Create. After that, it will generate a Access URL, hit Copy and 
        paste it to consant jsonBinURL below. URL should look like this:
    
        //api.jsonbin.io/b/5aXXXXXXXXXXXXXXX23e4
    */
        const jsonBinURL = '';
    
        let list = [];
        let userHitBack = false;
        let trashIcon;
        let banSong = () => {return};
        const THROW_TEXT = "Throw To Trashbin";
        const UNTHROW_TEXT = "Take Out Of Trashbin";
        const TRASH_BUTTON = '<button id="trashbin-icon" class="button button-icon-only spoticon-browse-active-16" data-tooltip-text="' 
                            + THROW_TEXT + '" style="position: absolute; right: 24px; top: -6px; transform: scaleX(0.75);"></button>';
    
        function Init() {
            if (!chrome.playerData || !chrome.player || $(".track-text-item").length < 1) {
                setTimeout(Init, 1000);
                return;
            }
    
            if (jsonBinURL) {
                $.ajax({
                    url: 'https:' + jsonBinURL + '/latest',
                    type: 'GET',
                    success: (data) => {
                        list = data["TrashSongList"];
                        if (!list) {
                            $.ajax({
                                url: 'https:' + jsonBinURL,
                                type: 'PUT',
                                contentType: 'application/json',
                                data: '{"TrashSongList":[]}',
                                success: () => {
                                    list = [];
                                },
                                error: (err) => {
                                    console.log(err.responseJSON);
                                }
                            });
                        }
                    },
                    error: (err) => {
                        console.log(err.responseJSON);
                    }
                });
            } else {
                list = JSON.parse(chrome.localStorage.get("TrashSongList"));
                if (!list) {
                    chrome.localStorage.set("TrashSongList", "[]");
                    list = [];
                }
            }
    
            $(".track-text-item").append(TRASH_BUTTON);
    
            trashIcon = $("#trashbin-icon");
    
            trashIcon.click(() => {
                var uriIndex = list.indexOf(chrome.playerData.track.uri);
    
                banSong();
    
                if (uriIndex == -1) {
                    list.push(chrome.playerData.track.uri);
                    chrome.player.next()
                } else {
                    list.splice(uriIndex, 1);
                }
    
                UpdateIconColor();
    
                if (jsonBinURL) {
                    $.ajax({
                        url: 'https:' + jsonBinURL,
                        type: 'PUT',
                        contentType: 'application/json',
                        data: '{"TrashSongList":' + JSON.stringify(list) + '}',
                        error: (err) => {
                            console.log(err.responseJSON);
                        }
                    });
                } else {
                    chrome.localStorage.set("TrashSongList", JSON.stringify(list));
                }
            });
            
            // Tracking when users hit previous button.
            // By doing that, user can return to threw song to take it out of trashbin.
            $("#player-button-previous").click(() => {
                userHitBack = true;
            })
    
            UpdateIconPosition();
            UpdateIconColor();
    
            chrome.player.addEventListener("songchange", WatchChange)
        }
    
        function WatchChange() {
            UpdateIconPosition();
            UpdateIconColor();
    
            if (userHitBack) {
                userHitBack = false;
                return;
            }
    
            if (list.indexOf(chrome.playerData.track.uri) !== -1) {
                chrome.player.next();
            }
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
            var trackContainer = $(".track-text-item")
            if (!trackContainer.hasClass("two-icons")) {
                trackContainer.addClass("two-icons");
                trashIcon.css("right", "24px");
                return;
            }
            var banButton = $(".track-text-item .nowplaying-ban-button")
            if (banButton.css("display") !== "none") {
                banButton.css("visibility", "hidden");
                trashIcon.css("right", "0px");
                banSong = () => banButton.click();
            } else {
                banSong = () => {return};
            }
        }
    
        function UpdateIconColor() {
            if (chrome.playerData.track.metadata["is_advertisement"] == "true") {
                trashIcon.attr("disabled", true);
                return;
            }
            trashIcon.attr("disabled", null);
            if (list.indexOf(chrome.playerData.track.uri) !== -1) {
                trashIcon.addClass("active");
                trashIcon.attr("data-tooltip-text", UNTHROW_TEXT);
            } else {
                trashIcon.removeClass("active")
                trashIcon.attr("data-tooltip-text", THROW_TEXT);
            }
        }
    
        Init();
    })()