#SingleInstance force
#NoEnv
#MaxThreadsPerHotkey 1

SetCapsLockState, AlwaysOff
SetWorkingDir %A_ScriptDir%
return


vim_mode := False

; Hold Space to enter VIM Mode
#if vim_mode OR (A_TickCount - CapsLockTime > 50) OR (A_TickCount - SpaceTime > 50)
	q::BackSpace
	e::Delete
	y::Send {Left 10}
	u::Send {Up 10}
	i::Send {Down 10}
	o::Send {Right 10}
	.::End
	,::Home
	j::Up
	k::Down
	h::Left
	l::Right

	Space::vim_mode := False
	Esc::vim_mode := False





#if

*Space::
	if !SpaceTime
		SpaceTime := A_TickCount
	return
*Space Up::
	if (A_TickCount - SpaceTime < 250)  	; 250 ms
		Send {Space}
	SpaceTime := ""
	return
*CapsLock::
	if !CapsLockTime
		CapsLockTime := A_TickCount
	return

*CapsLock Up::
	if (A_TickCount - CapsLockTime < 250)  	; 250 ms
		vim_mode := !vim_mode
	else
		vim_mode := False
	CapsLockTime := ""
	return



; Function keys
$Launch_Media::Send {F1}
$Volume_Down::Send {F2}
$Volume_Up::Send {F3}
$Volume_Mute::Send {F4}
$Media_Stop::Send {F5}
$Media_Prev::Send {F6}
$Media_Play_Pause::Send {F7}
$Media_Next::Send {F8}
$Launch_Mail::Send {F9}
$Browser_Home::Send {F10}


$F1::LockDesktop()
$F2::Send {F2}
$F3::Send {Volume_Up}
$F4::Send {Volume_Down}
$F5::run SndVol.exe
$F6::Send {Media_Prev}
$F7::Send {Media_Play_Pause}
$F8::Send {Media_Next}
$F9::AdjustScreenBrightness(-5)
$F10::AdjustScreenBrightness(5)


; Numpads
NumpadDiv::Send ^#{Left}
NumpadMult::Send #{Tab}
NumpadSub::Send ^#{Right}

^Numpad1::ToggleRelay("0")
^Numpad2::ToggleRelay("1")
^Numpad3::ToggleRelay("2")

^Numpad7::WinMinimize A
^Numpad8::ToggleMaximize()
^Numpad9::WinClose A

Pause::LockDesktop()

#`::WinMinimize A

; Double tab Right Shift to Open Context Menu (Right Click)
~RShift::
	if (A_PriorHotkey <> "~RShift" or A_TimeSincePriorHotkey > 400) {
	    KeyWait RShift
	    return
	}
	Send {AppsKey}
	return

; MPC
#IfWinActive ahk_exe mpc-hc64.exe
	XButton1::SendInput, {Right}
	XButton2::SendInput, {Left}

#IfWinNotActive ahk_exe GenshinImpact.exe
	RButton::RButton
	~RButton & XButton1::Send ^#{Left}
	~RButton & XButton2::Send ^#{Right}

; VSCode
#IfWinActive ahk_exe Code.exe

	^`::
		Send, ^k
		Send, ^{Right}
		return


; Explorer
#IfWinActive ahk_class CabinetWClass
	^b::
		Send !vn{space}
		return

; Honkai Star Rail
#IfWinActive ahk_exe StarRail.exe
	~XButton1::
		While GetKeyState("XButton1", "P")
		{
			Send {Space}
			Send 1
			Sleep, 25 ; repeat rate
		}
		return
	~XButton2::
		While GetKeyState("XButton2", "P")
		{
			Send f
			Sleep, 150 ; repeat rate
		}
		return
	~Space::
		While GetKeyState("Space", "P")
		{
			Send {Space}
			Sleep, 150 ; repeat rate
		}
		return
	~E::
		While GetKeyState("E", "P")
		{
			Send E
			Sleep, 150 ; repeat rate
		}
		return
	z::
		MouseGetPos, xpos, ypos
	    MouseClick, left, 1253, 145, 1, 0
	    MouseMove, %xpos%, %ypos%, 0
	    return
	x::
		MouseGetPos, xpos, ypos
	    MouseClick, left, 1253, 173, 1, 0
	    MouseMove, %xpos%, %ypos%, 0
	    return
	`::
		MouseGetPos, xpos, ypos
	    MouseClick, left, 1201, 53, 1, 0
	    MouseMove, %xpos%, %ypos%, 0
	    return

