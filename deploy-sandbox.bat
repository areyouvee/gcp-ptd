@echo off
REM ===============================
REM Sandbox Deployment Script - Windows
REM ===============================

set ZIP_FILE=%1

if "%ZIP_FILE%"=="" (
    echo Usage: deploy-sandbox.bat sandbox-<devname>.zip
    exit /b 1
)

REM Extract dev name from ZIP filename (sandbox-bob.zip -> bob)
set DEV_NAME=%ZIP_FILE:~8,-4%

REM Get current active GCP project
for /f "delims=" %%i in ('gcloud config get-value project 2^>nul') do set PROJECT_ID=%%i

if "%PROJECT_ID%"=="" (
    echo No active GCP project found. Set it using: gcloud config set project ^<PROJECT_ID^>
    exit /b 1
)

REM Setup temporary deployment directory
set TMP_DIR=.\sandbox-deploy-tmp
if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"
mkdir "%TMP_DIR%"

REM Unzip the provided zip file into TMP_DIR
tar -xf "%ZIP_FILE%" -C "%TMP_DIR%"

REM Submit build
echo Submitting build for dev: %DEV_NAME% to project: %PROJECT_ID%
gcloud builds submit "%TMP_DIR%" --config="%TMP_DIR%\cloudbuild.yaml" --substitutions="_DEV_NAME=%DEV_NAME%,_PROJECT_ID=%PROJECT_ID%"

REM Move back to batch file directory
cd /d %~dp0

REM Rename temp folder to avoid locking issues
set TMP_DELETE_DIR=sandbox-deploy-tmp-delete
if exist "%TMP_DELETE_DIR%" rmdir /s /q "%TMP_DELETE_DIR%"
rename "%TMP_DIR%" "sandbox-deploy-tmp-delete"

REM Delete the renamed folder
rmdir /s /q "%TMP_DELETE_DIR%"
