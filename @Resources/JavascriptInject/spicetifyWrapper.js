(function SpicetifyRainmeterWebsocket() {
    var ws;
    function Init(retry = 0) {
        if (retry > 10) {
            console.log("Spicetify websocket was shutdown. Please Reload or Restart Spotify to connect again.")
            return;
        }
        var url = "ws://127.0.0.1:58932/Spicetify"
        ws = new WebSocket(url);
        ws.onclose = () => {
            setTimeout(() => Init(++retry), 5000)
        };
        ws.onmessage = (event) => {
            var command = event.data.toLowerCase()
            if (command == "reloadspotify") {
                location.reload()
            }
        };
    }
    Init();
})();

const Spicetify = {
    Player: {
        addEventListener: undefined,
        back: undefined,
        data: undefined,
        decreaseVolume: undefined,
        dispatchEvent: undefined,
        eventListeners: undefined,
        formatTime: undefined,
        getDuration: undefined,
        getMute: undefined,
        getProgressMs: undefined,
        getProgressPercent: undefined,
        getRepeat: undefined,
        getShuffle: undefined,
        getThumbDown: undefined,
        getThumbUp: undefined,
        getVolume: undefined,
        increaseVolume: undefined,
        isPlaying: undefined,
        next: undefined,
        pause: undefined,
        play: undefined,
        removeEventListener: undefined,
        seek: undefined,
        setMute: undefined,
        setRepeat: undefined,
        setShuffle: undefined,
        setVolume: undefined,
        skipBack: undefined,
        skipForward: undefined,
        thumbDown: undefined,
        thumbUp: undefined,
        toggleMute: undefined,
        togglePlay: undefined,
        toggleRepeat: undefined,
        toggleShuffle: undefined,
    },

    addToQueue: undefined,

    BridgeAPI: undefined,

    CosmosAPI: undefined,

    getAudioData: undefined,

    LibURI: undefined,

    LocalStorage: undefined,

    PlaybackControl: undefined,

    Queue: undefined,

    removeFromQueue: undefined,

    test: () => {
        const SPICETIFY_METHOD = [
            "Player",
            "addToQueue",
            "BridgeAPI",
            "CosmosAPI",
            "getAudioData",
            "LibURI",
            "LocalStorage",
            "PlaybackControl",
            "Queue",
            "removeFromQueue",
            "showNotification",
        ];

        const PLAYER_METHOD = [
            "addEventListener",
            "back",
            "data",
            "decreaseVolume",
            "dispatchEvent",
            "eventListeners",
            "formatTime",
            "getDuration",
            "getMute",
            "getProgressMs",
            "getProgressPercent",
            "getRepeat",
            "getShuffle",
            "getThumbDown",
            "getThumbUp",
            "getVolume",
            "increaseVolume",
            "isPlaying",
            "next",
            "pause",
            "play",
            "removeEventListener",
            "seek",
            "setMute",
            "setRepeat",
            "setShuffle",
            "setVolume",
            "skipBack",
            "skipForward",
            "thumbDown",
            "thumbUp",
            "toggleMute",
            "togglePlay",
            "toggleRepeat",
            "toggleShuffle",
        ]

        let count = SPICETIFY_METHOD.length;
        SPICETIFY_METHOD.forEach((method) => {
            if (Spicetify[method] === undefined || Spicetify[method] === null) {
                console.error(`Spicetify.${method} is not available. Please open an issue in Spicetify repository to inform me about it.`)
                count--;
            }
        })
        console.log(`${count}/${SPICETIFY_METHOD.length} Spicetify methods and objects are OK.`)

        count = PLAYER_METHOD.length;
        PLAYER_METHOD.forEach((method) => {
            if (Spicetify.Player[method] === undefined || Spicetify.Player[method] === null) {
                console.error(`Spicetify.Player.${method} is not available. Please open an issue in Spicetify repository to inform me about it.`)
                count--;
            }
        })
        console.log(`${count}/${PLAYER_METHOD.length} Spicetify.Player methods and objects are OK.`)
    }
}