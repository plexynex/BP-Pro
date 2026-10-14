@echo off
setlocal enabledelayedexpansion
title Cek File EDIT vs 4R (4 angka)

:: ===== KONFIGURASI =====
set "EDIT_DIR=%~dp0EDIT"
set "R4_DIR=%~dp04R"

:: ===== VALIDASI =====
cls
echo.
echo   ==================================================
echo     CEK FILE EDIT  vs  4R  (deteksi 4 angka)
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
set /a TANPA_ANGKA=0

:: ===== PROSES SETIAP FILE DI FOLDER EDIT =====
for %%F in ("%EDIT_DIR%\*.*") do (
    set "FNAME=%%~nxF"
    set "BASENAME=%%~nF"
    set /a TOTAL+=1
    
    :: Ambil 4 angka terakhir dari nama file (sebelum ekstensi)
    call :AMBIL_4ANGKA "!BASENAME!"
    set "KODE=!KODE4!"
    
    if "!KODE!"=="" (
        echo   [?] !FNAME!
        echo       -- tidak ada 4 angka dalam nama
        set /a TANPA_ANGKA+=1
    ) else (
        set "FOUND="
        
        :: Cari file di 4R yang punya 4 angka sama
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
:: Hasil disimpan di variabel KODE4
:: ==================================================
:AMBIL_4ANGKA
set "STR=%~1"
set "KODE4="
set "TMP="
set "COUNT=0"

:: Loop setiap karakter dari belakang
set "LEN=0"
set "S=!STR!"
:COUNT_LEN
if defined S (
    set "S=!S:~1!"
    set /a LEN+=1
    goto :COUNT_LEN
)

:: Baca dari karakter terakhir ke belakang
for /l %%I in (%LEN%,-1,1) do (
    set /a IDX=%%I-1
    for /f "delims=" %%C in ("!STR:~%%IDX,1!") do (
        set "CH=%%C"
        echo !CH! | findstr /r "^[0-9]$" >nul
        if !errorlevel! equ 0 (
            set "TMP=!CH!!TMP!"
            set /a COUNT+=1
            if !COUNT! geq 4 goto :GOT_4
        ) else (
            if !COUNT! gtr 0 goto :GOT_4
        )
    )
)

:GOT_4
if !COUNT! geq 4 (
    set "KODE4=!TMP!"
)
goto :EOF
