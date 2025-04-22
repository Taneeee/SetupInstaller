@echo off
setlocal

set SERVICE_NAME=DemoConnectorForMSI


echo Stopping service: %SERVICE_NAME%
sc stop "%SERVICE_NAME%"
timeout /t 5 >nul

echo Deleting service: %SERVICE_NAME%
sc delete "%SERVICE_NAME%"
timeout /t 3 >nul

echo Uninstall script completed.
endlocal
exit /b 0
