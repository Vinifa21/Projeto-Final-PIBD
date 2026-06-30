@echo off
REM Abre o psql ja conectado ao banco faculdade
chcp 65001 >nul
set PGCLIENTENCODING=UTF8
"C:\Users\carlo\AppData\Local\Temp\claude\C--Users-carlo\daefcb2e-abba-4a28-8c89-5df1f08bb851\scratchpad\pg\pgsql\bin\psql.exe" -h localhost -p 5432 -U vini21 -d faculdade
pause
