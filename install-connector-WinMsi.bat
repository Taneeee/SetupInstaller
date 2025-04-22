@echo off

rem  ====================================================================================
rem     ----------- BMC Helix Developer Tools Connector Install script -----------
rem  ====================================================================================

echo ====================================================================================
echo    ----------- BMC Helix Developer Tools Connector Install script -----------
echo ====================================================================================

setlocal EnableExtensions EnableDelayedExpansion

set "CURRENT_DIR=%cd%"
set "BASE_PATH=BMC-DevTools"
set "ENV_VARIABLE_FILE_PATH=%CURRENT_DIR%\%BASE_PATH%\opt\fluent\etc\data\config\env.list"
set "MEK_FILE_PATH=%CURRENT_DIR%\%BASE_PATH%\opt\fluent\etc\data\config\mek.txt"
set "TD_AGENT_EXECUTABLE_PATH=%CURRENT_DIR%\%BASE_PATH%\opt\fluent\bin\fluent.bat"
set "FLUENTD_EXECUTABLE=%CURRENT_DIR%\%BASE_PATH%\opt\fluent\bin\fluentd"
set "RUBY_EXECUTABLE=%CURRENT_DIR%\%BASE_PATH%\opt\fluent\bin\ruby"
set "RUBY_PATH_REPLACEMENT_SCRIPT=%CURRENT_DIR%\%BASE_PATH%\opt\repo\scripts\file_operations_utility.rb"
set "ETC_TD_AGENT_DIR=%CURRENT_DIR%/%BASE_PATH%/opt/fluent/etc/fluent"
set "TD_AGENT_DIR=%CURRENT_DIR%/%BASE_PATH%/opt/fluent"

set "WINDOWS_NON_DOCKERISED_BUILD=tdc-connector-windows-277da8c-791"
set "DATA_FOLDER=data"
set "CUSTOM_FOLDER=custom"
set "CONFIG_FOLDER=config"
set "LOG_FOLDER=logs"
set "CONNECTOR_ID=PARAMETERS.agent_id"
set "CONNECTOR_NAME=DemoConnectorForMSI"
set "CONNECTOR_DESC=PARAMETERS.agent_desc"
set "CONNECTOR_TAGS="
set "CONNECTOR_TYPE=tdc-connector-windows"
set "CONNECTOR_V2=true"
set "SCRIPT_INSTALL_LOG_FOLDER=%CURRENT_DIR%\%BASE_PATH%\opt\%CONNECTOR_NAME%"


if exist "%SCRIPT_INSTALL_LOG_FOLDER%" (

echo -------- Connector folder %SCRIPT_INSTALL_LOG_FOLDER% exists -------- 

)ELSE (
echo -------- Creating connector folder --------  
mkdir %SCRIPT_INSTALL_LOG_FOLDER%
)  

set "SCRIPT_INSTALL_LOG_FILE=%SCRIPT_INSTALL_LOG_FOLDER%\%CONNECTOR_NAME%_install.log"

rem check if service already exist (Service will be created with Connector name), if exist then do nothing

echo  -------- Checking if service name [%CONNECTOR_NAME%] already exist -------- 
echo "-------- Checking if service name [%CONNECTOR_NAME%] already exist --------" > %SCRIPT_INSTALL_LOG_FILE% 2>&1

sc query %CONNECTOR_NAME% > nul

IF ERRORLEVEL 1060 (
    echo  -------- %CONNECTOR_NAME% service does not exist -------- 
	echo  -------- %CONNECTOR_NAME% service does not exist --------  >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
) else (
    echo -------- Service with connector name [%CONNECTOR_NAME%] already exist -------- 
    echo -------- Service with connector name [%CONNECTOR_NAME%] already exist -------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
	goto gotoEND
)


rem assigment of variables
echo -------- Preparing environment list --------
echo -------- Preparing environment list -------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1

:: Fetch FQDN from argument or use fallback
set "fqdnhost="
if "%~1"=="" (
    echo -------- No FQDN passed from installer. Getting system FQDN --------
    call :getHostFQDN fqdnhost
) else (
    echo -------- FQDN passed from installer: %~1 --------
    set "fqdnhost=%~1"
)

if not defined fqdnhost (
    echo -------- Failed to determine FQDN. Aborting. --------
    echo -------- Failed to determine FQDN. Aborting. -------- >> "%SCRIPT_INSTALL_LOG_FILE%" 2>&1
    goto gotoEND
)

:: Prepare environment list
set "AGENT_NAME=%CONNECTOR_NAME%-%fqdnhost%"
echo AGENT_NAME=%AGENT_NAME%> "%ENV_VARIABLE_FILE_PATH%"
echo HOST_NAME=%fqdnhost%>> "%ENV_VARIABLE_FILE_PATH%"
echo MLWr6v1hjA31MKfKyAgqNbRQxvspOsC9RH+/fVbQ6Zk=> %MEK_FILE_PATH%

