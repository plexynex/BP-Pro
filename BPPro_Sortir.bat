@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title File Sorter Pro

:: ===== WARNA (via PowerShell escape) =====
for /f %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"
set "C_RESET=%ESC%[0m"
set "C_BOLD=%ESC%[1m"
set "C_DIM=%ESC%[2m"
set "C_CYAN=%ESC%[96m"
set "C_GREEN=%ESC%[92m"
set "C_RED=%ESC%[91m"
set "C_YELLOW=%ESC%[93m"
set "C_BLUE=%ESC%[94m"
set "C_MAGENTA=%ESC%[95m"
set "C_WHITE=%ESC%[97m"
set "C_GRAY=%ESC%[90m"

:: ===== KONFIGURASI =====
set "SORTIR_DIR=%~dp0sortir"
set "BASE_DIR=%~dp0"

:: ===== VARIABEL PENGHITUNG =====
set /a TOTAL_BERHASIL=0
set /a TOTAL_GAGAL=0
set /a TOTAL_TIDAK_DITEMUKAN=0

:: ===== BERSIHKAN LAYAR =====
cls
call :HEADER

:: ===== BUAT FOLDER SORTIR =====
if not exist "%SORTIR_DIR%" (
    mkdir "%SORTIR_DIR%"
    echo   %C_GREEN%[+]%C_RESET% Folder %C_CYAN%sortir%C_RESET% dibuat
) else (
    echo   %C_GRAY%[=]%C_RESET% Folder %C_CYAN%sortir%C_RESET% sudah tersedia
)
echo.

:: ===== INPUT =====
call :LINE
echo   %C_BOLD%Masukkan nama file%C_RESET% %C_GRAY%(pisah dengan koma)%C_RESET%
echo   %C_GRAY%contoh: 1234, 0912, 1209%C_RESET%
call :LINE
echo.
set /p "INPUT=  %C_MAGENTA%❯%C_RESET% " 
set "INPUT=%INPUT: =%"

if "%INPUT%"=="" (
    echo.
    echo   %C_RED%[!]%C_RESET% Tidak ada input. Keluar.
    echo.
    pause
    exit /b
)

echo.
call :LINE
echo   %C_BOLD%Mencari:%C_RESET% %C_YELLOW%%INPUT%%C_RESET%
call :LINE
echo.

:: ===== PROSES SETIAP NAMA =====
for %%A in (%INPUT%) do (
    set "NAMA=%%A"
    set "DITEMUKAN="
    set /a JML_BERHASIL=0
    set /a JML_GAGAL=0
    
    echo   %C_CYAN%▸%C_RESET% %C_BOLD%!NAMA!%C_RESET%
    
    :: [TAHAP 1] Pencarian nama PERSIS (rekursif)
    for /r "%BASE_DIR%" %%F in ("!NAMA!.*") do (
        echo %%~dpF | findstr /i /c:"\sortir\" >nul
        if !errorlevel! neq 0 (
            if exist "%%F" (
                set "DITEMUKAN=1"
                call :PINDAH_FILE "%%F" "%%~nxF" "%%~dpF"
            )
        )
    )
    
    :: [TAHAP 2] Pencarian MENGANDUNG (rekursif)
    if not defined DITEMUKAN (
        for /r "%BASE_DIR%" %%F in ("*!NAMA!*.*") do (
            echo %%~dpF | findstr /i /c:"\sortir\" >nul
            if !errorlevel! neq 0 (
                if exist "%%F" (
                    set "DITEMUKAN=1"
                    call :PINDAH_FILE "%%F" "%%~nxF" "%%~dpF"
                )
            )
        )
    )
    
    :: ===== HASIL PER NAMA =====
    if not defined DITEMUKAN (
        set /a TOTAL_TIDAK_DITEMUKAN+=1
        echo     %C_YELLOW%◦%C_RESET% %C_GRAY%tidak ditemukan%C_RESET%
    ) else (
        set /a TOTAL_BERHASIL+=!JML_BERHASIL!
        set /a TOTAL_GAGAL+=!JML_GAGAL!
        echo     %C_GRAY%└ %C_GREEN%!JML_BERHASIL! berhasil%C_RESET% %C_GRAY%·%C_RESET% %C_RED%!JML_GAGAL! gagal%C_RESET%
    )
    echo.
)

