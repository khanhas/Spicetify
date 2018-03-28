(function SpicetifyRainmeterWebsocket() {
    var ws;
    function Init() {
        var url = "ws://127.0.0.1:58932/Spicetify"
        ws = new WebSocket(url);
        ws.onclose = () => {
            setTimeout(() => Init(), 5000)
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