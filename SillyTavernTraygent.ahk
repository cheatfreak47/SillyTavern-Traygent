#NoEnv
SetWorkingDir %A_ScriptDir%
; ================ SELF BUILDING CHECK ================
if (!A_IsCompiled) {
	; Checks to see if the script was ran with --build. If so, it performs the Build tasks near the bottom of the script.
	; Else, through error.
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

; ===================== READ PORT =====================
FileRead, config, config.yaml
if RegExMatch(config, "port:\s*\K\d+", match) {
    port := match  ; Legacy-style access for AHK v1.1
} else {
    MsgBox, 16, Error, Port could not be read from config.yaml.
	ExitApp
}

; ============ SINGLE INSTANCE ENFORCEMENT ============
DetectHiddenWindows, On
; We check if another window with our class exists yet, if it does, we are a second instance.
if WinExist("SillyTavernTraygent ahk_class AutoHotkey") {
    Run, http://127.0.0.1:%port%
    ExitApp
}
; If we're not, we set our class so any future second instances will be caught.
WinSetTitle, ahk_class AutoHotkey, , SillyTavernTraygent
; In the event something is missed we fallback on forced SingleInstance mode.
#SingleInstance Force


; ================== BUILD TRAY MENU ==================
Menu, Tray, Tip, SillyTavern ; Tooltip
Menu, Tray, NoStandard ; Remove all default items
Menu, Tray, Add, SillyTavern Traygent, DoNothing ; Tray label, Dummy functionality
Menu, Tray, Disable, SillyTavern Traygent ; Disable it so it's not clickable
Menu, Tray, Add ; Adds a separator line
Menu, Tray, Add, Open, HandlerOpen ; Open SillyTavern in browser
Menu, Tray, Add, Restart, HandlerRestart ; Restart Server
Menu, Tray, Add, Update, HandlerUpdate ; Git Pull the latest SillyTavern Server
Menu, Tray, Add, Toggle Console, HandlerConsoleToggle ; Toggle Console Window visibilty
Menu, Tray, Add, Exit, HandlerExit ; Close server and exit the tray agent
Menu, Tray, Default, Open ; Double click the icon also opens SillyTavern in the browser

; ================== MAIN OPERATION ===================
OnExit("TerminationProtocol") ; When the script exits it should terminate the server.

MainLogic:
; Make sure user isn't an idiot
if !FileExist("Start.bat") {
    MsgBox, 16, Error, Start.bat not found!
    ExitApp
}
; We track console visibility to control it via tray icon
cmdVisible := false
RunWait, "Start.bat", , Hide, PID

; This code only gets ran if the server is killed, crashes, or is closed by the user closing the console window.
MsgBox, 16, Error, SillyTavern Server Unexpectedly Closed.`nRestarting server...
goto MainLogic

; =================== TRAY FUNCTIONS ==================
HandlerOpen:
    Run, http://127.0.0.1:%port% ; Open the server in browser
return

DoNothing:
 ; Do... nothing! Spooky.
return

HandlerRestart:
	TerminationProtocol() ; Terminate server
	goto MainLogic ; Restart server
return

HandlerUpdate:
	TerminationProtocol() ; Terminate server
	RunWait, "cmd.exe" /c git pull, , Hide ; Update server
	goto MainLogic ; Restart server
return

HandlerConsoleToggle:
    If (cmdVisible) {
        WinHide, ahk_pid %PID% ; hide the console
        cmdVisible := false ; mark it as hidden
    } else {
        WinShow, ahk_pid %PID% ; show the console 
        WinActivate, ahk_pid %PID% ; foreground it
        cmdVisible := true ; mark it as visible
    }
return

HandlerExit:
    ExitApp
return

; ====================== FUNCTIONS ====================
TerminationProtocol() {
    global PID ; makes PID a global var so it can be read from other threads
    if (PID) {
        RunWait, taskkill /pid %PID% /f /t, , Hide ; BODYSLAM THE SERVER BABY
    }
    return
}

; =================== BUILD SECTION ===================
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