@echo off
setlocal enabledelayedexpansion

diskpart /s %~dp0\eject\listvolume

endlocal
