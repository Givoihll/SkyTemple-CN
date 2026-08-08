!include LogicLib.nsh

!define PRODUCT_NAME "SkyTemple CN"
!define PRODUCT_VERSION "1.8.4"
!define APPEXE "skytemple.exe"
!define PRODUCT_ICON "skytemple.ico"

SetCompressor lzma
!define FILES_SOURCE_PATH "dist\skytemple"
RequestExecutionLevel user

; Modern UI
!include "MUI2.nsh"
!define MUI_ABORTWARNING
!define MUI_WELCOMEFINISHPAGE_BITMAP "modern-wizard.bmp"
!define MUI_ICON "${PRODUCT_ICON}"
Icon "${PRODUCT_ICON}"
BrandingText "${PRODUCT_NAME}"

; UI pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "..\..\SkyTemple_CN_Setup.exe"
InstallDir "$LOCALAPPDATA\${PRODUCT_NAME}"
ShowInstDetails show

Function UninstallPrevious
    ReadRegStr $R0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString"
    ${If} $R0 == ""
        Goto Done
    ${EndIf}
    DetailPrint "Removing previous installation..."
    ExecShellWait "open" "$R0" "/S" SW_HIDE
    Sleep 5000
    Done:
FunctionEnd

Section "" SecUninstallPrevious
    Call UninstallPrevious
SectionEnd

Section "Install"
    DetailPrint "Installing ${PRODUCT_NAME}..."
    !include install_files.nsh
    SetOutPath "$INSTDIR"
    File "${PRODUCT_ICON}"

    CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\${APPEXE}" "" "$INSTDIR\${PRODUCT_ICON}"
    CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${APPEXE}" "" "$INSTDIR\${PRODUCT_ICON}"

    WriteUninstaller "$INSTDIR\uninstall.exe"

    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                     "DisplayName" "${PRODUCT_NAME} ${PRODUCT_VERSION}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                     "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                     "InstallLocation" "$INSTDIR"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                     "DisplayIcon" "$INSTDIR\${PRODUCT_ICON}"
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                     "NoModify" 1
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                     "NoRepair" 1
SectionEnd

Section "Uninstall"
    Delete "$INSTDIR\${PRODUCT_ICON}"
    Delete "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk"
    RMDir "$SMPROGRAMS\${PRODUCT_NAME}"
    Delete "$DESKTOP\${PRODUCT_NAME}.lnk"

    !include uninstall_files.nsh

    Delete "$INSTDIR\uninstall.exe"
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
SectionEnd