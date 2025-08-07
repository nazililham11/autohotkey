#SingleInstance force
#NoEnv
#MaxThreadsPerHotkey 1

#Include hyperWindowSnap.ahk

; SetCapsLockState, AlwaysOff
return



$F1::LockDesktop()
$F9::AdjustScreenBrightness(-5)
$F10::AdjustScreenBrightness(5)


; Special mapping for my 65% keyboard layout
NumpadHome::SendInput !1
NumpadUp::SendInput !2
NumpadPgup::SendInput !3
NumpadLeft::SendInput !4
NumpadClear::SendInput !5
NumpadRight::SendInput !6
NumpadEnd::Delete
NumpadDown::Home
NumpadPgdn::Pgup
NumpadIns::End
NumpadDel::PgDn

+BackSpace::Delete
#BackSpace::WinClose  A

#NumpadIns:: 
#Numpad0::ToggleWindowTitileBar()
!#Space::OpenAlacrittyCommnand()
#NumpadSub:: SendInput {PrintScreen}

#Escape:: WinMinimize a

; Double tab Right Shift to Open Context Menu (Right Click)
~RShift::
	if (A_PriorHotkey <> "~RShift" or A_TimeSincePriorHotkey > 400) {
	    KeyWait RShift
	    return
	}
	SendInput {AppsKey}
	return


; When numlock are off, use Numpad + and - to switch between virtual desktops
#If !GetKeyState("NumLock", "T")
    NumpadAdd::SendInput ^#{Left}
	NumpadSub::SendInput ^#{Right}


; custom Vim like
#If GetKeyState("CapsLock", "T") | GetKeyState("CapsLock", "P")
	j::Left
	k::Down
	l::Right
	i::Up

	u::BackSpace
	o::Delete
	p::Home
	`;::End
	[::PgUp
	'::PgDn

	; 	j::Up
	; 	k::Down
	; 	h::Left
	; 	l::Right

#If


; MPC
#IfWinActive ahk_exe mpc-hc64.exe
	XButton1::Right
	XButton2::Left


; VSCode
#IfWinActive ahk_exe Code.exe

	^`::
		SendInput ^k
		SendInput ^{Right}
		return


; Explorer
#IfWinActive ahk_class CabinetWClass
	^b::
		SendInput !vn{space}
		return


; Honkai Star Rail
#IfWinActive ahk_exe StarRail.exe
	~XButton1::
		While GetKeyState("XButton1", "P") {
			SendInput {Space}
			SendInput 1
			Sleep, 25 ; repeat rate
		}
		return
	~XButton2::
		While GetKeyState("XButton2", "P") {
			SendInput f
			Sleep, 150 ; repeat rate
		}
		return
	~E::
		While GetKeyState("E", "P") {
			SendInput E
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
    CapsLock::
		MouseGetPos, xpos, ypos
	    MouseClick, left, 1201, 53, 1, 0
	    MouseMove, %xpos%, %ypos%, 0
	    return


; Genshin Impact
#IfWinActive ahk_exe GenshinImpact.exe
	~XButton1::
		While GetKeyState("XButton1", "P") {
			SendInput {LButton}
			Sleep, 150 ; repeat rate
		}
		return
	~XButton2::
		While GetKeyState("XButton2", "P") {
			SendInput f
			Sleep, 50 ; repeat rate
		}
		return


; Sublime Text
#IfWinActive ahk_exe sublime_text.exe
	!Right:: SendInput {F2}
	!Left:: SendInput +{F2}


; Web Browser
#If WinActive("ahk_exe msedge.exe") or WinActive("ahk_exe chrome.exe")
	XButton1:: SendInput ^{Tab}
	XButton2:: 
		WinGetTitle, active_title, A
	 	if ((!!InStr(active_title, "pixiv")) == 1) {
	 		SendInput b
	 		Sleep 50
	 		SendInput d
	 	} 
	 	else {
			SendInput ^+{Tab}
	 	}
		return
	^Space:: SendInput ^+a
 

; ------------------------------------------------------------------------------------------------
; Methods
; ------------------------------------------------------------------------------------------------

ToggleWindowTitileBar() {
	WinGet, currentStyle, Style, A
    titleBarHidden := !(currentStyle & 0xC00000)

    ; MsgBox %currentStyle%
	if (!titleBarHidden) {
		WinSet, Style, -0xC00000, A
		WinSet, Style, -0x840000, A
	} 
	else {	
		WinSet, Style, +0xC00000, A
		WinSet, Style, +0x840000, A
	}
	return
}

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

BrightnessOSD() {
	static PostMessagePtr := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "PostMessageW" : "PostMessageA", "Ptr")
	static WM_SHELLHOOK := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
	static FindWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "FindWindowW" : "FindWindowA", "Ptr")

	HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	if !(HWND) {
		try if ((shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}"))) {
			try if ((flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}"))) {
				DllCall(NumGet(NumGet(flyoutDisp + 0) + 3 * A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0), ObjRelease(flyoutDisp)
			}
			ObjRelease(shellProvider)
		}
		HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	}
	DllCall(PostMessagePtr, "Ptr", HWND, "UInt", WM_SHELLHOOK, "Ptr", 0x37, "Ptr", 0)
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

OpenAlacrittyCommnand() {
	config_file := "%APPDATA%\alacritty\command.toml"
	working_dir := "C:/"
	command := "cmd /k cls"
	Run alacritty.exe --config-file %config_file% --working-directory %working_dir% --command %command%
}


; Cheatsheet
; https://www.autohotkey.com/docs/v1/Hotkeys.htm
;
; # Windows Key
; ! Alt Key
; ^ Ctrl Key
; + Shift Key
