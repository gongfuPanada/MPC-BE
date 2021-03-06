@ECHO OFF
REM $Id$
REM
REM (C) 2009-2013 see Authors.txt
REM
REM This file is part of MPC-BE.
REM
REM MPC-BE is free software; you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation; either version 3 of the License, or
REM (at your option) any later version.
REM
REM MPC-BE is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with this program.  If not, see <http://www.gnu.org/licenses/>.

SETLOCAL
CD /D %~dp0

IF EXIST "..\..\..\build.user.bat" (
  CALL ..\..\..\build.user.bat
)

REM pre-build checks

  IF DEFINED MINGW32 (SET MPCBE_MINGW32=%MINGW32%) ELSE (GOTO MissingVar)
  IF DEFINED MINGW64 (SET MPCBE_MINGW64=%MINGW64%) ELSE (GOTO MissingVar)
  IF DEFINED MSYS    (SET MPCBE_MSYS=%MSYS%)       ELSE (GOTO MissingVar)

IF NOT DEFINED VS100COMNTOOLS GOTO MissingVar

SET ARG=%*
SET ARG=%ARG:/=%
SET ARG=%ARG:-=%
SET ARGB=0
SET ARGBC=0
SET ARGC=0
SET ARGCL=0
SET ARGD=0
SET ARGF=0
SET ARGM=0
SET ARGPL=0
SET ARGPA=0
SET ARGIN=0
SET ARGZI=0
SET INPUT=0
SET ARGVS=0

IF /I "%ARG%" == "?"          GOTO ShowHelp

FOR %%A IN (%ARG%) DO (
  IF /I "%%A" == "help"       GOTO ShowHelp
  IF /I "%%A" == "GetVersion" ENDLOCAL & CALL :SubGetVersion & EXIT /B
  IF /I "%%A" == "Build"      SET "BUILDTYPE=Build"   & SET /A ARGB+=1
  IF /I "%%A" == "Clean"      SET "BUILDTYPE=Clean"   & SET /A ARGB+=1  & SET /A ARGCL+=1
  IF /I "%%A" == "Rebuild"    SET "BUILDTYPE=Rebuild" & SET /A ARGB+=1
  IF /I "%%A" == "Both"       SET "PLATFORM=Both"     & SET /A ARGPL+=1
  IF /I "%%A" == "Win32"      SET "PLATFORM=Win32"    & SET /A ARGPL+=1
  IF /I "%%A" == "x86"        SET "PLATFORM=Win32"    & SET /A ARGPL+=1
  IF /I "%%A" == "x64"        SET "PLATFORM=x64"      & SET /A ARGPL+=1
  IF /I "%%A" == "All"        SET "CONFIG=All"        & SET /A ARGC+=1
  IF /I "%%A" == "Main"       SET "CONFIG=Main"       & SET /A ARGC+=1  & SET /A ARGM+=1
  IF /I "%%A" == "Filters"    SET "CONFIG=Filters"    & SET /A ARGC+=1  & SET /A ARGF+=1
  IF /I "%%A" == "MPCBE"      SET "CONFIG=MPCBE"      & SET /A ARGC+=1
  IF /I "%%A" == "MPC-BE"     SET "CONFIG=MPCBE"      & SET /A ARGC+=1
  IF /I "%%A" == "Resource"   SET "CONFIG=Resources"  & SET /A ARGC+=1  & SET /A ARGD+=1
  IF /I "%%A" == "Resources"  SET "CONFIG=Resources"  & SET /A ARGC+=1  & SET /A ARGD+=1
  IF /I "%%A" == "Debug"      SET "BUILDCFG=Debug"    & SET /A ARGBC+=1 & SET /A ARGD+=1
  IF /I "%%A" == "Release"    SET "BUILDCFG=Release"  & SET /A ARGBC+=1
  IF /I "%%A" == "Packages"   SET "PACKAGES=True"     & SET /A ARGPA+=1 & SET /A ARGCL+=1 & SET /A ARGD+=1 & SET /A ARGF+=1 & SET /A ARGM+=1
  IF /I "%%A" == "Installer"  SET "INSTALLER=True"    & SET /A ARGIN+=1 & SET /A ARGCL+=1 & SET /A ARGD+=1 & SET /A ARGF+=1 & SET /A ARGM+=1
  IF /I "%%A" == "Zip"        SET "ZIP=True"          & SET /A ARGZI+=1 & SET /A ARGCL+=1 & SET /A ARGM+=1
  IF /I "%%A" == "VS2010" (
    SET SLN=
    SET BUILD=VS2010
    SET "VSCOMNTOOLS=%VS100COMNTOOLS%"
  ) & SET /A ARGVS+=1
  IF /I "%%A" == "VS2012" (
    SET SLN=_2012
    SET BUILD=VS2012
    SET "VSCOMNTOOLS=%VS110COMNTOOLS%"
  ) & SET /A ARGVS+=1
)

