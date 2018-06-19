// START METADATA
// NAME: Trashbin
// AUTHOR: khanhas
// DESCRIPTION: Throw songs to trashbin and never hear it again.
// END METADATA

/// <reference path="../globals.d.ts" />

(function TrashBin() {
    /**
     * By default, trash songs list is saved in Spicetify.LocalStorage but
     * everything will be cleaned if Spotify is uninstalled. So instead
     * of collecting trash songs again, you can use JsonBin service to
     * store your list, which is totally free and fast. Go to website
     * https://jsonbin.io/ , create a blank json:

        {}

     * and hit Create. After that, it will generate an
     *  Access URL, hit Copy and
     * paste it to constant jsonBinURL below. URL should look like this:

        //api.jsonbin.io/b/XXXXXXXXXXXXXXXXXXXX

     */
    const jsonBinURL = "";

    let trashSongList = {};
    let trashArtistList = {};
    let userHitBack = false;
    let trashIcon = {};
    let baseArtistUri = "artist_uri";
    let banSong = () => {
        return;
    };
    const THROW_TEXT = "Throw To Trashbin";
    const UNTHROW_TEXT = "Take Out Of Trashbin";
    const TRASH_BUTTON = `<button
      id="trashbin-icon"
      class="button button-icon-only spoticon-browse-active-16"
      data-tooltip-text="${THROW_TEXT}"
      style="position: absolute; right: 24px; top: -6px; transform: scaleX(0.75);"></button>`;
    const TRASH_ARTIST_BUTTON = `<div class="glue-page-header__button throw-artist">
      <button
      class="button button-icon-with-stroke spoticon-browse-active-16"
      data-tooltip="${THROW_TEXT}"></button>
      </div>`;

    function init() {
        if (
            !Spicetify.Player.data ||
            !Spicetify.Player ||
            (!jsonBinURL && !Spicetify.LocalStorage)
        ) {
            setTimeout(init, 1000);
            return;
        }

        if (jsonBinURL) {
            $.ajax({
                url: `https:${jsonBinURL}/latest`,
                method: "GET",
                success: (data) => {
                    const oldFormat = dataIsInOldFormat(data);

                    if (oldFormat) {
                        trashSongList = migrateDataToNewFormat(
                            data["TrashSongList"]
                        );
                        trashArtistList = migrateDataToNewFormat(
                            data["TrashArtistList"]
                        );
                    } else {
                        trashSongList = data["trashSongList"];
                        trashArtistList = data["trashArtistList"];
                    }

                    if (oldFormat || !trashSongList || !trashArtistList) {
                        trashSongList = trashSongList || {};
                        trashArtistList = trashArtistList || {};

                        $.ajax({
                            url: `https:${jsonBinURL}`,
                            method: "PUT",
                            contentType: "application/json",
                            data: JSON.stringify({
                                trashSongList,
                                trashArtistList,
                            }),
                            error: (err) => {
                                console.error(err);
                            },
                        });
                    }
                },
                error: (err) => {
                    console.error(err);
                },
            });
        } else {
            trashSongList = JSON.parse(
                Spicetify.LocalStorage.get("TrashSongList")
            );
            trashArtistList = JSON.parse(
                Spicetify.LocalStorage.get("TrashArtistList")
            );

            if (dataIsInOldFormat(trashSongList))
                trashSongList = migrateDataToNewFormat(trashSongList);

            if (dataIsInOldFormat(trashArtistList))
                trashArtistList = migrateDataToNewFormat(trashArtistList);

            if (!trashSongList) {
                Spicetify.LocalStorage.set("TrashSongList", "{}");
                trashSongList = {};
            }

            if (!trashArtistList) {
                Spicetify.LocalStorage.set("TrashArtistList", "{}");
                trashArtistList = {};
            }
        }

        $(".track-text-item").append(TRASH_BUTTON);

        trashIcon = $("#trashbin-icon");

        trashIcon.on("click", () => {
            banSong();

            if (!trashSongList[Spicetify.Player.data.track.uri]) {
                trashSongList[Spicetify.Player.data.track.uri] = true;
                Spicetify.Player.next();
            } else {
                delete trashSongList[Spicetify.Player.data.track.uri];
            }

            updateIconColor();

            storeList();
        });

        // Tracking when users hit previous button.
        // By doing that, user can return to threw song to take it out of trashbin.
        $("#player-button-previous").on("click", () => {
            userHitBack = true;
        });

        updateIconPosition();
        updateIconColor();

        Spicetify.Player.addEventListener("songchange", watchChange);

        watchArtistPage();
    }

    //Observe artist page
    function watchArtistPage() {
        const target = $("iframe#app-artist");
        if (!target.length) {
            setTimeout(watchArtistPage, 1000);
            return;
        }

        function appendArtistTrashbin() {
            const headers = $("iframe#app-artist")
                .contents()
                .find(".glue-page-header__buttons");
            if (!headers.length) {
                setTimeout(appendArtistTrashbin, 100);
                return;
            }

            const artistUri = `spotify:artist:${
                $("iframe#app-artist")
                    .attr("data-app-uri")
                    .split(":")[3]
            }`;
            const throwButton = headers.find(".throw-artist");

            if (!throwButton.length) {
                headers.each(function() {
                    $(this).append(TRASH_ARTIST_BUTTON);
                    const trashButton = $(this).find(".throw-artist");

                    trashButton.attr("artist-uri", artistUri);
                    trashButton.on("click", () => {
                        if (!trashArtistList[artistUri]) {
                            trashArtistList[artistUri] = true;
                        } else {
                            delete trashArtistList[artistUri];
                        }

                        storeList();
                        updateIconColor_Artist();
                    });
                });
                updateIconColor_Artist();
            } else if (throwButton.attr("artist-uri") !== artistUri) {
                setTimeout(appendArtistTrashbin, 100);
                return;
            }
        }

        appendArtistTrashbin();

        const artistObserver = new MutationObserver(appendArtistTrashbin);
        artistObserver.observe(target[0], {
            attributes: true,
            attributeFilter: ["data-app-uri"],
        });
    }

    function storeList() {
        if (jsonBinURL) {
            $.ajax({
                url: `https:${jsonBinURL}`,
                method: "PUT",
                contentType: "application/json",
                data: JSON.stringify({ trashSongList, trashArtistList }),
                error: (err) => {
                    console.error(err);
                },
            });
        } else {
            Spicetify.LocalStorage.set(
                "TrashSongList",
                JSON.stringify(trashSongList)
            );
            Spicetify.LocalStorage.set(
                "TrashArtistList",
                JSON.stringify(trashArtistList)
            );
        }
    }

    function watchChange() {
        updateIconPosition();
        updateIconColor();

        if (userHitBack) {
            userHitBack = false;
            return;
        }

        if (trashSongList[Spicetify.Player.data.track.uri]) {
            Spicetify.Player.next();
            return;
        }

        let uriIndex = 0;
        let artistUri = Spicetify.Player.data.track.metadata[baseArtistUri];

        while (artistUri) {
            if (trashArtistList[artistUri]) {
                Spicetify.Player.next();
                return;
            }

            uriIndex++;
            artistUri =
                Spicetify.Player.data.track.metadata[
                    baseArtistUri + ":" + uriIndex
                ];
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
    function updateIconPosition() {
        const trackContainer = $(".track-text-item");

        if (!trackContainer.hasClass("two-icons")) {
            trackContainer.addClass("two-icons");
            trashIcon.css("right", "24px");
            return;
        }

        const banButton = $(".track-text-item .nowplaying-ban-button");

        if (banButton.css("display") !== "none") {
            banButton.css("visibility", "hidden");
            trashIcon.css("right", "0px");
            banSong = () => banButton.trigger("click");
        } else {
            banSong = () => {
                return;
            };
        }
    }

    function updateIconColor() {
        if (Spicetify.Player.data.track.metadata["is_advertisement"] === "true") {
            trashIcon.attr("disabled", true);
            return;
        }

        trashIcon.removeAttr("disabled");

        if (trashSongList[Spicetify.Player.data.track.uri]) {
            trashIcon.addClass("active");
            trashIcon.attr("data-tooltip-text", UNTHROW_TEXT);
        } else {
            trashIcon.removeClass("active");
            trashIcon.attr("data-tooltip-text", THROW_TEXT);
        }
    }

    function updateIconColor_Artist() {
        const buttons = $("iframe#app-artist")
            .contents()
            .find(".throw-artist");

        buttons.each(function() {
            const inner = $(this).find("button");

            if (trashArtistList[$(this).attr("artist-uri")]) {
                inner.addClass("contextmenu-active");
                inner.attr("data-tooltip", UNTHROW_TEXT);
            } else {
                inner.removeClass("contextmenu-active");
                inner.attr("data-tooltip", THROW_TEXT);
            }
        });
    }

    function dataIsInOldFormat(data) {
        if (!data) {
            return false;
        }

        return (
            Array.isArray(data) ||
            (!Array.isArray(data) &&
                (!!data["TrashSongList"] || !!data["TrashArtistList"]))
        );
    }

    function migrateDataToNewFormat(data) {
        const newDataFormat = {};

        if (data && data.length)
            data.forEach((item) => (newDataFormat[item] = true));

        return newDataFormat;
    }

    init();
})();
