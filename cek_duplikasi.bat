@echo off
setlocal enabledelayedexpansion
title Cek File EDIT vs 4R (tanpa ekstensi)

:: ===== KONFIGURASI =====
set "EDIT_DIR=%~dp0EDIT"
set "R4_DIR=%~dp04R"

:: ===== VALIDASI =====
cls
echo.
echo   ==================================================
echo     CEK FILE EDIT  vs  4R  (abaikan ekstensi)
echo   ==================================================
echo.

if not exist "%EDIT_DIR%" (
    echo   [!] Folder EDIT tidak ditemukan:
    echo       %EDIT_DIR%
    echo.
    pause
    exit /b
)

if not exist "%R4_DIR%" (
    echo   [!] Folder 4R tidak ditemukan:
    echo       %R4_DIR%
    echo.
    pause
    exit /b
)

echo   Sumber : %EDIT_DIR%
echo   Target : %R4_DIR%
echo.
echo   --------------------------------------------------
echo.

:: ===== PENGHITUNG =====
set /a TOTAL=0
set /a SUDAH_ADA=0
set /a BELUM_ADA=0

:: ===== PROSES SETIAP FILE DI FOLDER EDIT =====
for %%F in ("%EDIT_DIR%\*.*") do (
    set "FNAME=%%~nxF"
    set "BASENAME=%%~nF"
    set "FOUND="
    set /a TOTAL+=1
    
    :: Cari file dengan nama dasar sama (ekstensi apapun) di folder 4R
    for %%G in ("%R4_DIR%\!BASENAME!.*") do (
        if exist "%%G" (
            set "FOUND=%%~nxG"
        )
    )
    
    if defined FOUND (
        set /a SUDAH_ADA+=1
        if /i "!FOUND!"=="!FNAME!" (
            echo   [v] !FNAME!
            echo       -- sudah ada di 4R ^(nama ^& ekstensi sama^)
        ) else (
            echo   [v] !FNAME!
            echo       -- sudah ada di 4R sebagai: !FOUND!
        )
    ) else (
        set /a BELUM_ADA+=1
        echo   [x] !FNAME!
        echo       -- belum ada di 4R
    )
)

:: ===== RINGKASAN =====
echo.
echo   ==================================================
echo     RINGKASAN
echo   ==================================================
echo.
echo     Total file di EDIT    .  %TOTAL%
echo     [v] Sudah ada di 4R   .  %SUDAH_ADA%
echo     [x] Belum ada di 4R   .  %BELUM_ADA%
echo.
echo   ==================================================
echo.

pause
endlocal
