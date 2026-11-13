@echo off
rem ShoeShop: резервная копия БД topotun (структура + данные) в db\backup\
chcp 65001 >nul
set MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin
set DB=topotun
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmm"') do set STAMP=%%i
set OUT=%~dp0backup\%DB%_dump_%STAMP%.sql

if not exist "%~dp0backup" mkdir "%~dp0backup"
"%MYSQL_BIN%\mysqldump.exe" -u root -p --databases %DB% --routines --triggers --default-character-set=utf8mb4 --result-file="%OUT%"
if errorlevel 1 (
    echo Ошибка: дамп не создан. Проверьте пароль root и путь MYSQL_BIN.
    exit /b 1
)
echo Готово: %OUT%
