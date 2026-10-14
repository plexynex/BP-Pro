@echo off
setlocal enabledelayedexpansion
title Cek File EDIT vs 4R

:: ===== KONFIGURASI =====
:: Pakai variabel terpisah supaya tidak ada masalah parsing
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "EDIT_DIR=%ROOT%\EDIT"
set "R4_DIR=%ROOT%\4R"

:: ===== DEBUG: tampilkan path yang dipakai =====
cls
echo.
echo   ==================================================
echo     CEK FILE EDIT  vs  4R  (deteksi 4 angka)
echo   ==================================================
echo.
echo   Path yang dipakai:
echo     EDIT : %EDIT_DIR%
echo     4R   : %R4_DIR%
echo.

if not exist "%EDIT_DIR%" (
    echo   [!] Folder EDIT tidak ditemukan.
    echo       Cek: %EDIT_DIR%
    echo.
    pause
    exit /b
)

if not exist "%R4_DIR%" (
    echo   [!] Folder 4R tidak ditemukan.
    echo       Cek: %R4_DIR%
    echo.
    pause
    exit /b
)

echo   Kedua folder OK.
echo.
echo   --------------------------------------------------
echo.

:: ===== PENGHITUNG =====
set /a TOTAL=0
set /a SUDAH_ADA=0
set /a BELUM_ADA=0
set /a TANPA_ANGKA=0

:: ===== PROSES SETIAP FILE DI FOLDER EDIT =====
for %%F in ("%EDIT_DIR%\*.*") do (
    set "FNAME=%%~nxF"
    set "BASENAME=%%~nF"
    set /a TOTAL+=1
    
    call :AMBIL_4ANGKA "!BASENAME!"
    set "KODE=!KODE4!"
    
    if "!KODE!"=="" (
        echo   [?] !FNAME!
        echo       -- tidak ada 4 angka dalam nama
        set /a TANPA_ANGKA+=1
    ) else (
        set "FOUND="
        
        for %%G in ("%R4_DIR%\*.*") do (
            set "GBASE=%%~nG"
            call :AMBIL_4ANGKA "!GBASE!"
            if /i "!KODE4!"=="!KODE!" (
                set "FOUND=%%~nxG"
            )
        )
        
        if defined FOUND (
            set /a SUDAH_ADA+=1
            if /i "!FOUND!"=="!FNAME!" (
                echo   [v] !FNAME!   ^(kode: !KODE!^)
                echo       -- sudah ada di 4R ^(nama sama^)
            ) else (
                echo   [v] !FNAME!   ^(kode: !KODE!^)
                echo       -- sudah ada di 4R sebagai: !FOUND!
            )
        ) else (
            set /a BELUM_ADA+=1
            echo   [x] !FNAME!   ^(kode: !KODE!^)
            echo       -- belum ada di 4R
        )
    )
)

:: ===== RINGKASAN =====
echo.
echo   ==================================================
echo     RINGKASAN
echo   ==================================================
echo.
echo     Total file di EDIT     .  %TOTAL%
echo     [v] Sudah ada di 4R    .  %SUDAH_ADA%
echo     [x] Belum ada di 4R    .  %BELUM_ADA%
if %TANPA_ANGKA% gtr 0 (
    echo     [?] Tanpa 4 angka       .  %TANPA_ANGKA%
)
echo.
echo   ==================================================
echo.

pause
endlocal
goto :EOF

:: ==================================================
:: FUNGSI: Ambil 4 angka terakhir dari sebuah string
:: ==================================================
:AMBIL_4ANGKA
set "STR=%~1"
set "KODE4="
set "TMP="
set "COUNT=0"

:: Hitung panjang string
set "LEN=0"
set "S=!STR!"
:COUNT_LEN
if defined S (
    set "S=!S:~1!"
    set /a LEN+=1
    goto :COUNT_LEN
)

if %LEN% lss 1 goto :EOF

:: Baca dari belakang
for /l %%I in (%LEN%,-1,1) do (
    set /a IDX=%%I-1
    set "CH=!STR:~%%IDX,1!"
    echo !CH! | findstr /r "^[0-9]$" >nul
    if !errorlevel! equ 0 (
        set "TMP=!CH!!TMP!"
        set /a COUNT+=1
        if !COUNT! geq 4 goto :GOT_4
    ) else (
        if !COUNT! gtr 0 goto :GOT_4
    )
)

:GOT_4
if !COUNT! geq 4 (
    set "KODE4=!TMP!"
)
goto :EOF
