#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

WinGet, checkID, ID, ahk_class SpotifyMainWindow
if not checkID
	Run, %A_AppData%\Spotify\Spotify.exe

definedBarOnlyHgt = %1%
if not definedBarOnlyHgt
	barOnlyHgt := 87
else
	barOnlyHgt := definedBarOnlyHgt

active := 0
oldWdt := 0
oldHgt := 0
wdt := 0
hgt := 0
while true {
	WinGetPos, , , wdt, hgt, ahk_class SpotifyMainWindow
	if (wdt <> oldWdt) Or (hgt <> oldHgt) Or (active <> oldActive)
	{
		if (active == 0)
		{
			ControlGetPos, , yPos, , , Chrome_RenderWidgetHostHWND1, ahk_class SpotifyMainWindow
			WinSet, Region, 0-%yPos% w%wdt% h%hgt%, ahk_class SpotifyMainWindow

		}
		else if (active == 1)
		{
			yPos := hgt - barOnlyHgt
			WinSet, Region, 0-%yPos% w%wdt% h%barOnlyHgt%, ahk_class SpotifyMainWindow
		}
		else if (active == 2)
		{
			WinSet, Region, 0-0 w%wdt% h%hgt%, ahk_class SpotifyMainWindow
		}
		oldWdt := wdt
		oldHgt := hgt
		oldActive := active
	}
	Sleep, 100
}

!+s::
{
	if (active == 0)
		active := 1
	else if (active == 1)
		active := 2
	else if (active == 2)
		active := 0
}
