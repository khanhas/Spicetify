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
        paste it to constant jsonBinURL below. URL should look like this:
    
        //api.jsonbin.io/b/5aXXXXXXXXXXXXXXX23e4
    */
        const jsonBinURL = '';
    
        let list = [];
        let artistList = [];
        let userHitBack = false;
        let trashIcon;
        let baseArtistUri = "artist_uri"
        let banSong = () => {};
        const THROW_TEXT = "Throw To Trashbin";
        const UNTHROW_TEXT = "Take Out Of Trashbin";
        const TRASH_BUTTON = `<button id="trashbin-icon" class="button button-icon-only spoticon-browse-active-16" data-tooltip-text="${THROW_TEXT}" style="position: absolute; right: 24px; top: -6px; transform: scaleX(0.75);"></button>`
        const TRASH_ARTIST_BUTTON = `<div class="glue-page-header__button throw-artist"><button class="button button-icon-with-stroke spoticon-browse-active-16" data-tooltip="${THROW_TEXT}"></button></div>`
    
        function Init() {
            if (!chrome.playerData || !chrome.player || (!jsonBinURL&&!chrome.localStorage)) {
                setTimeout(Init, 1000);
                return;
            }
    
            if (jsonBinURL) {
                $.ajax({
                    url: `https:${jsonBinURL}/latest`,
                    type: 'GET',
                    success: data => {
                        list = data["TrashSongList"];
                        artistList = data["TrashArtistList"];
                        if (!list || !artistList) {
                            list = list||[];
                            artistList = artistList||[];
                            var initList = {
                                "TrashSongList": list,
                                "TrashArtistList": artistList
                            };
        
                            $.ajax({
                                url: `https:${jsonBinURL}`,
                                type: 'PUT',
                                contentType: 'application/json',
                                data: JSON.stringify(initList),
                                error: err => {
                                    console.log(err.responseJSON);
                                }
                            });
                        }
                    },
                    error: err => {
                        console.log(err.responseJSON);
                    }
                });
            } else {
                list = JSON.parse(chrome.localStorage.get("TrashSongList"));
                artistList = JSON.parse(chrome.localStorage.get("TrashArtistList"));
                if (!list) {
                    chrome.localStorage.set("TrashSongList", "[]");
                    list = [];
                }
                if (!artistList) {
                    chrome.localStorage.set("TrashArtistList", "[]");
                    artistList = [];
                }
            }
    
            WatchPlayer()
    
            WatchArtistPage()
        }
        
        function WatchPlayer() {
            if ($(".track-text-item").length < 1) {
                setTimeout(WatchPlayer, 1000);
                return;
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
    
                StoreList();
            });
            
            // Tracking when users hit previous button.
            // By doing that, user can return to threw song to take it out of trashbin.
            $("#player-button-previous").click(() => {
                userHitBack = true;
            })
    
            UpdateIconPosition();
            UpdateIconColor();
    
            chrome.player.addEventListener("songchange", WatchChange);
        }

        //Observe artist page
        function WatchArtistPage() {
            var target = $("iframe#app-artist");
            if (target.length < 1) {
                setTimeout(WatchArtistPage, 1000);
                return;
            }
    
            function AppendArtistTrashbin() {
                var headers = $("iframe#app-artist").contents()
                        .find(".glue-page-header__buttons");
                if (headers.length < 1) {
                    setTimeout(AppendArtistTrashbin, 100);
                    return;
                }
    
                var artistUri = $("iframe#app-artist").attr("data-app-uri").split(/:/)
                artistUri = "spotify:artist:" + artistUri[3]
    
                var throwButton = headers.find(".throw-artist");
                
                if (throwButton.length < 1) {
                    headers.each(function() {
                        $(this).append(TRASH_ARTIST_BUTTON);
                        var trashButton = $(this).find(".throw-artist");
    
                        trashButton.attr("artist-uri", artistUri);
                        trashButton.click(() => {
                            var uriIndex = artistList.indexOf(artistUri);
    
                            if (uriIndex == -1) {
                                artistList.push(artistUri);
                            } else {
                                artistList.splice(uriIndex, 1);
                            }
    
                            StoreList();
                            UpdateIconColor_Artist();
                        })
    
                    })
                    UpdateIconColor_Artist();
                } else if (throwButton.attr("artist-uri") !== artistUri) {
                    setTimeout(AppendArtistTrashbin, 100);
                    return;
                }
            }
    
            AppendArtistTrashbin();
    
            var artistObserver = new MutationObserver(AppendArtistTrashbin);
            artistObserver.observe(target[0], {
                attributes: true, 
                attributeFilter: ["data-app-uri"]
            });
        }
        
        function StoreList() {
            if (jsonBinURL) {
                $.ajax({
                    url: `https:${jsonBinURL}`,
                    type: 'PUT',
                    contentType: 'application/json',
                    data: `{"TrashSongList":${JSON.stringify(list)}, "TrashArtistList":${JSON.stringify(artistList)}}`,
                    error: err => {
                        console.log(err.responseJSON);
                    }
                });
            } else {
                chrome.localStorage.set("TrashSongList", JSON.stringify(list));
                chrome.localStorage.set("TrashArtistList", JSON.stringify(artistList));
            }
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
                return;
            }
    
            var uriIndex = 0 
            var artistUri = chrome.playerData.track.metadata[baseArtistUri]
            while (artistUri) {
                if (artistList.indexOf(artistUri) !== -1) {
                    chrome.player.next();
                    return;
                }
                uriIndex++;
                artistUri = chrome.playerData.track.metadata[baseArtistUri + ':' + uriIndex]
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
                banSong = () => {};
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
    
        function UpdateIconColor_Artist() {
            var buttons = $("iframe#app-artist").contents().find(".throw-artist");
            
            buttons.each(function() {
                var inner = $(this).find("button");
                
                if (artistList.indexOf($(this).attr("artist-uri")) !== -1) {
                    inner.addClass("contextmenu-active");
                    inner.attr("data-tooltip", UNTHROW_TEXT);
                } else {
                    inner.removeClass("contextmenu-active")
                    inner.attr("data-tooltip", THROW_TEXT);
                }
            })
            
        }
    
        Init();
    })()