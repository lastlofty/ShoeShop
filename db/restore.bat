@echo off
rem ShoeShop: восстановление БД topotun из файла резервной копии.
rem Использование: restore.bat [путь_к_дампу.sql]
rem Без параметра берётся последняя копия из db\backup\
chcp 65001 >nul
set MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin
set DUMP=%~1
if "%DUMP%"=="" (
    for /f "delims=" %%f in ('dir /b /o:d "%~dp0backup\*.sql"') do set DUMP=%~dp0backup\%%f
)
if not exist "%DUMP%" (
    echo Ошибка: файл "%DUMP%" не найден.
    exit /b 1
)
echo Восстанавливаю из %DUMP%
"%MYSQL_BIN%\mysql.exe" -u root -p --default-character-set=utf8mb4 < "%DUMP%"
if errorlevel 1 (
    echo Ошибка восстановления. Проверьте пароль root и путь MYSQL_BIN.
    exit /b 1
)
echo Готово. Проверка: откройте db\checks.sql и выполните запрос 1.