REM pre-build checks

  IF DEFINED MINGW32 (SET MPCBE_MINGW32=%MINGW32%) ELSE (GOTO MissingVar)
  IF DEFINED MINGW64 (SET MPCBE_MINGW64=%MINGW64%) ELSE (GOTO MissingVar)
  IF DEFINED MSYS    (SET MPCBE_MSYS=%MSYS%)       ELSE (GOTO MissingVar)

IF NOT DEFINED VSCOMNTOOLS GOTO MissingVar

FOR %%X IN (%*) DO SET /A INPUT+=1
SET /A VALID=%ARGB%+%ARGPL%+%ARGC%+%ARGBC%+%ARGPA%+%ARGIN%+%ARGZI%+%ARGVS%

IF %VALID% NEQ %INPUT% GOTO UnsupportedSwitch

IF %ARGB%  GTR 1 (GOTO UnsupportedSwitch) ELSE IF %ARGB% == 0  (SET "BUILDTYPE=Build")
IF %ARGPL% GTR 1 (GOTO UnsupportedSwitch) ELSE IF %ARGPL% == 0 (SET "PLATFORM=Both")
IF %ARGC%  GTR 1 (GOTO UnsupportedSwitch) ELSE IF %ARGC% == 0  (SET "CONFIG=MPCBE")
IF %ARGBC% GTR 1 (GOTO UnsupportedSwitch) ELSE IF %ARGBC% == 0 (SET "BUILDCFG=Release")
IF %ARGPA% GTR 1 (GOTO UnsupportedSwitch) ELSE IF %ARGPA% == 0 (SET "PACKAGES=False")
IF %ARGIN% GTR 1 (GOTO UnsupportedSwitch) ELSE IF %ARGIN% == 0 (SET "INSTALLER=False")
IF %ARGZI% GTR 1 (GOTO UnsupportedSwitch) ELSE IF %ARGZI% == 0 (SET "ZIP=False")
IF %ARGCL% GTR 1 (GOTO UnsupportedSwitch)
IF %ARGD%  GTR 1 (GOTO UnsupportedSwitch)
IF %ARGF%  GTR 1 (GOTO UnsupportedSwitch)
IF %ARGM%  GTR 1 (GOTO UnsupportedSwitch)
IF %ARGVS% GTR 1 (GOTO UnsupportedSwitch)

IF /I "%PACKAGES%" == "True" SET "INSTALLER=True" & SET "ZIP=True"

:Start
REM Check if the %LOG_DIR% folder exists otherwise MSBuild will fail
SET "LOG_DIR=bin\logs"
IF NOT EXIST "%LOG_DIR%" MD "%LOG_DIR%"

CALL :SubDetectWinArch

SET "MSBUILD=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"
SET "MSBUILD_SWITCHES=/nologo /consoleloggerparameters:Verbosity=minimal /maxcpucount /nodeReuse:true"

SET START_TIME=%TIME%
SET START_DATE=%DATE%

IF /I "%PLATFORM%" == "Win32" (GOTO Win32) ELSE IF /I "%PLATFORM%" == "x64" (GOTO x64)

:Win32
CALL "%VSCOMNTOOLS%..\..\VC\vcvarsall.bat" x86

IF /I "%CONFIG%" == "Filters" (
  CALL :SubFilters Win32
  IF /I "%ZIP%" == "True" CALL :SubCreatePackages Filters Win32
  GOTO x64
)

