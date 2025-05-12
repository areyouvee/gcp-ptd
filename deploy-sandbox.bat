@echo off
setlocal enabledelayedexpansion

REM Usage: deploy_sandbox.bat sandbox-bob.zip

set "ZIP_FILE=%~1"

if "%ZIP_FILE%"=="" (
    echo Usage: %~nx0 sandbox-^<devname^>.zip
    exit /b 1
)

REM Extract dev name (e.g., sandbox-bob.zip → bob)
for %%F in ("%ZIP_FILE%") do (
    set "FILENAME=%%~nF"
)
for /f "tokens=2 delims=-" %%D in ("!FILENAME!") do (
    set "DEV_NAME=%%D"
)

REM Get current GCP project
FOR /F "delims=" %%P IN ('gcloud config get-value project 2^>nul') DO (
    set "PROJECT_ID=%%P"
)

if "!PROJECT_ID!"=="" (
    echo No active GCP project found. Set it using: gcloud config set project ^<PROJECT_ID^>
    exit /b 1
)

set "TMP_DIR=.\sandbox-deploy-tmp"
if exist "!TMP_DIR!" rmdir /s /q "!TMP_DIR!"
mkdir "!TMP_DIR!"

echo Unzipping %ZIP_FILE% to !TMP_DIR!...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '!TMP_DIR!' -Force"

echo Submitting build for dev: !DEV_NAME! to project: !PROJECT_ID!
gcloud builds submit "!TMP_DIR!" ^
  --substitutions=_DEV_NAME="!DEV_NAME!",_PROJECT_ID="!PROJECT_ID!" ^
  --config="!TMP_DIR!\cloudbuild.yaml"

echo Deployment has been submitted. Cleaning up temp dir...
rmdir /s /q "!TMP_DIR!"
