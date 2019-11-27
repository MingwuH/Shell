@echo off

setlocal enabledelayedexpansion

for %%X in (*) do @certutil -hashfile %%X sha256 >> sha256.txt

endlocal
