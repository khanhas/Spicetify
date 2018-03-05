#NoEnv
#NoTrayIcon
#SingleInstance, force
; #Warn  ; Enable warnings to assist with detecting common errors.

WinGet, hwnd, PID, ahk_exe Spotify.exe
Process, Close, %hwnd%
WinWaitClose, ahk_exe Spotify.exe
Run, %A_AppData%\Spotify\Spotify.exe