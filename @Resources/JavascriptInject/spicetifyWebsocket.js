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