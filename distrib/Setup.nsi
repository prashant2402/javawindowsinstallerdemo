; Setup.nsi
;
; This script creates a windows setup installer with two modes of operation: 
;1. Full Installation - Copies application files, shows configuration options, add shortcuts and starts the application
;2. Patch Installation - Copies application files, kills any running java applications and starts the application again.
; Instructions to developers:
;->Update PRODUCT_VERSION with the correct version of the release
;->Execute Configure.nsi script before running this script as Setup depends on the Configure.exe file.
;->The output file 'Setup.exe' is generated in main project folder, that would be the only deliverable to be released to the end user.
;======================================================
; Include
!include MUI.nsh
!include LogicLib.nsh
!include InstallOptions.nsh
!include Sections.nsh
!include RemoveFilesAndSubDirs.nsh
!include TextFunc.nsh
!include StrRep.nsh
!include StrContains.nsh
!include x64.nsh
;======================================================
 ;Language strings
LangString TEXT_IO_TITLE ${LANG_ENGLISH} "Configuration page"
LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "This page will update application configuration based on input values given on this page."
LangString DESC_SETUPTYPE_TOP ${LANG_ENGLISH} "Check the type of setup you want to select. Click Next to continue."
LangString DESC_SETUPTYPE_LEFT ${LANG_ENGLISH} "Select type of setup"
LangString DESC_InstallFull ${LANG_ENGLISH} "This will install a full application. PLEASE NOTE: This will delete any existing install."
LangString DESC_InstallPatch ${LANG_ENGLISH} "This will install a patch to an existing application."
LangString DESC_UpdateConfig ${LANG_ENGLISH} "This will update configuration for the existing installation."
;======================================================
; helper defines
!define PRODUCT_NAME "Java Windows Installer Demo"
!define PRODUCT_VERSION "1.0.0"
!define PRODUCT_PUBLISHER "Java Windows Installer Demo"
;======================================================
  
; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "Are you sure you want to cancel this installation?"
!define MUI_HEADERIMAGE
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
!define MUI_COMPONENTSPAGE_TEXT_TOP $(DESC_SETUPTYPE_TOP)
!define MUI_COMPONENTSPAGE_TEXT_COMPLIST $(DESC_SETUPTYPE_LEFT)

;======================================================
; Pages
;======================================================
; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
;!insertmacro MUI_PAGE_LICENSE "license.txt"
; Components page
!insertmacro MUI_PAGE_COMPONENTS  
;function to check if dir page to be skipped  
!define MUI_PAGE_CUSTOMFUNCTION_PRE DirPage_Pre
; Directory page 
!insertmacro MUI_PAGE_DIRECTORY
;custom page configuration  
Page custom customerConfig
; Instfiles page 
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH
;======================================================
; Languages
 
!insertmacro MUI_LANGUAGE "English"
;======================================================

; Reserve Files
 
ReserveFile "customerConfig.ini"
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
;======================================================

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "../javawindowsinstallerdemo-${PRODUCT_VERSION}.exe"
InstallDir "C:\temp\javawindowsinstallerdemo"
ShowInstDetails show
ShowUninstDetails hide
;======================================================
; Variables
var varProp1
var varProp2
var varProp3
var varProp4
var varProp5
var varPreviousVersion
 
;======================================================
; Sections
 
