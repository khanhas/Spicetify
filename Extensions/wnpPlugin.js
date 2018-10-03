// START METADATA
// NAME: WebNowPlaying Companion
// AUTHOR: tjrulz (modded by khanhas)
// DESCRIPTION: Get song information and control player
// END METADATA

/// <reference path="../globals.d.ts" />

(function WebNowPlaying() {
    const INFO_LIST = [
        "state",
        "title",
        "artist",
        "album",
        "cover",
        "duration",
        "position",
        "volume",
        "rating",
        "repeat",
        "shuffle",
    ];

    const currentMusicInfo = {};

    INFO_LIST.forEach((field) => {
        currentMusicInfo[field] = null;
    })

    let ws;
    let musicEvents = {};
    let musicInfo = {};
    let currState = 0

    /*
ooooo   ooooo oooooooooooo ooooo        ooooooooo.   oooooooooooo ooooooooo.    .oooooo..o
`888'   `888' `888'     `8 `888'        `888   `Y88. `888'     `8 `888   `Y88. d8P'    `Y8
 888     888   888          888          888   .d88'  888          888   .d88' Y88bo.
 888ooooo888   888oooo8     888          888ooo88P'   888oooo8     888ooo88P'   `"Y8888o.
 888     888   888    "     888          888          888    "     888`88b.         `"Y88b
 888     888   888       o  888       o  888          888       o  888  `88b.  oo     .d8P
o888o   o888o o888ooooood8 o888ooooood8 o888o        o888ooooood8 o888o  o888o 8""88888P'
*/
    /**
     * Zero padding a number
     * @param {number} number number to pad
     * @param {number} length
     */
    function pad(number, length) {
        var str = String(number);
        while (str.length < length) {
            str = "0" + str;
        }
        return str;
    }

    /**
     * Convert seconds to a time string acceptable to Rainmeter
     * @param {number} timeInMs
     */
    function convertTimeToString(timeInMs) {
        const timeInSeconds = Math.round(timeInMs / 1000);
        const timeInMinutes = Math.floor(timeInSeconds / 60);
        if (timeInMinutes < 60) {
            return timeInMinutes + ":" + pad(timeInSeconds % 60, 2);
        }
        return (
            timeInMinutes / 60 +
            ":" +
            pad(timeInMinutes % 60, 2) +
            ":" +
            pad(timeInSeconds % 60, 2)
        );
    }

    /*
  .oooooo.   oooooooooo.     oooo oooooooooooo   .oooooo.   ooooooooooooo  .oooooo..o
 d8P'  `Y8b  `888'   `Y8b    `888 `888'     `8  d8P'  `Y8b  8'   888   `8 d8P'    `Y8
888      888  888     888     888  888         888               888      Y88bo.
888      888  888oooo888'     888  888oooo8    888               888       `"Y8888o.
888      888  888    `88b     888  888    "    888               888           `"Y88b
`88b    d88'  888    .88P     888  888       o `88b    ooo       888      oo     .d8P
 `Y8bood8P'  o888bood8P'  .o. 88P o888ooooood8  `Y8bood8P'      o888o     8""88888P'
                          `Y888P
*/
    function resetEventHandler() {
        musicEvents = {
            readyCheck: null,
            playpause: null,
            next: null,
            previous: null,
            progressSeconds: null,
            volume: null,
            repeat: null,
            shuffle: null,
            rating: null,
        };
    }

    //Use this object to define custom logic to retrieve data
    function resetMusicInfo() {
        INFO_LIST.forEach((field) => {
            musicInfo[field] = null;
        })
        musicInfo.readyCheck = null;
    }

    /*
ooooo     ooo ooooooooo.   oooooooooo.         .o.       ooooooooooooo oooooooooooo ooooooooo.
`888'     `8' `888   `Y88. `888'   `Y8b       .888.      8'   888   `8 `888'     `8 `888   `Y88.
 888       8   888   .d88'  888      888     .8"888.          888       888          888   .d88'
 888       8   888ooo88P'   888      888    .8' `888.         888       888oooo8     888ooo88P'
 888       8   888          888      888   .88ooo8888.        888       888    "     888`88b.
 `88.    .8'   888          888     d88'  .8'     `888.       888       888       o  888  `88b.
   `YbodP'    o888o        o888bood8P'   o88o     o8888o     o888o     o888ooooood8 o888o  o888o
*/
    function updateInfo() {
        if (musicInfo.readyCheck === null || musicInfo.readyCheck()) {
            INFO_LIST.forEach((field) => {
                try {
                    if (musicInfo[field] === null) {
                        return;
                    }

                    let temp = musicInfo[field].call();
                    if (temp !== null && currentMusicInfo[field] !== temp) {
                        ws.send(`${field.toUpperCase()}:${temp}`);
                        currentMusicInfo[field] = temp;
                    }
                } catch (e) {
                    ws.send(
                        `Error:Error updating ${field} for Spotify Desktop`
                    );
                    ws.send("ErrorD:" + e);
                }
            });
        } else {
            if (currState !== 0) {
                ws.send("STATE:" + 0);
                currState = 0;
            }
        }
    }

    /*
oooooooooooo oooooo     oooo oooooooooooo ooooo      ooo ooooooooooooo  .oooooo..o
`888'     `8  `888.     .8'  `888'     `8 `888b.     `8' 8'   888   `8 d8P'    `Y8
 888           `888.   .8'    888          8 `88b.    8       888      Y88bo.
 888oooo8       `888. .8'     888oooo8     8   `88b.  8       888       `"Y8888o.
 888    "        `888.8'      888    "     8     `88b.8       888           `"Y88b
 888       o      `888'       888       o  8       `888       888      oo     .d8P
o888ooooood8       `8'       o888ooooood8 o8o        `8      o888o     8""88888P'
*/
    function fireEvent(event) {
        if (!(musicEvents.readyCheck && musicEvents.readyCheck())) {
            return;
        }
        const m = event.data;
        const n = m.indexOf(" ");
        let type = n === -1 ? m : m.substring(0, n);
        type = type.toLowerCase();
        const info = m.substring(n + 1);
        switch (type) {
            case "playpause":
                musicEvents.playpause();
                break;
            case "next":
                musicEvents.next();
                break;
            case "previous":
                musicEvents.previous();
                break;
            case "setposition":
                musicEvents.progressSeconds(parseInt(info));
                break;
            case "setvolume":
                musicEvents.volume(parseInt(info) / 100);
                break;
            case "repeat":
                musicEvents.repeat();
                break;
            case "shuffle":
                musicEvents.shuffle();
                break;
            case "rating":
                musicEvents.rating(parseInt(info));
                break;
            case "search": {
                let query = info;

                if (!Spicetify.CosmosAPI) {
                    console.error("Cosmos API is not available.");
                    return;
                }

                if (!query) {
                    return;
                }

                let field = "tracks"
                const exclamPos = query.indexOf('!');

                if (exclamPos !== -1) {
                    let foundField = false;
                    const findField = query.substring(0, exclamPos).toLowerCase();
                    switch (findField) {
                        case "album":       foundField = true; field = "albums"; break;
                        case "artist":      foundField = true; field = "artists"; break;
                        case "playlist":    foundField = true; field = "playlists"; break;
                        case "show":        foundField = true; field = "shows"; break;
                        case "podcast":     foundField = true; field = "audioepisodes"; break;
                    }
                    if (foundField) {
                        query = query.substring(exclamPos + 1);
                    }
                }

                query = escape(query);
                const limit = 20;
                const uri = `hm://searchview/km/v4/search/${query}?entityVersion=2&limit=${limit}&imageSize=small&catalogue=&country=${__spotify.product_state.country_code}&locale=${__spotify.locale}&platform=${__spotify.client}&username=${__spotify.username}`;

                Spicetify.CosmosAPI.resolver.resolve(
                    new Spicetify.CosmosAPI.Request("GET", uri), (error, res) => {
                        if (error) {
                            console.log(error);
                            return;
                        }
                        console.log(res.getJSONBody().results[field])
                        let result = res.getJSONBody().results[field].hits;

                        if (result.length > 0) {
                            result = result.map((item) => ({
                                a: item.artists ? item.artists.map((a) => a.name).join(", ") : "",
                                n: item.name,
                                u: item.uri,
                                i: item.image,
                            }));
                        }
                        ws.send("SEARCHRESULT:" + JSON.stringify(result));
                    }
                );
                break;
            }
            case "playurl": {
                const uri = Spicetify.LibURI.from(info);
                switch (uri.type) {
                    case "track":
                    case "episode":
                        Spicetify.PlaybackControl.playTrack(info, {}, () => {});
                        break;
                    case "album":
                    case "show":
                    case "playlist":
                        Spicetify.PlaybackControl.playFromResolver(info, {}, () => {});
                        break;
                    case "artist":
                        Spicetify.PlaybackControl.playFromArtist(info, {}, () => {});
                        break;
                }
            }
        }
    }

    /*
 .oooooo..o oooooooooooo ooooooooooooo ooooo     ooo ooooooooo.
d8P'    `Y8 `888'     `8 8'   888   `8 `888'     `8' `888   `Y88.
Y88bo.       888              888       888       8   888   .d88'
 `"Y8888o.   888oooo8         888       888       8   888ooo88P'
     `"Y88b  888    "         888       888       8   888
oo     .d8P  888       o      888       `88.    .8'   888
8""88888P'  o888ooooood8     o888o        `YbodP'    o888o
*/

    function init() {
        const url = "ws://127.0.0.1:8974/";

        ws = new WebSocket(url);
        let sendData;

        ws.onopen = function() {
            ws.send("PLAYER: Spotify Desktop");

            INFO_LIST.forEach(field => {
                currentMusicInfo[field] = null;
            })

            //@TODO Dynamic update rate based on success rate
            sendData = setInterval(() => {
                updateInfo();
            }, 500);
        };

        ws.onclose = () => {
            clearInterval(sendData);
            setTimeout(function() {
                init();
            }, 5000);
        };

        ws.onmessage = (event) => fireEvent(event);
    }

    window.onbeforeunload = () => {
        ws.onclose = () => {}; // disable onclose handler first
        ws.close();
    };

    function setup() {
        resetMusicInfo();

        musicInfo.readyCheck = () => (Spicetify.Player.data ? true : false);

        musicInfo.state = () => (Spicetify.Player.isPlaying() ? 1 : 2);

        musicInfo.title = () =>
            Spicetify.Player.data.track.metadata.title || "N/A";

        musicInfo.artist = () =>
            document
                .getElementsByClassName("view-player")[0]
                .getElementsByClassName("artist")[0]
                .innerText.replace(/\n/, "");

        musicInfo.album = () =>
            Spicetify.Player.data.track.metadata.album_title || "N/A";

        musicInfo.cover = () => {
            let currCover =
                Spicetify.Player.data.track.metadata.image_xlarge_url || "";
            if (currCover !== "" && currCover.indexOf("localfile") === -1) {
                return (
                    "https://i.scdn.co/image/" +
                    currCover.substring(currCover.lastIndexOf(":") + 1)
                );
            } else {
                return "";
            }
        };

        musicInfo.duration = () =>
            convertTimeToString(Spicetify.Player.getDuration());

        musicInfo.position = () =>
            convertTimeToString(Spicetify.Player.getProgressMs());

        musicInfo.volume = () =>
            Math.round(Spicetify.Player.getVolume() * 100);

        musicInfo.rating = () => {
            const heart = document.querySelector(
                '[data-interaction-target="heart-button"]'
            );

            const isHeartAvailable = heart.style.display !== "none";
            if (isHeartAvailable) {
                if (heart.classList.contains("active")) {
                    return 5;
                }

                return 0;
            } else {
                const add = document.querySelector('[data-button="add"]');
                if (
                    add.attributes["data-interaction-intent"].value === "remove"
                ) {
                    return 5;
                }

                return 0;
            }
        };

        musicInfo.repeat = () => Spicetify.Player.getRepeat();

        musicInfo.shuffle = () => (Spicetify.Player.getShuffle() ? 1 : 0);

        resetEventHandler();

        musicEvents.readyCheck = () => (Spicetify.Player.data ? true : false);

        musicEvents.playpause = () => Spicetify.Player.togglePlay();

        musicEvents.next = () => Spicetify.Player.next();

        musicEvents.previous = () => Spicetify.Player.back();

        musicEvents.progressSeconds = (p) => Spicetify.Player.seek(p * 1000);

        musicEvents.volume = (v) => Spicetify.Player.setVolume(v);

        musicEvents.repeat = () => Spicetify.Player.toggleRepeat();

        musicEvents.shuffle = () => Spicetify.Player.toggleShuffle();

        musicEvents.rating = (rating) => {
            const like = rating > 3;
            const heart = document.querySelector(
                '[data-interaction-target="heart-button"]'
            );
            const isHeartAvailable = heart.style.display !== "none";
            if (isHeartAvailable) {
                if (heart.classList.contains("active") && !like) {
                    heart.click();
                } else if (!heart.classList.contains("active") && like) {
                    heart.click();
                }
            } else {
                const add = document.querySelector('[data-button="add"]');
                if (
                    !like &&
                    add.attributes["data-interaction-intent"].value == "remove"
                ) {
                    add.click();
                } else if (
                    like &&
                    add.attributes["data-interaction-intent"].value == "save"
                ) {
                    add.click();
                }
            }
        };
    }

    setup();
    init();
})();