IF /I "%CONFIG%" == "Resources" CALL :SubResources Win32 && GOTO x64

CALL :SubMPCBE Win32

IF /I "%CONFIG%" == "Main" GOTO x64

CALL :SubResources Win32

IF /I "%INSTALLER%" == "True" CALL :SubCreateInstaller Win32
IF /I "%ZIP%" == "True"       CALL :SubCreatePackages MPC-BE Win32

IF /I "%CONFIG%" == "All" (
  CALL :SubFilters Win32
  IF /I "%ZIP%" == "True" CALL :SubCreatePackages Filters Win32
)

:x64
IF /I "%PLATFORM%" == "Win32" GOTO End

CALL "%VSCOMNTOOLS%..\..\VC\vcvarsall.bat" %x64_type%

IF /I "%CONFIG%" == "Filters" (
  CALL :SubFilters x64
  IF /I "%ZIP%" == "True" CALL :SubCreatePackages Filters x64
  GOTO END
)

IF /I "%CONFIG%" == "Resources" CALL :SubResources x64 && GOTO END

CALL :SubMPCBE x64

IF /I "%CONFIG%" == "Main" GOTO End

CALL :SubResources x64

IF /I "%INSTALLER%" == "True" CALL :SubCreateInstaller x64
IF /I "%ZIP%" == "True"       CALL :SubCreatePackages MPC-BE x64

IF /I "%CONFIG%" == "All" (
  CALL :SubFilters x64
  IF /I "%ZIP%" == "True" CALL :SubCreatePackages Filters x64
)

:End
TITLE Compiling MPC-BE [FINISHED]
SET END_TIME=%TIME%
CALL :SubGetDuration
CALL :SubMsg "INFO" "Compilation started on %START_DATE%-%START_TIME% and completed on %DATE%-%END_TIME% [%DURATION%]"
ENDLOCAL
EXIT /B

:SubFilters
TITLE Compiling MPC-BE Filters - %BUILDCFG% Filter^|%1...
REM Call update_version.bat before building the filters
CALL "update_version.bat"
"%MSBUILD%" mpc-be%SLN%.sln %MSBUILD_SWITCHES%^
 /target:%BUILDTYPE% /property:Configuration="%BUILDCFG% Filter";Platform=%1^
 /flp1:LogFile=%LOG_DIR%\filters_errors_%BUILDCFG%_%1.log;errorsonly;Verbosity=diagnostic^
 /flp2:LogFile=%LOG_DIR%\filters_warnings_%BUILDCFG%_%1.log;warningsonly;Verbosity=diagnostic
IF %ERRORLEVEL% NEQ 0 (
  CALL :SubMsg "ERROR" "mpc-be%SLN%.sln %BUILDCFG% Filter %1 - Compilation failed!"
) ELSE (
  CALL :SubMsg "INFO" "mpc-be%SLN%.sln %BUILDCFG% Filter %1 compiled successfully"
)
EXIT /B

:SubMPCBE
TITLE Compiling MPC-BE - %BUILDCFG%^|%1...
"%MSBUILD%" mpc-be%SLN%.sln %MSBUILD_SWITCHES%^
 /target:%BUILDTYPE% /property:Configuration=%BUILDCFG%;Platform=%1^
 /flp1:LogFile=%LOG_DIR%\mpc-be_errors_%BUILDCFG%_%1.log;errorsonly;Verbosity=diagnostic^
 /flp2:LogFile=%LOG_DIR%\mpc-be_warnings_%BUILDCFG%_%1.log;warningsonly;Verbosity=diagnostic
IF %ERRORLEVEL% NEQ 0 (
  CALL :SubMsg "ERROR" "mpc-be%SLN%.sln %BUILDCFG% %1 - Compilation failed!"
) ELSE (
  CALL :SubMsg "INFO" "mpc-be%SLN%.sln %BUILDCFG% %1 compiled successfully"
)
TITLE Compiling MPCBEShellExt - %BUILDCFG%...
"%MSBUILD%" MPCBEShellExt%SLN%.sln %MSBUILD_SWITCHES%^
 /target:%BUILDTYPE% /property:Configuration=%BUILDCFG%;Platform=Win32