echo ACCESS_KEY=FTKLEEVBN3N4N2S4J7YERQ3HFUAANF>> %ENV_VARIABLE_FILE_PATH%
echo ACCESS_SECRET_KEY=I8U0+DfoyMsMz0duU2E7MLOqRO2FjWOhy1DOahX22RQYQDsCNDnQ7h/tzlA4ycH8E7514ogdOWZbhBcToWrqq03UxhVI5esD7iPh/VF7>> %ENV_VARIABLE_FILE_PATH%
echo TENANT_ID=102673089>> %ENV_VARIABLE_FILE_PATH%
echo DATA_ENC_KEY=WZRvwGVAm/w8etxdS/bEYA1I2lLOWy2w8xaTgdziE+Dl+dqyuj8caEbQ9QDmN8zmjG85fEUP7wblKTcZ6nxp9aYn8jmSsEtq>> %ENV_VARIABLE_FILE_PATH%
echo ADE_BASE_URL=https://hp-hmarcusdv-trial.dsmlab.bmc.com>> %ENV_VARIABLE_FILE_PATH%
echo AGENT_ID=%CONNECTOR_ID%>> %ENV_VARIABLE_FILE_PATH%
echo VERSION=%WINDOWS_NON_DOCKERISED_BUILD%>> %ENV_VARIABLE_FILE_PATH%
echo HOST_IP=127.0.1.1>> %ENV_VARIABLE_FILE_PATH%
echo INSTALLATION_ROOT_DIR=%CURRENT_DIR%\%BASE_PATH%\>> %ENV_VARIABLE_FILE_PATH%
echo ADE_SG_BASE_URL=https://hp-hmarcusdv-trial.dsmlab.bmc.com>> %ENV_VARIABLE_FILE_PATH%
echo ADE_SG_JWT=>> %ENV_VARIABLE_FILE_PATH%
echo FLUENTD_LOG_GENERATION=10>> %ENV_VARIABLE_FILE_PATH%
echo FLUENTD_LOG_SIZE_BYTE=10000000>> %ENV_VARIABLE_FILE_PATH%
echo AGENT_DESC=%CONNECTOR_DESC% >> %ENV_VARIABLE_FILE_PATH%
echo AGENT_TYPE=%CONNECTOR_TYPE% >> %ENV_VARIABLE_FILE_PATH%
echo AGENT_TAGS=%CONNECTOR_TAGS% >> %ENV_VARIABLE_FILE_PATH%
echo AGENT_V2=%CONNECTOR_V2% >> %ENV_VARIABLE_FILE_PATH%

echo -------- Environment list is created --------
echo -------- Environment list is created -------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
 
echo -------- Starting TD agent as a service -------- 
echo -------- Starting TD agent as a service -------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1


:: Register the FluentD service
echo -------- Registering FluentD service -------- 
call "%FLUENTD_EXECUTABLE%" --reg-winsvc i --winsvc-name %CONNECTOR_NAME% --winsvc-display-name %CONNECTOR_NAME%  --winsvc-desc "FluentD log collection"  --reg-winsvc-fluentdopt '-c %ETC_TD_AGENT_DIR%/fluentd.conf --log %TD_AGENT_DIR%/fluent.log  --log-rotate-age 10 --log-rotate-size 10000000'


if not %ERRORLEVEL%==0 (
	echo -------- FluentD command failed to register service -------- 
	echo -------- FluentD command failed to register service -------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
	goto gotoEND
)ELSE (
	goto createService
)

:createService

echo -------- FluentD Service command is executed -------- 
echo -------- FluentD Service command is executed -------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1

echo -------- Checking service [%CONNECTOR_NAME%] status --------
echo -------- Checking service [%CONNECTOR_NAME%] status -------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1


sc query %CONNECTOR_NAME% >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
if not %ERRORLEVEL%==0 (

	echo The service [%CONNECTOR_NAME%] could not installed correctly, please check your environment and verify the required permissions are granted to user

	echo The service [%CONNECTOR_NAME%] could not installed correctly, please check your environment and verify the required permissions are granted to user >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
	goto  gotoEND

)


:: Replace paths in config using Ruby script
echo -------- Replacing paths in conf files --------- 
echo -------- Replacing paths in conf files --------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
if "%CONNECTOR_V2%"=="true" (
	echo -------- Its V2 connector ---------
	echo -------- Its V2 connector --------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
    	call "%RUBY_EXECUTABLE%" "%RUBY_PATH_REPLACEMENT_SCRIPT%" true
) else (
    	call "%RUBY_EXECUTABLE%" "%RUBY_PATH_REPLACEMENT_SCRIPT%"
)

if not %ERRORLEVEL%==0 (
    echo --------Script failed to update paths --------- 
	echo --------Script failed to update paths --------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
	goto gotoEND

)

:: Start the service

echo -------- Service [%CONNECTOR_NAME%] created successfully --------
echo -------- Service [%CONNECTOR_NAME%] created successfully -------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1

echo -------- Starting service [%CONNECTOR_NAME%] --------
echo -------- Starting service [%CONNECTOR_NAME%] -------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1

sc config "%CONNECTOR_NAME%" start=auto >> "%SCRIPT_INSTALL_LOG_FILE%" 2>&1
sc start "%CONNECTOR_NAME%" >> "%SCRIPT_INSTALL_LOG_FILE%" 2>&1

if not %ERRORLEVEL%==0 (
   echo The service [%CONNECTOR_NAME%] is not started, please check your environment and verify the required permissions are granted to user

	echo The service [%CONNECTOR_NAME%] is not started, please check your environment and verify the required permissions are granted to user >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
	goto  gotoEND

)

echo -------- Service [%CONNECTOR_NAME%] started successfully --------
echo -------- Service [%CONNECTOR_NAME%] started successfully -------- >> %SCRIPT_INSTALL_LOG_FILE% 2>&1
goto gotoEND


:getHostFQDN
rem Retrieve FQDN via net config
for /f "tokens=2,* delims=:" %%A in ('net config workstation ^| findstr /C:"Full Computer name"') do (
    set "HOST_FQDN=%%B"
)
set "HOST_FQDN=%HOST_FQDN: =%"
set "%~1=%HOST_FQDN%"
exit /b 0

:gotoEND

echo -------- Exiting --------