@echo off
setlocal EnableDelayedExpansion
for /r %%i in (git2\*.d) do set files=%%i !files!

rem echo %files%
dmd -lib -ofbin\dlibgit.lib -Isrc %files%