IF %ERRORLEVEL% NEQ 0 (
  CALL :SubMsg "ERROR" "MPCBEShellExt%SLN%.sln %BUILDCFG% Win32 - Compilation failed!"
) ELSE (
  CALL :SubMsg "INFO" "MPCBEShellExt%SLN%.sln %BUILDCFG% Win32 compiled successfully"
)
"%MSBUILD%" MPCBEShellExt%SLN%.sln %MSBUILD_SWITCHES%^
 /target:%BUILDTYPE% /property:Configuration=%BUILDCFG%;Platform=x64
IF %ERRORLEVEL% NEQ 0 (
  CALL :SubMsg "ERROR" "MPCBEShellExt%SLN%.sln %BUILDCFG% x64 - Compilation failed!"
) ELSE (
  CALL :SubMsg "INFO" "MPCBEShellExt%SLN%.sln %BUILDCFG% x64 compiled successfully"
)
EXIT /B

:SubResources
IF /I "%BUILDCFG%" == "Debug" (
  CALL :SubMsg "WARNING" "/debug was used, resources will not be built."
EXIT /B
)

FOR %%A IN ("Armenian" "Basque" "Belarusian" "Catalan" "Chinese Simplified"
 "Chinese Traditional" "Czech" "Dutch" "French" "German" "Greek" "Hebrew" "Hungarian"
 "Italian" "Japanese" "Korean" "Polish" "Portuguese" "Romanian" "Russian" "Slovak" "Spanish"
 "Swedish" "Turkish" "Ukrainian"
) DO (
 TITLE Compiling mpcresources - %%~A^|%1...
 "%MSBUILD%" mpcresources%SLN%.sln %MSBUILD_SWITCHES%^
 /target:%BUILDTYPE% /property:Configuration="Release %%~A";Platform=%1
 IF %ERRORLEVEL% NEQ 0 CALL :SubMsg "ERROR" "Compilation failed!"
)
EXIT /B

:SubCreateInstaller
IF "%~1" == "x64" SET ISDefs=/Dx64Build

CALL :SubDetectInnoSetup

IF NOT DEFINED InnoSetupPath (
  CALL :SubMsg "WARNING" "Inno Setup wasn't found, the %1 installer wasn't built"
  EXIT /B
)

TITLE Compiling %1 installer...
"%InnoSetupPath%\iscc.exe" /Q /O"bin" "distrib\mpc-be_setup.iss" %ISDefs%
IF %ERRORLEVEL% NEQ 0 CALL :SubMsg "ERROR" "Compilation failed!"
CALL :SubMsg "INFO" "%1 installer successfully built"

EXIT /B

:SubCreatePackages
CALL :SubDetectSevenzipPath
CALL :SubGetVersion

IF NOT DEFINED SEVENZIP (
  CALL :SubMsg "WARNING" "7-Zip wasn't found, the %1 %2 package wasn't built"
  EXIT /B
)

IF /I "%~1" == "Filters" (SET "NAME=standalone_filters-mpc-be") ELSE (SET "NAME=MPC-BE")
IF /I "%~2" == "Win32" (
  SET ARCH=x86
) ELSE (
  SET ARCH=x64
)

PUSHD "bin"

SET PackagesOut=Packages

IF NOT EXIST "%PackagesOut%\%MPCBE_VER%" MD "%PackagesOut%\%MPCBE_VER%"

SET "PCKG_NAME=%NAME%.%MPCBE_VER%.%ARCH%"

IF EXIST "%PackagesOut%\%MPCBE_VER%\%PCKG_NAME%.(%BUILD%).7z"     DEL "%PackagesOut%\%MPCBE_VER%\%PCKG_NAME%.(%BUILD%).7z"
IF EXIST "%PCKG_NAME%"        RD /Q /S "%PCKG_NAME%"

TITLE Copying %PCKG_NAME%...
IF NOT EXIST "%PCKG_NAME%" MD "%PCKG_NAME%"

