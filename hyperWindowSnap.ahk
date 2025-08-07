/**
 * Hyper Window Snap
 * Hyper Window Snap is an AutoHotkey script for moving and resizing windows to into quadrants, especially useful for 4k monitors.
 * Based on Advanced Window Snap by Andrew Moore.
 *
 * @author Andrew Moore <andrew+github@awmoore.com>
 * @author Jeff Axelrod <jeff+github@theaxelrods.com>
 * @version 1.0
 */
 
/**
 * SnapActiveWindow resizes and moves (snaps) the active window to a given position.
 * @param {string} winPlaceVertical   The vertical placement of the active window.
 *                                    Expecting "bottom" or "middle", otherwise assumes
 *                                    "top" placement.
 * @param {string} winPlaceHorizontal The horizontal placement of the active window.
 *                                    Expecting "left" or "right", otherwise assumes
 *                                    window should span the "full" width of the monitor.
 * @param {string} winSizeHeight      The height of the active window in relation to
 *                                    the active monitor's height. Expecting "half" size,
 *                                    otherwise will resize window to a "third".
 */
 
SplitSnapActiveWindow(winPlaceVertical, winPlaceHorizontal, winSizeHeight) {
    oldClipboard = clipboardAll
    clipboard =
    while(clipboard == "") {
        SendInput ^l^c
    }
    SendInput ^w^n
    WinWaitNotActive
    SendInput %clipboard%{enter}
    clipboard := %oldClipboard%
    SnapActiveWindow(winPlaceVertical, winPlaceHorizontal, winSizeHeight)
}

SnapActiveWindow(winPlaceVertical, winPlaceHorizontal, winSizeHeight) {
    bPadding := 15
    tPadding := 15
    lPadding := 15
    rPadding := 15
    xGap := 15
    yGap := 15
    
    activeWin := WinExist("A")
    activeMon := GetMonitorIndexFromWindow(activeWin)
        WinGet, MinMaxState, MinMax, A
        If (MinMaxState) {
            WinRestore, A
        }
    
    SysGet, MonitorWorkArea, MonitorWorkArea, %activeMon%

    if (winSizeHeight == "half") {
        height := (MonitorWorkAreaBottom - MonitorWorkAreaTop)/2 - bPadding  - (xGap / 2)
    } else if (winSizeHeight == "full") {
        height := (MonitorWorkAreaBottom - MonitorWorkAreaTop) - bPadding - tPadding
    } else if (winSizeHeight == "third") {
        height := (MonitorWorkAreaBottom - MonitorWorkAreaTop)/3- bPadding - tPadding - xGap 
    }

    if (winPlaceHorizontal == "left") {
        posX  := MonitorWorkAreaLeft + lPadding
        width := (MonitorWorkAreaRight - MonitorWorkAreaLeft)/2 - lPadding - (yGap / 2)
    } else if (winPlaceHorizontal == "right") {
        posX  := MonitorWorkAreaLeft + ((MonitorWorkAreaRight - MonitorWorkAreaLeft)/2) + lPadding - (yGap / 2)
        width := (MonitorWorkAreaRight - MonitorWorkAreaLeft)/2  - rPadding - (yGap / 2)
    } else {
        posX  := MonitorWorkAreaLeft + lPadding
        width := MonitorWorkAreaRight - MonitorWorkAreaLeft - lPadding - rPadding
    }

    if (winPlaceVertical == "bottom") {
        posY := MonitorWorkAreaBottom - height - bPadding
    } else if (winPlaceVertical == "middle") {
        posY := MonitorWorkAreaTop + height + tPadding + yGap
    } else {
        posY := MonitorWorkAreaTop + tPadding
    }
    
    WinMove,A,,%posX%,%posY%,%width%,%height%
}

shrinkActiveWindow(command) {
    WinGet activeWin, ID, A
    activeMon := GetMonitorIndexFromWindow(activeWin)

    SysGet, MonitorWorkArea, MonitorWorkArea, %activeMon%
    WinGetPos, posX, posY, width, height, A

    if (command == "halfbottom") {
        height := height/2
        posY := posY + height
    }
    if (command == "halftop") {
        height := height/2
    }
    if (command == "halfright") {
        width := width/2
        posX := posX + width
    }
    if (command == "halfleft") {
        width := width/2
    }
    if (command == "halftopleft") {
        height := height/2
        width := width/2
    }
    if (command == "halftopright") {
        height := height/2
        width /= 2
        posX := posX + width
    }

    WinMove,A,,%posX%,%posY%,%width%,%height%
}