:: ===== RINGKASAN AKHIR =====
call :LINE2
echo   %C_BOLD%%C_WHITE%RINGKASAN AKHIR%C_RESET%
call :LINE2
echo.
echo     %C_GREEN%✔  Berhasil%C_RESET%          %C_GRAY%·%C_RESET%  %C_BOLD%%TOTAL_BERHASIL%%C_RESET%
echo     %C_RED%✘  Gagal%C_RESET%             %C_GRAY%·%C_RESET%  %C_BOLD%%TOTAL_GAGAL%%C_RESET%
echo     %C_YELLOW%◌  Tidak ditemukan%C_RESET%   %C_GRAY%·%C_RESET%  %C_BOLD%%TOTAL_TIDAK_DITEMUKAN%%C_RESET%
echo.
call :LINE2
echo   %C_GRAY%Tujuan:%C_RESET% %C_CYAN%%SORTIR_DIR%%C_RESET%
call :LINE2
echo.

pause
endlocal
goto :EOF

:: ==================================================
:: HEADER
:: ==================================================
:HEADER
echo.
echo   %C_CYAN%╔══════════════════════════════════════════════════╗%C_RESET%
echo   %C_CYAN%║%C_RESET%  %C_BOLD%%C_WHITE%  BATANG PADI PROJECT  %C_RESET%                              %C_CYAN%║%C_RESET%
echo   %C_CYAN%║%C_RESET%  %C_GRAY%Pencari ^& Pemindah File Otomatis%C_RESET%          %C_CYAN%║%C_RESET%
echo   %C_CYAN%╚══════════════════════════════════════════════════╝%C_RESET%
echo.
goto :EOF

:: ==================================================
:: GARIS PEMISAH
:: ==================================================
:LINE
echo   %C_GRAY%──────────────────────────────────────────────────%C_RESET%
goto :EOF

:LINE2
echo   %C_CYAN%══════════════════════════════════════════════════%C_RESET%
goto :EOF

:: ==================================================
:: FUNGSI PINDAH FILE
:: ==================================================
:PINDAH_FILE
set "SRC=%~1"
set "FNAME=%~2"
set "SRCDIR=%~3"

:: Auto-rename kalau duplikat
set "TARGET=%SORTIR_DIR%\%FNAME%"
set "COUNTER=1"
set "RENAMED="

:CEK_DUPLIKAT
if exist "%TARGET%" (
    set "BASENAME=%~n2"
    set "EXT=%~x2"
    set "TARGET=%SORTIR_DIR%\!BASENAME!_!COUNTER!!EXT!"
    set "RENAMED=!BASENAME!_!COUNTER!!EXT!"
    set /a COUNTER+=1
    goto :CEK_DUPLIKAT
)

move "!SRC!" "!TARGET!" >nul 2>&1

if !errorlevel! equ 0 (
    set /a JML_BERHASIL+=1
    echo     %C_GREEN%✔%C_RESET% %C_WHITE%!FNAME!%C_RESET%
    echo       %C_GRAY%↳ %C_GRAY%!SRCDIR!%C_RESET%
    if defined RENAMED (
        echo       %C_YELLOW%↻ renamed → !RENAMED!%C_RESET%
    )
) else (
    set /a JML_GAGAL+=1
    set "ERRMSG="
    
    if not exist "!SRC!" set "ERRMSG=file sumber hilang"
    if "!ERRMSG!"=="" (
        echo test > "%SORTIR_DIR%\_test.tmp" 2>nul
        if !errorlevel! neq 0 (
            set "ERRMSG=akses ditolak ke folder sortir"
            del "%SORTIR_DIR%\_test.tmp" >nul 2>&1
        ) else (
            del "%SORTIR_DIR%\_test.tmp" >nul 2>&1
            set "ERRMSG=file terkunci / sedang digunakan"
        )
    )
    
    echo     %C_RED%✘%C_RESET% %C_WHITE%!FNAME!%C_RESET%
    echo       %C_GRAY%↳ %C_GRAY%!SRCDIR!%C_RESET%
    echo       %C_RED%! %C_RED%!ERRMSG!%C_RESET%
)
goto :EOF