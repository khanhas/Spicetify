// START METADATA
// NAME: Shuffle+
// AUTHOR: khanhas
// DESCRIPTION: True shuffle wtih no bias.
// END METADATA

(function ShufflePlus() {
// Context shuffle buttons
const CONTEXT_SHUFFLE = `<button class="button button-green shufflePlusContext">Shuffle Context</button>`;

// Queue shuffle buttons
const QUEUE_SHUFFLE = `<button class="button button-green shufflePlusQueue">Shuffle Queue</button>`;

// Text of notifcation when queue is shuffled sucessfully
const NOTIFICATION_TEXT = "Shuffled!";

// Whether Shuffer Queue should show.
const showShuffleQueueButton = true;

if (!chrome.cosmosAPI) {
    setTimeout(ShufflePlus, 1000);
    return;
}

const interval = setInterval(() => {
    const curActive = $("iframe.active")
    if (curActive.length > 0) {
        var curURI = curActive.attr("data-app-uri");
        if (curURI === "spotify:app:queue") {
            const doc = curActive.contents();
            if (!doc) return;

            const header = doc.find(".glue-page-header__buttons");

            header.append(CONTEXT_SHUFFLE);
            header.find(".shufflePlusContext").click(contextShuffle);

            if (showShuffleQueueButton) {
                header.append(QUEUE_SHUFFLE);
                header.find(".shufflePlusQueue").click(queueShuffle);
            }

            clearInterval(interval);
        }
    };
}, 1000)

function contextShuffle() {
    const contextURI = chrome.playerData.context_uri;
    const uriObj = chrome.libURI.from(contextURI);
    const uriType = uriObj.type;
    if (uriType === "playlist") {
        playlistShuffle(contextURI);

    } else if (uriType === "collection") {
        collectionShuffle();

    } else if (uriType === "album") {
        albumShuffle(contextURI);

    } else if (uriType === "show") {
        showShuffle(uriObj._base62Id);

    } else {
        chrome.showNotification && chrome.showNotification(`Unsupported context URI type: ${uriType}`)
    }
}

function queueShuffle() {
    let replace = chrome.queue.next_tracks;
    let delimiterIndex = -1;

    for (let i = 0; i < replace.length; i++) {
        if (replace[i].uri === "spotify:delimiter") {
            delimiterIndex = i;
            break;
        }
    }

    if (delimiterIndex !== -1) {
        replace.splice(delimiterIndex)
    }

    setQueue(shuffle(replace));
}

function playlistShuffle(uri) {
    chrome.bridgeAPI.cosmosJSON({
        method: 'GET',
        uri: `sp://core-playlist/v1/playlist/${uri}/rows`,
        body: { policy: {
            link: true
        }}
    }, (error, res) => {
        if (error) {
            console.log("playlistShuffle", error)
            return;
        }
        let replace = res.rows;
        replace = replace.map((item) => ({
            uri: item.link,
        }))

        setQueue(shuffle(replace));
    })
}

function collectionShuffle() {
    chrome.bridgeAPI.cosmosJSON({
        method: 'GET',
        uri: "sp://core-collection/unstable/@/list/tracks/all",
        body: {
            policy: {
                list: {
                    link: true,
                }
            }
        }
    }, (error, res) => {
        if (error) {
            console.log("collectionShuffle", error)
            return;
        }
        let replace = res.items;
        replace = replace.map((item) => ({
            uri: item.link,
        }))

        setQueue(shuffle(replace));
    })
}

function albumShuffle(uri) {
    const arg = [uri, 0, -1];
    chrome.bridgeAPI.request('album_tracks_snapshot', arg, (error, res) => {
        if (error) {
            console.log("albumShuffle", error)
            return;
        }
        let replace = res.array;
        replace = replace.map((item) => ({
            uri: item,
        }))

        setQueue(shuffle(replace));
    })
}

function showShuffle(uriBase62) {
    chrome.cosmosAPI.resolver.get({
        url: `sp://core-show/unstable/show/${uriBase62}`,
    }, (error, res) => {
        if (error) {
            console.log("showShuffle", error)
            return;
        }
        let replace = res.getJSONBody().items;

        replace = replace.map((item) => ({
            uri: item.link,
        }))

        setQueue(shuffle(replace));
    })
}

// From: https://bost.ocks.org/mike/shuffle/
function shuffle(array) {
    let counter = array.length;

    // While there are elements in the array
    while (counter > 0) {
        // Pick a random index
        let index = Math.floor(Math.random() * counter);

        // Decrease counter by 1
        counter--;

        // And swap the last element with it
        let temp = array[counter];
        array[counter] = array[index];
        array[index] = temp;
    }
    return array;
}

function setQueue(state) {
    state.push({uri: "spotify:delimiter"})
    const currentQueue = chrome.queue;
    currentQueue.next_tracks = state;

    const stringified = JSON.stringify(currentQueue);

    state.length = 0; //Flush array.

    const request = new chrome.cosmosAPI.Request("PUT", "sp://player/v2/main/queue", null, stringified);

    chrome.cosmosAPI.resolver.resolve(request, (error, response) => {
        if (error) {
            console.log(error);
            return;
        } else {
            chrome.showNotification && chrome.showNotification("Shuffled!")
        }
    });
}
})()