Section "Install a full application" fullInstallSection
  ; Version checking logic
  ; This will send out a warning if the same version is already installed
  ; Open the file and assign it the handle $R8
  FileOpen $R8 "$INSTDIR\config\version.txt" r
  ; Go to position 0 on the first line of the file
  FileSeek $R8 0
  ; Read from there until the end of the line and copy to the variable
  FileRead $R8 $varPreviousVersion
  ; If the variable is empty (which will mean the file is not there in this case
  ; go to lbl_noprev. Otherwise go to lbl_prev
  StrCmp $varPreviousVersion "" lbl_noprev lbl_prev
 
  lbl_noprev:
  ; Close the file (otherwise you'll have some problems during the copying of
  ; files that override the version.txt file
  FileClose $R8
  GoTo lbl_prevdone
 
  lbl_prev:
  ;MessageBox MB_OK "Previous version: $varPreviousVersion"
  ; Close the file (otherwise you'll have some problems during the copying of
  ; files that override the version.txt file
  FileClose $R8
  ; If the variable is equal to ${PRODUCT_VERSION}, which is the version of this installer,
  ; go to lbl_warn, otherwise for to lbl_prevdone
  StrCmp $varPreviousVersion ${PRODUCT_VERSION} lbl_warn lbl_del
 
      lbl_warn:
      ; Ask confirmation to user that they want to install ${PRODUCT_VERSION} even though they
      ; already have it installed. If they click OK, go to lbl_prevdone, if they click
      ; Cancel, go to lbl_ABORT
      MessageBox MB_OKCANCEL|MB_ICONQUESTION "Existing install is the same version as this installer. The existing install will be removed. Do you want to continue?" IDOK lbl_prevdone IDCANCEL lbl_ABORT
 
             lbl_ABORT:
             ; Abort the install
             ABORT
             GoTo lbl_del
 
            lbl_del:
            ExecWait '"$INSTDIR\uninstaller.exe" /S _?=$INSTDIR'
            ;!insertmacro RemoveFilesAndSubDirs "$INSTDIR\"
            GoTo lbl_prevdone
 
  lbl_prevdone:
 
 SetOutPath $INSTDIR\config
 File /r "..\distrib\application.properties"
 File /r "..\distrib\version.txt"
 SetOutPath $INSTDIR
 File /r "..\target\javawindowsinstallerdemo.exe"
 File /r "..\Configure.exe"

 ;create shortcut only GUI is enabled
 ;StrCmp $varGui "Yes" 0 +2
 ;CreateShortcut "$desktop\javawindowsinstallerdemo.lnk" "$instdir\javawindowsinstallerdemo.exe"
 
 Call parseConfig
 
 CreateShortcut "$SMStartup\javawindowsinstallerdemo.lnk" "$instdir\javawindowsinstallerdemo.exe"
 
 ;Useful if there any DLL related differences to be aware of between 32/64 bit windows 
   ${If} ${RunningX64}
    # 64 bit code
    #MessageBox MB_OK "running on x64"
  ${Else}
    # 32 bit code 
    #MessageBox MB_OK "running on x32"   
  ${EndIf} 
 
 # define uninstaller name
 WriteUninstaller $INSTDIR\uninstaller.exe
 
 ;Call killJava
 
 Call startApp

 
SectionEnd
 
Section /o "Install a Patch to an existing application" installPatchSection
  ; Version checking logic
  ; This will send out a warning if the same version is already installed
  ; and abort if there is no previous version
  ; Open the file and assign it the handle $R8
  FileOpen $R8 "$INSTDIR\config\version.txt" r
  ; Go to position 11 on the first line of the file
  FileSeek $R8 0
  ; Read from there until the end of the line and copy to the variable
  FileRead $R8 $varPreviousVersion
  ; If the variable is empty (which will mean the file is not there in this case
  ; go to lbl_noprev. Otherwise go to lbl_prev
  StrCmp $varPreviousVersion "" lbl_noprev lbl_prev
 
  lbl_noprev:
  ; The variable is empty, meaning either the previous install was corrupt or the file wasn't
  ; there, which means they need to do a full install, not just a patch install
  MessageBox MB_OK "No previous version detected. You need to perform a full install"
  ; Close the file (otherwise you'll have some problems during the copying of
  ; files that override the version.txt file
  FileClose $R8
  ; Abort the install
  ABORT
  GoTo lbl_prevdone
 
  lbl_prev:
  ;MessageBox MB_OK "Previous version of app: $varPreviousVersion"
  ; Close the file (otherwise you'll have some problems during the copying of
  ; files that override the version.txt file
  FileClose $R8
  ; If the variable is equal to ${PRODUCT_VERSION}, which is the version of this installer,
  ; go to next command (the message box), otherwise for to two commands down (or the CreateDirectory)
  StrCmp $varPreviousVersion "${PRODUCT_VERSION}" "+1" "+2"
  ; Ask confirmation to user that they want to install ${PRODUCT_VERSION} even though they
  ; already have it installed. If they click OK, go to lbl_prevdone, if they click
  ; Cancel, go to lbl_ABORT
  MessageBox MB_OKCANCEL|MB_ICONQUESTION "Existing install is the same version as this installer. Do you want to continue?" IDOK lbl_prevdone IDCANCEL lbl_ABORT
 
          lbl_ABORT:
          ; Abort the install
          ABORT
          GoTo lbl_prevdone
 
  lbl_prevdone:
 
  ; Save the config files into a temp directory
  CreateDirectory "C:\Temp3141592"
  CopyFiles "$INSTDIR\config\application.properties" "C:\Temp3141592\application.properties"
  
  ; Perform the actual install
  SetOutPath $INSTDIR
  File /r "..\target\javawindowsinstallerdemo.exe"
  File /r "..\Configure.exe"
  
  ; Put the config files back in their places and delete the temp directory
  CopyFiles "C:\Temp3141592\application.properties" "$INSTDIR\config\application.properties"
  
  RMDir /r "C:\Temp3141592"
  

  ;Call killJava

  Call startApp

SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"
SetAutoClose true

 ;Call un.killJava

 !insertmacro RemoveFilesAndSubDirs "$INSTDIR\"
  
 Delete "$desktop\javawindowsinstallerdemo.lnk"
 
 Delete "$SMSTARTUP\javawindowsinstallerdemo.lnk"

SectionEnd

;======================================================
;Descriptions
 
;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${fullInstallSection} $(DESC_InstallFull)
  !insertmacro MUI_DESCRIPTION_TEXT ${installPatchSection} $(DESC_InstallPatch)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;======================================================
; Functions
 
Function .onInit
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "customerConfig.ini"
  StrCpy $1 ${fullInstallSection}  
FunctionEnd

Function .onSelChange
  !insertmacro StartRadioButtons $1
  !insertmacro RadioButton ${fullInstallSection}
  !insertmacro RadioButton ${installPatchSection}
  !insertmacro EndRadioButtons
FunctionEnd

;==============================================================
; Custom screen functions

Function DirPage_Pre
  Push $0
  SectionGetFlags ${fullInstallSection} $0
  StrCmp $0 ${SF_SELECTED} noskip 0

  SectionGetFlags ${installPatchSection} $0
  StrCmp $0 ${SF_SELECTED} skip 0

  noskip:
      GOTO done
      
  skip:
      ABORT
      
  done:
FunctionEnd

Function parseConfig
;replace single if there is not already a double slash
StrCpy '$9' $varProp1
${StrContains} $0 '\\' $varProp1
StrCmp $0 "" toDouble
  Goto done
toDouble:
    ${StrRep} $9 $varProp1 '\' '\\'
done:
 ${ConfigWrite} "$INSTDIR\config\application.properties" "property.one=" $9 $R0
 ${ConfigWrite} "$INSTDIR\config\application.properties" "property.two=" $varProp2 $R0
 ${ConfigWrite} "$INSTDIR\config\application.properties" "property.three=" $varProp3 $R0
 ${ConfigWrite} "$INSTDIR\config\application.properties" "property.four=" $varProp4 $R0
 ${ConfigWrite} "$INSTDIR\config\application.properties" "property.five=" $varProp5 $R0
FunctionEnd

Function customerConfig
 Push $0
      SectionGetFlags ${fullInstallSection} $0
      StrCmp $0 ${SF_SELECTED} callShowConfig 0
      
      Abort
      Goto noConfig
      
      callShowConfig:
       Call showCustomerConfig
       Goto noConfig
      
      noConfig:
 Pop $0
      
FunctionEnd
 
Function showCustomerConfig
  !insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE)" "$(TEXT_IO_SUBTITLE)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "customerConfig.ini"
  !insertmacro MUI_INSTALLOPTIONS_READ $varProp1 "customerConfig.ini" "Field 3" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $varProp2 "customerConfig.ini" "Field 5" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $varProp3 "customerConfig.ini" "Field 7" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $varProp4 "customerConfig.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $varProp5 "customerConfig.ini" "Field 11" "State"
  
FunctionEnd

Function killJava
   KillProcWMI::KillProc "javaw.exe"
   sleep 1500
FunctionEnd

Function un.killJava
   KillProcWMI::KillProc "javaw.exe"
   sleep 1500
FunctionEnd

Function startApp
    Exec "$INSTDIR\javawindowsinstallerdemo.exe"
    SetRebootFlag true
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?$\r$\nPlease ensure you have close all Java applications as the uninstaller will automatically shutdown any running Java processes." IDYES +2
  Abort
FunctionEnd

