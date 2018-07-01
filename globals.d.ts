declare class Spicetify {
    public static Player: {
        /**
         * Register a listener `type` on Spicetify.Player.
         *
         * On default, `Spicetify.Player` always dispatch:
         *  - `songchange` type when player changes track.
         *  - `onplaypause` type when player plays or pauses.
         * @param type
         * @param callback
         */
        addEventListener(type: string, callback: () => void): void;
        /**
         * Skip to previous track.
         */
        back(): void;
        /**
         * An object contains all information about current track and player.
         */
        data: any;
        /**
         * Decrease a small amount of volume.
         */
        decreaseVolume(): void;
        /**
         * Dispatches an event at `Spicetify.Player`.
         *
         * On default, `Spicetify.Player` always dispatch
         *  - `songchange` type when player changes track.
         *  - `onplaypause` type when player plays or pauses.
         * @param event
         */
        dispatchEvent(event: Event): void;
        eventListeners: {
            [key: string]: Array<() => void>
        };
        /**
         * Convert milisecond to `mm:ss` format
         * @param milisecond
         */
        formatTime(milisecond: number): string;
        /**
         * Return song total duration in milisecond.
         */
        getDuration(): number;
        /**
         * Return mute state
         */
        getMute(): boolean;
        /**
         * Return elapsed duration in milisecond.
         */
        getProgressMs(): number;
        /**
         * Return elapsed duration in percentage (0 to 1).
         */
        getProgressPercent(): number;
        /**
         * Return current Repeat state (No repeat = 0/Repeat all = 1/Repeat one = 2).
         */
        getRepeat(): number;
        /**
         * Return current shuffle state
         */
        getShuffle(): boolean;
        /**
         * Return track thumb down state
         */
        getThumbDown(): boolean;
        /**
         * Return track thumb up state
         */
        getThumbUp(): boolean;
        /**
         * Return current volume level.
         */
        getVolume(): number;
        /**
         * Increase a small amount of volume.
         */
        increaseVolume(): void;
        /**
         * Return a boolean whether player is playing.
         */
        isPlaying(): boolean;
        /**
         * Skip to next track.
         */
        next(): void;
        /**
         * Pause track.
         */
        pause(): void;
        /**
         * Resume track.
         */
        play(): void;
        /**
         * Unregister added event listener `type`.
         * @param type
         * @param callback
         */
        removeEventListener(type: string, callback: () => void): void;
        /**
         * Seek track to position.
         * @param position can be in percentage (0 to 1) or in milisecond.
         */
        seek(position: number): void;
        /**
         * Turn mute on/off
         * @param state
         */
        setMute(state: boolean): void;
        /**
         *
         * @param mode `0` No repeat. `1` Repeat all. `2` Repeat one track.
         */
        setRepeat(mode: number): void;
        /**
         * Set shuffle state to true or false
         * @param state
         */
        setShuffle(state: boolean): void;
        /**
         * Set volume level
         * @param level 0 to 1
         */
        setVolume(level: number): void;
        /**
         * Seek to next  `amount` of milisecond
         * @param amount in milisecond. Default: 15000.
         */
        skipBack(amount?: number): void;
        /**
         * Seek to previous `amount` of milisecond
         * @param amount in milisecond. Default: 15000.
         */
        skipForward(amount?: number): void;
        /**
         * Thumb down current track.
         */
        thumbDown(): void;
        /**
         * Thumb up current track.
         */
        thumbUp(): void;
        /**
         * Toggle Mute/No mute.
         */
        toggleMute(): void;
        /**
         * Toggle Play/Pause.
         */
        togglePlay(): void;
        /**
         * Toggle No repeat/Repeat all/Repeat one.
         */
        toggleRepeat(): void;
        /**
         * Toggle Shuffle/No shuffle.
         */
        toggleShuffle(): void;
    }

    public static addToQueue: (uri: string, callback: () => void) => void;
    public static BridgeAPI: any;
    public static CosmosAPI: any;
    public static getAudioData: (callback: (data: any) => void, uri?: string) => void;
    public static LibURI: any;
    public static LiveAPI: any;
    public static LocalStorage: any;
    public static PlaybackControl: any;
    public static Queue: any;
    public static removeFromQueue: (uri: string, callback: () => void) => void;
    public static showNotification: (text: string) => void;
}