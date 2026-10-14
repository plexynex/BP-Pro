@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Cek File EDIT vs 4R

:: ===== WARNA =====
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
set "R4_DIR=%~dp0 4R"
set "R4_DIR=%~dp04R"

:: ===== VALIDASI FOLDER =====
cls
echo.
echo   %C_CYAN%╔══════════════════════════════════════════════════╗%C_RESET%
echo   %C_CYAN%║%C_RESET%  %C_BOLD%%C_WHITE%  CEK FILE EDIT  vs  4R  %C_RESET%                       %C_CYAN%║%C_RESET%
echo   %C_CYAN%╚══════════════════════════════════════════════════╝%C_RESET%
echo.

if not exist "%EDIT_DIR%" (
    echo   %C_RED%[!]%C_RESET% Folder %C_YELLOW%EDIT%C_RESET% tidak ditemukan:
    echo       %C_GRAY%%EDIT_DIR%%C_RESET%
    echo.
    pause
    exit /b
)

if not exist "%R4_DIR%" (
    echo   %C_RED%[!]%C_RESET% Folder %C_YELLOW%4R%C_RESET% tidak ditemukan:
    echo       %C_GRAY%%R4_DIR%%C_RESET%
    echo.
    pause
    exit /b
)

echo   %C_GRAY%Sumber :%C_RESET% %C_CYAN%%EDIT_DIR%%C_RESET%
echo   %C_GRAY%Target :%C_RESET% %C_CYAN%%R4_DIR%%C_RESET%
echo.
echo   %C_GRAY%──────────────────────────────────────────────────%C_RESET%
echo.

:: ===== VARIABEL PENGHITUNG =====
set /a TOTAL=0
set /a SUDAH_ADA=0
set /a BELUM_ADA=0

:: ===== PROSES SETIAP FILE DI FOLDER EDIT =====
for %%F in ("%EDIT_DIR%\*.*") do (
    set "FNAME=%%~nxF"
    set /a TOTAL+=1
    
    if exist "%R4_DIR%\!FNAME!" (
        set /a SUDAH_ADA+=1
        echo   %C_GREEN%✔%C_RESET% %C_WHITE%!FNAME!%C_RESET%
        echo     %C_GREEN%→ sudah ada di 4R%C_RESET%
    ) else (
        set /a BELUM_ADA+=1
        echo   %C_RED%✘%C_RESET% %C_WHITE%!FNAME!%C_RESET%
        echo     %C_RED%→ belum ada di 4R%C_RESET%
    )
)

:: ===== RINGKASAN =====
echo.
echo   %C_CYAN%══════════════════════════════════════════════════%C_RESET%
echo   %C_BOLD%%C_WHITE%RINGKASAN%C_RESET%
echo   %C_CYAN%══════════════════════════════════════════════════%C_RESET%
echo.
echo     %C_GRAY%Total file di EDIT%C_RESET%    %C_GRAY%·%C_RESET%  %C_BOLD%%TOTAL%%C_RESET%
echo     %C_GREEN%✔  Sudah ada di 4R%C_RESET%    %C_GRAY%·%C_RESET%  %C_BOLD%%SUDAH_ADA%%C_RESET%
echo     %C_RED%✘  Belum ada di 4R%C_RESET%    %C_GRAY%·%C_RESET%  %C_BOLD%%BELUM_ADA%%C_RESET%
echo.
echo   %C_CYAN%══════════════════════════════════════════════════%C_RESET%
echo.

pause
endlocal