IF /I "%NAME%" == "MPC-BE" (
  IF NOT EXIST "%PCKG_NAME%\Lang" MD "%PCKG_NAME%\Lang"
  IF /I "%ARCH%" == "x64" (
    COPY /Y /V "%~1_%ARCH%\mpc-be64.exe"        "%PCKG_NAME%\mpc-be64.exe" >NUL
    COPY /Y /V "%~1_%ARCH%\MPCBEShellExt64.dll" "%PCKG_NAME%\MPCBEShellExt64.dll" >NUL
  ) ELSE (
    COPY /Y /V "%~1_%ARCH%\mpc-be.exe"          "%PCKG_NAME%\mpc-be.exe" >NUL
    COPY /Y /V "%~1_%ARCH%\MPCBEShellExt.dll"   "%PCKG_NAME%\MPCBEShellExt.dll" >NUL
  )
  COPY /Y /V "%~1_%ARCH%\mpciconlib.dll"           "%PCKG_NAME%\*.dll" >NUL
  COPY /Y /V "%~1_%ARCH%\Lang\mpcresources.??.dll" "%PCKG_NAME%\Lang\mpcresources.??.dll" >NUL
) ELSE (
  COPY /Y /V "%~1_%ARCH%\*.ax"           "%PCKG_NAME%\*.ax" >NUL
  COPY /Y /V "%~1_%ARCH%\VSFilter.dll"   "%PCKG_NAME%\VSFilter.dll" >NUL
)

COPY /Y /V "..\docs\COPYING.txt"             "%PCKG_NAME%" >NUL
COPY /Y /V "..\docs\Authors.txt"             "%PCKG_NAME%" >NUL
COPY /Y /V "..\docs\Authors mpc-hc team.txt" "%PCKG_NAME%" >NUL
COPY /Y /V "..\docs\Changelog.txt"           "%PCKG_NAME%" >NUL
COPY /Y /V "..\docs\Changelog.Rus.txt"       "%PCKG_NAME%" >NUL
COPY /Y /V "..\docs\Readme.txt"              "%PCKG_NAME%" >NUL
IF NOT EXIST "%PCKG_NAME%\Shaders" MD "%PCKG_NAME%\Shaders"
COPY /Y /V "..\distrib\Shaders\*.psh"        "%PCKG_NAME%\Shaders\*.psh" >NUL

IF /I "%NAME%" == "MPC-BE" (
TITLE Creating archive %PCKG_NAME%.zip...
START "7z" /B /WAIT "%SEVENZIP%" a -tzip "%PackagesOut%\%MPCBE_VER%\%PCKG_NAME%-installer.(%BUILD%).zip" "%PCKG_NAME%.exe"^
 -mx9)
IF %ERRORLEVEL% NEQ 0 CALL :SubMsg "ERROR" "Unable to create %PCKG_NAME%-installer.zip!"
CALL :SubMsg "INFO" "%PCKG_NAME%-installer.zip successfully created"
)

TITLE Creating archive %PCKG_NAME%.7z...
START "7z" /B /WAIT "%SEVENZIP%" a -t7z "%PackagesOut%\%MPCBE_VER%\%PCKG_NAME%.(%BUILD%).7z" "%PCKG_NAME%"^
 -m0=lzma2:d128m -mx9 -mmt -ms=on
IF %ERRORLEVEL% NEQ 0 CALL :SubMsg "ERROR" "Unable to create %PCKG_NAME%.7z!"
CALL :SubMsg "INFO" "%PCKG_NAME%.7z successfully created"

IF EXIST "%PCKG_NAME%" RD /Q /S "%PCKG_NAME%"

POPD
EXIT /B

:SubGetVersion
REM Get the version
FOR /F "tokens=3,4 delims= " %%A IN (
  'FINDSTR /I /L /C:"define MPC_VERSION_MAJOR" "include\Version.h"') DO (SET "VerMajor=%%A")
FOR /F "tokens=3,4 delims= " %%A IN (
  'FINDSTR /I /L /C:"define MPC_VERSION_MINOR" "include\Version.h"') DO (SET "VerMinor=%%A")
FOR /F "tokens=3,4 delims= " %%A IN (
  'FINDSTR /I /L /C:"define MPC_VERSION_PATCH" "include\Version.h"') DO (SET "VerPatch=%%A")