; Genshin Impact
#IfWinActive ahk_exe GenshinImpact.exe
	~XButton1::
		While GetKeyState("XButton1", "P")
		{
			Send {LButton}
			Sleep, 150 ; repeat rate
		}
		return
	~XButton2::
		While GetKeyState("XButton2", "P")
		{
			Send f
			Sleep, 50 ; repeat rate
		}
		return

; Chrome
#IfWinActive ahk_exe chrome.exe
	XButton1::
		WinGetTitle, active_title, A
	 	if ((!!InStr(active_title, "pixiv")) = 1)
	 		Send c
		else
			Send ^{Tab}
		return
	XButton2::
		WinGetTitle, active_title, A
	 	if ((!!InStr(active_title, "pixiv")) = 1){
	 		Send b
	 		Sleep 50
	 		Send d
	 	}
		else
			Send ^+{Tab}
		return





; Methods

; Toggle Relay
ToggleRelay(relayId) {
	relay_ps := "./relay.py"
	RunWait, python %relay_ps% %relayId%,,HIDE
	return
}
ToggleMaximize() {
	WinGet MX, MinMax, A
	if (MX == 1)
	    WinRestore A
	else if (MX == 0)
	    WinMaximize A
	return
}
; Goto next window
NextWindow() {
	WinGetClass, ActiveClass, A
	WinGet, Active, ID, A
	WinGet, OpenWindowsAmount, Count, ahk_class %ActiveClass%

	if (OpenWindowsAmount > 1) {
		WinGetClass, WindowClass, A
		WinGet, WindowsWithSameTitleList, List, ahk_class %WindowClass%

		if (WindowsWithSameTitleList > 1) {
			WinActivate, % "ahk_id " WindowsWithSameTitleList%WindowsWithSameTitleList%
		}
	}
}
; Adjust screen brightness
AdjustScreenBrightness(step) {
	static service := "winmgmts:{impersonationLevel=impersonate}!\\.\root\WMI"
	monitors := ComObjGet(service).ExecQuery("SELECT * FROM WmiMonitorBrightness WHERE Active=TRUE")
	monMethods := ComObjGet(service).ExecQuery("SELECT * FROM wmiMonitorBrightNessMethods WHERE Active=TRUE")
	for i in monitors {
		curr := i.CurrentBrightness
		break
	}
	toSet := curr + step
	if (toSet < 0)
		toSet := 0
	if (toSet > 100)
		toSet := 100
	for i in monMethods {
		i.WmiSetBrightness(1, toSet)
		break
	}
	BrightnessOSD()
}
; Show brignhtness OSD
BrightnessOSD() {
	static PostMessagePtr := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "PostMessageW" : "PostMessageA", "Ptr")
	 ,WM_SHELLHOOK := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
	static FindWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "FindWindowW" : "FindWindowA", "Ptr")
	HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	IF !(HWND) {
		try IF ((shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}"))) {
			try IF ((flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}"))) {
				DllCall(NumGet(NumGet(flyoutDisp+0)+3*A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0)
				 ,ObjRelease(flyoutDisp)
			}
			ObjRelease(shellProvider)
		}
		HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	}
	DllCall(PostMessagePtr, "Ptr", HWND, "UInt", WM_SHELLHOOK, "Ptr", 0x37, "Ptr", 0)
}
; Send HTTP GET Request
HttpGet(URL) {
	static req := ComObjCreate("Msxml2.XMLHTTP")
	req.open("GET", URL, false)
	req.send()
}
Speak(speak) {
	oSPVoice := ComObjCreate("SAPI.SpVoice")
	oSpVoice.Rate := 2
	oSPVoice.Speak(speak)
}
LockDesktop() {
	DllCall("LockWorkStation")
}
OpenSoundMixer() {
	SndVol.exe
}



; Cheatsheet
; https://www.autohotkey.com/docs/v1/Hotkeys.htm
;
; # Windows Key
; ! Alt Key
; ^ Ctrl Key
; + Shift Key
