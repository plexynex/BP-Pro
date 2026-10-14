@echo off
setlocal enabledelayedexpansion
title Cek File EDIT vs 4R (tanpa ekstensi)

:: ===== WARNA (opsional) =====
for /f %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"
set "C_RESET=%ESC%[0m"
set "C_BOLD=%ESC%[1m"
set "C_CYAN=%ESC%[96m"
set "C_GREEN=%ESC%[92m"
set "C_RED=%ESC%[91m"
set "C_YELLOW=%ESC%[93m"
set "C_GRAY=%ESC%[90m"
set "C_WHITE=%ESC%[97m"

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
    set "FBASE=%%~nF"
    set /a TOTAL+=1
    set "MATCH="
    
    :: Cari di folder 4R: file yang nama dasarnya sama (abaikan ekstensi)
    for %%G in ("%R4_DIR%\*.*") do (
        if /i "%%~nG"=="!FBASE!" (
            set "MATCH=%%~nxG"
        )
    )
    
    if defined MATCH (
        set /a SUDAH_ADA+=1
        echo   [v] !FNAME!
        echo       -- sudah ada di 4R sebagai !MATCH!
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