FOR /F "tokens=3,4 delims= " %%A IN (
  'FINDSTR /I /L /C:"define MPC_VERSION_STATUS" "include\Version.h"') DO (SET "VerStatus=%%A")
FOR /F "tokens=3,4 delims= " %%A IN (
  'FINDSTR /I /L /C:"define MPC_VERSION_REV" "include\Version_rev.h"') DO (SET "VerRev=%%A")

SET MPCBE_VER=%VerMajor%.%VerMinor%.%VerPatch%.%VerStatus%.%VerRev%
EXIT /B

:SubDetectWinArch
IF DEFINED PROGRAMFILES(x86) (SET x64_type=amd64) ELSE (SET x64_type=x86_amd64)
EXIT /B

:SubDetectInnoSetup
REM Detect if we are running on 64bit WIN and use Wow6432Node, and set the path
REM of Inno Setup accordingly
IF /I "%x64_type%" == "amd64" (
  SET "U_=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
) ELSE (
  SET "U_=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

FOR /F "delims=" %%A IN (
  'REG QUERY "%U_%\Inno Setup 5_is1" /v "Inno Setup: App Path" 2^>Nul ^|FIND "REG_SZ"') DO (
  SET "InnoSetupPath=%%A" & CALL :SubInnoSetupPath %%InnoSetupPath:*Z=%%)
EXIT /B

:SubDetectSevenzipPath
IF EXIST "%PROGRAMFILES%\7za.exe" (SET "SEVENZIP=%PROGRAMFILES%\7za.exe" & EXIT /B)
IF EXIST "7za.exe"                (SET "SEVENZIP=7za.exe" & EXIT /B)

FOR %%A IN (7z.exe)  DO (SET "SEVENZIP_PATH=%%~$PATH:A")
IF EXIST "%SEVENZIP_PATH%" (SET "SEVENZIP=%SEVENZIP_PATH%" & EXIT /B)

FOR %%A IN (7za.exe) DO (SET "SEVENZIP_PATH=%%~$PATH:A")
IF EXIST "%SEVENZIP_PATH%" (SET "SEVENZIP=%SEVENZIP_PATH%" & EXIT /B)

IF /I "%x64_type%" == "amd64" (
  FOR /F "delims=" %%A IN (
    'REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\7-Zip" /v "Path" 2^>Nul ^| FIND "REG_SZ"') DO (
    SET "SEVENZIP_REG=%%A" & CALL :SubSevenzipPath %%SEVENZIP_REG:*REG_SZ=%%
  )
)

FOR /F "delims=" %%A IN (
  'REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\7-Zip" /v "Path" 2^>Nul ^| FIND "REG_SZ"') DO (
  SET "SEVENZIP_REG=%%A" & CALL :SubSevenzipPath %%SEVENZIP_REG:*REG_SZ=%%
)
EXIT /B

:ShowHelp
TITLE %~nx0 Help
ECHO.
ECHO Usage:
ECHO %~nx0 [Clean^|Build^|Rebuild] [x86^|x64^|Both] [Main^|Resources^|MPCBE^|Filters^|All] [Debug^|Release] [Packages^|Installer^|Zip] [VS2010^|VS2012]
ECHO.
ECHO Notes: You can also prefix the commands with "-", "--" or "/".
ECHO        Debug only applies to mpc-be%SLN%.sln.
ECHO        The arguments are not case sensitive and can be ommitted.
ECHO. & ECHO.
ECHO Executing %~nx0 without any arguments will use the default ones:
ECHO "%~nx0 Build Both MPCBE Release"
ECHO. & ECHO.
ECHO Examples:
ECHO %~nx0 x86 Resources VS2010 -Builds the x86 resources
ECHO %~nx0 Resources VS2010     -Builds both x86 and x64 resources
ECHO %~nx0 x86 VS2010           -Builds x86 Main exe and the x86 resources
ECHO %~nx0 x86 Debug VS2010     -Builds x86 Main Debug exe and x86 resources
ECHO %~nx0 x86 Filters VS2010   -Builds x86 Filters
ECHO %~nx0 x86 All VS2010       -Builds x86 Main exe, x86 Filters and the x86 resources
ECHO %~nx0 x86 Packages VS2010  -Builds x86 Main exe, x86 resources and creates the installer and the .7z package
ECHO.
ENDLOCAL
EXIT /B

:MissingVar
COLOR 0C
TITLE Compiling MPC-BE [ERROR]
ECHO Not all build dependencies were found.
ECHO.
ECHO See "docs\Compilation.txt" for more information.
ECHO. & ECHO.
ECHO Press any key to exit...
PAUSE >NUL
ENDLOCAL
EXIT /B

:UnsupportedSwitch
ECHO.
ECHO Unsupported commandline switch!
ECHO.
ECHO "build.bat %*"
ECHO.
ECHO Run "%~nx0 help" for details about the commandline switches.
CALL :SubMsg "ERROR" "Compilation failed!"

:SubInnoSetupPath
SET InnoSetupPath=%*
EXIT /B

:SubSevenzipPath
SET "SEVENZIP=%*\7z.exe"
EXIT /B

:SubMsg
ECHO. & ECHO ------------------------------
IF /I "%~1" == "ERROR" (
  CALL :SubColorText "0C" "[%~1]" & ECHO  %~2
) ELSE IF /I "%~1" == "INFO" (
  CALL :SubColorText "0A" "[%~1]" & ECHO  %~2
) ELSE IF /I "%~1" == "WARNING" (
  CALL :SubColorText "0E" "[%~1]" & ECHO  %~2
)
ECHO ------------------------------ & ECHO.
IF /I "%~1" == "ERROR" (
  ECHO Press any key to close this window...
  PAUSE >NUL
  ENDLOCAL
  EXIT
) ELSE (
  EXIT /B
)

:SubColorText
FOR /F "tokens=1,2 delims=#" %%A IN (
  '"PROMPT #$H#$E# & ECHO ON & FOR %%B IN (1) DO REM"') DO (
  SET "DEL=%%A")
<NUL SET /p ".=%DEL%" > "%~2"
FINDSTR /v /a:%1 /R ".18" "%~2" NUL
DEL "%~2" > NUL 2>&1
EXIT /B

:SubGetDuration
SET START_TIME=%START_TIME: =%
SET END_TIME=%END_TIME: =%

FOR /F "tokens=1-4 delims=:.," %%A IN ("%START_TIME%") DO (
  SET /A "STARTTIME=(100%%A %% 100) * 360000 + (100%%B %% 100) * 6000 + (100%%C %% 100) * 100 + (100%%D %% 100)"
)

FOR /F "tokens=1-4 delims=:.," %%A IN ("%END_TIME%") DO (
  SET /A "ENDTIME=(100%%A %% 100) * 360000 + (100%%B %% 100) * 6000 + (100%%C %% 100) * 100 + (100%%D %% 100)"
)

SET /A DURATION=%ENDTIME%-%STARTTIME%
IF %ENDTIME% LSS %STARTTIME% SET /A "DURATION+=24 * 360000"

SET /A DURATIONH=%DURATION% / 360000
SET /A DURATIONM=(%DURATION% - %DURATIONH%*360000) / 6000
SET /A DURATIONS=(%DURATION% - %DURATIONH%*360000 - %DURATIONM%*6000) / 100
SET /A DURATIONHS=(%DURATION% - %DURATIONH%*360000 - %DURATIONM%*6000 - %DURATIONS%*100)*10

IF %DURATIONH%  EQU 0 (SET DURATIONH=)  ELSE (SET DURATIONH=%DURATIONH%h )
IF %DURATIONM%  EQU 0 (SET DURATIONM=)  ELSE (SET DURATIONM=%DURATIONM%m )
IF %DURATIONS%  EQU 0 (SET DURATIONS=)  ELSE (SET DURATIONS=%DURATIONS%s )
IF %DURATIONHS% EQU 0 (SET DURATIONHS=) ELSE (SET DURATIONHS=%DURATIONHS%ms)

SET "DURATION=%DURATIONH%%DURATIONM%%DURATIONS%%DURATIONHS%"
EXIT /B
