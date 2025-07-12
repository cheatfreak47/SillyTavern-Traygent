#NoEnv
SetWorkingDir %A_ScriptDir%
; Selfbuild stuff
if (!A_IsCompiled) {
	; Checks to see if the script was ran with --build. If so, it performs the Build tasks near the bottom of the script.
	Loop, % A_Args.Length()
	{
		if (A_Args[A_Index] = "--build") {
			goto Build
		}
		break
	}
	MsgBox, 16, Error, This script must be run as a compiled .exe, not as a .ahk script. Running the script directly with --build will allow you to compile the script automatically.
    ExitApp
}

; We check if the script is running already in case we're a second instance. If we are, we just open the page and exit!
DetectHiddenWindows, On
if WinExist("SillyTavernTraygent ahk_class AutoHotkey") {
    Run, http://127.0.0.1:8000
    ExitApp
}
; This is what tips us off earlier in the script that there's another instance.
WinSetTitle, ahk_class AutoHotkey, , SillyTavernTraygent
; Just in case that doesn't work, we fall back on standard detection
#SingleInstance Force

; Set the Tray tooltip
Menu, Tray, Tip, SillyTavern

; Add menu Tray items
Menu, Tray, NoStandard ; Remove all default items
Menu, Tray, Add, SillyTavern Traygent, HandlerLabel
Menu, Tray, Disable, SillyTavern Traygent ; Gray out an item
Menu, Tray, Add ; Adds a separator line
Menu, Tray, Add, Open, HandlerOpen
Menu, Tray, Add, Restart, HandlerRestart
Menu, Tray, Add, Exit, HandlerExit
Menu, Tray, Default, Open ; Makes double-click open the server

OnExit("TerminationProtocol")

; actually call the Start.bat file
MainLogic:
if !FileExist("Start.bat") {
    MsgBox, 16, Error, Start.bat not found!
    ExitApp
}

RunWait, "Start.bat", , Hide, PID
;In the event that the server dies but our script doesn't... we will probably just terminate too, so that's what this is.
ExitApp

HandlerOpen:
    ; Your open action here
    Run, http://127.0.0.1:8000
return

HandlerLabel:
return

HandlerRestart:
	TerminationProtocol()
	goto MainLogic
return

HandlerExit:
    ExitApp
return

TerminationProtocol() {
    global PID
    if (PID) {
        RunWait, taskkill /pid %PID% /f /t, , Hide
    }
    return
}
ExitApp

; more selfbuild stuff
Build:
	; Try to read the install location of AutoHotKey 1.1 from the 64-bit registry path
	RegRead, InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\AutoHotkey, InstallDir
	; If the above registry path doesn't exist (i.e., on a 32-bit machine), try the 32-bit registry path
	if (ErrorLevel) {
		RegRead, InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
	}
	; If the install location of AutoHotKey 1.1 is still not found, show an error message
	if (ErrorLevel) {
		MsgBox, 48, Error, AutoHotkey installation location not found in the registry.
		ExitApp
	}
	; Try to build with an icon if it exists.
	ScriptName := SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".",, 0) - 1)
	if FileExist(ScriptName . .ico) {
	RunWait, "%InstallDir%\Compiler\ahk2exe.exe" /in "%A_ScriptFullPath%" /out "%A_WorkingDir%\%ScriptName%.exe" /icon "%ScriptName%.ico"
	}
	else {
	RunWait, "%InstallDir%\Compiler\ahk2exe.exe" /in "%A_ScriptFullPath%" /out "%A_WorkingDir%\%ScriptName%.exe"
	}
	MsgBox, 64, Information, Compiled script.
	ExitApp