max(x,y) {
    return x > y ? x : y
}

min(x,y) {
    return x < y ? x : y
}

activateWindow(num) {
    WinGet activeWin, ID, A
    activeMon := GetMonitorIndexFromWindow(activeWin)
    SysGet, MonitorWorkArea, MonitorWorkArea, %activeMon%
    CoordMode, Mouse, Screen
    Switch num {
        Case 7:
            MouseMove MonitorWorkAreaRight / 4, MonitorWorkAreaBottom / 4, 0
        Case 8:
            MouseMove MonitorWorkAreaRight / 2, MonitorWorkAreaBottom / 4, 0
        Case 9:
            MouseMove 3 * MonitorWorkAreaRight / 4, MonitorWorkAreaBottom / 4, 0
        Case 4:
            MouseMove MonitorWorkAreaRight / 4, MonitorWorkAreaBottom / 2, 0
        Case 6:
            MouseMove 3 * MonitorWorkAreaRight / 4, MonitorWorkAreaBottom / 2, 0
        Case 1:
            MouseMove MonitorWorkAreaRight / 4, 3 * MonitorWorkAreaBottom / 4, 0
        Case 2:
            MouseMove MonitorWorkAreaRight / 2, 3 * MonitorWorkAreaBottom / 4, 0
        Case 3:
            MouseMove 3 * MonitorWorkAreaRight / 4, 3 * MonitorWorkAreaBottom / 4, 0
    }
    Sleep, 100
    MouseGetPos,,, hwnd 
    WinActivate, ahk_id %hwnd%
}

moveActiveWindow(command) {
    WinGet activeWin, ID, A
    activeMon := GetMonitorIndexFromWindow(activeWin)

    SysGet, MonitorWorkArea, MonitorWorkArea, %activeMon%
     WinGetPos, posX, posY, width, height, A

   if (command == "moveup" || command == "moveupright" || command == "moveupleft") && (posY - height >= 0) {
          posY := posY - height
    }
   if (command == "movedown" || command = "movedownright" || command = "movedownleft") && (posY + height * 2 <= MonitorWorkAreaBottom) {
          posY := posY + height
    }
   if (command == "moveright" || command == "moveupright" || command == "movedownright") && (posX + width * 2 <= MonitorWorkAreaRight) {
          posX := posX + width
    }
    if (command == "moveleft" || commmand == "moveupleft" || command == "movedownleft") && (posX - height >= 0) {
          posX := posX - width
    }

    WinMove,A,,%posX%,%posY%,%width%,%height%
}

/**
 * GetMonitorIndexFromWindow retrieves the HWND (unique ID) of a given window.
 * @param {Uint} windowHandle
 * @author shinywong
 * @link http://www.autohotkey.com/board/topic/69464-how-to-determine-a-window-is-in-which-monitor/?p=440355
 */
GetMonitorIndexFromWindow(windowHandle) {
    ; Starts with 1.
    monitorIndex := 1

    VarSetCapacity(monitorInfo, 40)
    NumPut(40, monitorInfo)

    if (monitorHandle := DllCall("MonitorFromWindow", "uint", windowHandle, "uint", 0x2))
        && DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) {
        monitorLeft   := NumGet(monitorInfo,  4, "Int")
        monitorTop    := NumGet(monitorInfo,  8, "Int")
        monitorRight  := NumGet(monitorInfo, 12, "Int")
        monitorBottom := NumGet(monitorInfo, 16, "Int")
        workLeft      := NumGet(monitorInfo, 20, "Int")
        workTop       := NumGet(monitorInfo, 24, "Int")
        workRight     := NumGet(monitorInfo, 28, "Int")
        workBottom    := NumGet(monitorInfo, 32, "Int")
        isPrimary     := NumGet(monitorInfo, 36, "Int") & 1

        SysGet, monitorCount, MonitorCount

        Loop, %monitorCount% {
            SysGet, tempMon, Monitor, %A_Index%

            ; Compare location to determine the monitor index.
            if ((monitorLeft = tempMonLeft) and (monitorTop = tempMonTop)
                and (monitorRight = tempMonRight) and (monitorBottom = tempMonBottom)) {
                monitorIndex := A_Index
                break
            }
        }
    }

    return %monitorIndex%
}

