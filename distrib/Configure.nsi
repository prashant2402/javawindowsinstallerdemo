; Configure.nsi
;
; This script creates a windows installer 'Configure.exe' which will be included by main Setup script 
;'Setup.nsi' while generating the deliverable for the user. 
; Instructions to developers:
;->Update PRODUCT_VERSION with the correct version of the release
;->Execute Configure.nsi script before running Setup.nsi script as Setup depends on the Configure.exe file.
;======================================================
; Include
!include MUI.nsh
!include InstallOptions.nsh
!include Sections.nsh
!include TextFunc.nsh
!include StrRep.nsh
!include StrContains.nsh
;======================================================
 ;Language strings
LangString TEXT_IO_TITLE ${LANG_ENGLISH} "Configuration page"
LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "This page will update application configuration based on input values given on this page."
LangString DESC_UpdateConfig ${LANG_ENGLISH} "This will update configuration for the existing installation."
LangString TEXT_CONFIG_TITLE ${LANG_ENGLISH} "Configuring the application"
LangString TEXT_CONFIG_SUBTITLE ${LANG_ENGLISH} "please wait..."
LangString TEXT_FINISH_TITLE ${LANG_ENGLISH} "Completed configuring the application. $\r$\n$\r$\n$\r$\nClick Finish to close the wizard."
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
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
;======================================================
; Pages
;======================================================
;custom page configuration  
Page custom showExistingCustomerConfig

!define MUI_PAGE_CUSTOMFUNCTION_SHOW preINSTFILES
; Instfiles page 
!insertmacro MUI_PAGE_INSTFILES
!define MUI_TEXT_FINISH_INFO_TEXT $(TEXT_FINISH_TITLE)
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
Caption '${PRODUCT_NAME} ${PRODUCT_VERSION} Configuration'
OutFile "..\Configure.exe"
InstallDir "C:\temp\javawindowsinstallerdemo"
InstallButtonText "Next >"
XpStyle on
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
 
Section "Update configuration for the exisiting installation" updateConfigSection

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
  StrCmp $varPreviousVersion "" lbl_noprev lbl_prevdone
 
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
 
 
  lbl_prevdone:
  
  Call parseConfig
  
   ; Save the config files into a temp directory
  CreateDirectory "C:\Temp3141592"
  CopyFiles "$INSTDIR\config\application.properties" "C:\Temp3141592\application.properties"

 SetOutPath $INSTDIR
  File /r "..\target\javawindowsinstallerdemo.exe"
  
; Put the config files back in their places and delete the temp directory
  CopyFiles "C:\Temp3141592\application.properties" "$INSTDIR\config\application.properties"
  RMDir /r "C:\Temp3141592"

  ;Call killJava

  Call startApp
  
SectionEnd

;======================================================
;Descriptions
 
;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${updateConfigSection} $(DESC_UpdateConfig)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;======================================================
; Functions
 
Function .onInit
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "customerConfig.ini"
FunctionEnd

;==============================================================
; Custom screen functions

;replace single slash if there is not already a double slash, useful for file paths
Function parseConfig
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

Function showExistingCustomerConfig
   !insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE)" "$(TEXT_IO_SUBTITLE)"

   ${ConfigRead} "$INSTDIR\config\application.properties" "property.one=" $varProp1 
   !insertmacro MUI_INSTALLOPTIONS_WRITE "customerConfig.ini" "Field 3" "State" $varProp1

   ${ConfigRead} "$INSTDIR\config\application.properties" "property.two=" $varProp2
   !insertmacro MUI_INSTALLOPTIONS_WRITE "customerConfig.ini" "Field 5" "State" $varProp2

   ${ConfigRead} "$INSTDIR\config\application.properties" "property.three=" $varProp3
   !insertmacro MUI_INSTALLOPTIONS_WRITE "customerConfig.ini" "Field 7" "State" $varProp3

   ${ConfigRead} "$INSTDIR\config\application.properties" "property.four=" $varProp4 
   !insertmacro MUI_INSTALLOPTIONS_WRITE "customerConfig.ini" "Field 9" "State" $varProp4

   ${ConfigRead} "$INSTDIR\config\application.properties" "property.five=" $varProp5 
   !insertmacro MUI_INSTALLOPTIONS_WRITE "customerConfig.ini" "Field 11" "State" $varProp5
   
   !insertmacro MUI_INSTALLOPTIONS_DISPLAY "customerConfig.ini"
   
   !insertmacro MUI_INSTALLOPTIONS_READ $varProp1 "customerConfig.ini" "Field 3" "State"
   !insertmacro MUI_INSTALLOPTIONS_READ $varProp2 "customerConfig.ini" "Field 5" "State"
   !insertmacro MUI_INSTALLOPTIONS_READ $varProp3 "customerConfig.ini" "Field 7" "State"
   !insertmacro MUI_INSTALLOPTIONS_READ $varProp4 "customerConfig.ini" "Field 9" "State"
   !insertmacro MUI_INSTALLOPTIONS_READ $varProp5 "customerConfig.ini" "Field 11" "State"
 
FunctionEnd
 
Function preINSTFILES
   !insertmacro MUI_HEADER_TEXT "$(TEXT_CONFIG_TITLE)" "$(TEXT_CONFIG_SUBTITLE)"
FunctionEnd

Function killJava
   KillProcWMI::KillProc "javaw.exe"
   sleep 1500
FunctionEnd

Function startApp
    Exec "$INSTDIR\javawindowsinstallerdemo.exe"
FunctionEnd
