#SingleInstance force
#NoEnv
#MaxThreadsPerHotkey 1
SetWorkingDir %A_ScriptDir%
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


$F1::
	Speak("locking desktop")
	DllCall("LockWorkStation")
	return
$F2::Send {F2}
$F3::Send {Volume_Up}
$F4::Send {Volume_Down}
$F5::
	Speak("opening sound mixer")
	run SndVol.exe
	return
$F6::Send {Media_Prev}
$F7::Send {Media_Play_Pause}
$F8::Send {Media_Next}
$F9::AdjustScreenBrightness(-5)
$F10::AdjustScreenBrightness(5)


; Numpads
NumpadDiv::Send ^#{Left}
NumpadMult::
	; works with 'winodows virtual desktop helper' app
	Send !3
	Speak("goto main dekstop")
	return
NumpadSub::Send ^#{Right}

^Numpad1::ToggleRelay("0")
^Numpad2::ToggleRelay("1")
^Numpad3::ToggleRelay("2")

^Numpad7::WinMinimize A
^Numpad8::ToggleMaximize()
^Numpad9::WinClose A


; Double tab Right Shift to Open Context Menu (Right Click)
~RShift::
	if (A_PriorHotkey <> "~RShift" or A_TimeSincePriorHotkey > 400) {
	    KeyWait RShift
	    return
	}
	Send {AppsKey}
	return

; One Comander
#IfWinActive ahk_exe OneCommander.exe
	
	XButton1::
		Send, {Shift down}
		KeyWait, XButton1
		Send, {Shift up}
		return
	XButton2::
		Send, {Ctrl down}
		KeyWait, XButton2
		Send, {Ctrl up}
		return
	^D::
		Send {Delete}
		return


; Explorer
#IfWinActive ahk_class CabinetWClass
	^b::
		Send !vn{space}
		return

; Honkai Star Rail
#IfWinActive ahk_exe StarRail.exe
	XButton1::
		Send f
		return
	; repeat f button when XButton is down
	~XButton2::
		Sleep, 500 ;repeat delay
		While GetKeyState("f", "P")
		{
			SendInput, {f Down}
			Sleep, 100 ; repeat rate
		}
		return

; Genshin Impact
#IfWinActive ahk_exe GenshinImpact.exe
	XButton1::
		Send f
		return
	; repeat f button when XButton is down
	~XButton2::
		Sleep, 500 ;repeat delay
		While GetKeyState("f", "P")
		{
			SendInput, {f Down}
			Sleep, 100 ; repeat rate
		}
		return
	MButton::
		; coordMode, pixel
		; Tested on 1366x768
		ImageSearch, FoundX, FoundY, 1000, 700, A_ScreenWidth, A_ScreenHeight, *0 button_1.bmp
		if (ErrorLevel = 0) {
		    MouseClick, left,  FoundY+20, FoundY+20
    		MsgBox The icon was found at %FoundX%x%FoundY%.
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

; Sublime Text
#IfWinActive ahk_exe sublime_text.exe
	F1::
		Send ^1
		return
	F2::
		Send ^2
		return
	F3::
		Send ^3
		return 






; Methods

; Toggle Relay
ToggleRelay(relayId) {
	Speak("Toggle relay yeay")
	relay_ps := "relay_toggler.ps1"
	RunWait, powershell -noprofile -command %relay_ps% %relayId%,,HIDE
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
	ComObjCreate("SAPI.SpVoice").Speak(speak)
}
LockDesktop() {
	Speak("Locking desktop")
	DllCall("LockWorkStation")
}
OpenSoundMixer() {
	Speak("Open sound mixer")
	SndVol.exe
}