; Numpad unmodified, activate corresponding window
; Numpad1::activateWindow(1)
; Numpad2::activateWindow(2)
; Numpad3::activateWindow(3)
; Numpad4::activateWindow(4)
; Numpad6::activateWindow(6)
; Numpad7::activateWindow(7)
; Numpad8::activateWindow(8)
; Numpad9::activateWindow(9)

; Win + Numpad = Snap to conrners for diagonals, or top, bottom, left, right of screen (Landscape)
#NumpadHome::
#Numpad7::SnapActiveWindow("top","left","half")
#NumpadUp::
#Numpad8::SnapActiveWindow("top","full","half")
#NumpadPgup::
#Numpad9::SnapActiveWindow("top","right","half")
#NumpadLeft::
#Numpad4::SnapActiveWindow("top","left","full")
#NumpadRight::
#Numpad6::SnapActiveWindow("top","right","full")
#NumpadEnd::
#Numpad1::SnapActiveWindow("bottom","left","half")
#NumpadDown::
#Numpad2::SnapActiveWindow("bottom","full","half")
#NumpadPgdn::
#Numpad3::SnapActiveWindow("bottom","right","half")
#NumpadClear::
#Numpad5::SnapActiveWindow("full","full","full")

; ; Ctrl + Alt + Win + keypad = split off Chrome or Edge tab and move to new window
; #If WinActive("ahk_exe chrome.exe") || WinActive("ahk_exe msedge.exe")
; ^#!Numpad7::SplitSnapActiveWindow("top","left","half")
; ^#!Numpad8::SplitSnapActiveWindow("top","full","half")
; ^#!Numpad9::SplitSnapActiveWindow("top","right","half")
; ^#!Numpad4::SplitSnapActiveWindow("top","left","full")
; ^#!Numpad6::SplitSnapActiveWindow("top","right","full")
; ^#!Numpad1::SplitSnapActiveWindow("bottom","left","half")
; ^#!Numpad2::SplitSnapActiveWindow("bottom","full","half")
; ^#!Numpad3::SplitSnapActiveWindow("bottom","right","half")
; #IfWinActive

; Shrink with Windows+Alt num pad
#!NumpadHome::
#!Numpad7::shrinkActiveWindow("halftopleft")
#!NumpadUp::
#!Numpad8::shrinkActiveWindow("halftop")
#!NumpadPgup::
#!Numpad9::shrinkActiveWindow("halftopright")
#!NumpadLeft::
#!Numpad4::shrinkActiveWindow("halfleft")
#!NumpadRight::
#!Numpad6::shrinkActiveWindow("halfright")
#!NumpadEnd::
#!Numpad1::shrinkActiveWindow("halfbottomleft")
#!NumpadDown::
#!Numpad2::shrinkActiveWindow("halfbottom")
#!NumpadPgdn::
#!Numpad3::shrinkActiveWindow("halfbottomright")

; #!Up::shrinkActiveWindow("halftop")
; #!Down::shrinkActiveWindow("halfbottom")
; #!Left::shrinkActiveWindow("halfleft")
; #!Right::shrinkActiveWindow("halfright")

; Scoot windows around the screen with ctrl+win number pad
; ^#NumpadHome::
; ^#Numpad7::moveActiveWindow("moveupleft")
; ^#NumpadUp::
; ^#Numpad8::moveActiveWindow("moveup")
; ^#NumpadPgup::
; ^#Numpad9::moveActiveWindow("moveupright")
; ^#NumpadLeft::
; ^#Numpad4::moveActiveWindow("moveleft")
; ^#NumpadRight::
; ^#Numpad6::moveActiveWindow("moveright")
; ^#NumpadEnd::
; ^#Numpad1::moveActiveWindow("movedownleft")
; ^#NumpadDown::
; ^#Numpad2::moveActiveWindow("movedown")
; ^#NumpadPgdn::
; ^#Numpad3::moveActiveWindow("movedownright")

; ^#Up::moveActiveWindow("moveup")
; ^#Down::moveActiveWindow("movedown")
; ^#Left::moveActiveWindow("moveleft")
; ^#Right::moveActiveWindow("moveright")