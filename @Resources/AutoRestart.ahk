#NoEnv
#NoTrayIcon
#SingleInstance, force
; #Warn  ; Enable warnings to assist with detecting common errors.

WinGet, hwnd, PID, ahk_class SpotifyMainWindow
Process, Close, %hwnd%
WinWaitClose, ahk_class SpotifyMainWindow
Run, %A_AppData%\Spotify\Spotify.exe