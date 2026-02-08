@echo off
REM Testers.AI Extension - Automated Installation and Execution Script for Windows
REM This script checks for VS Code, installs it if needed, builds and installs the extension, then runs a test

setlocal enabledelayedexpansion

REM Parse command-line arguments
set URLS=
set INSTRUCTIONS=
set JSON_OUTPUT=
set IMAGE_OUTPUT=
set SKIP_INSTALL=0
set VSIX_PATH=

:parse_args
if "%~1"=="" goto end_parse
if /i "%~1"=="--url" (
    if "!URLS!"=="" (
        set URLS=%~2
    ) else (
        set URLS=!URLS!,%~2
    )
    shift
    shift
    goto parse_args
)
if /i "%~1"=="--instructions" (
    set INSTRUCTIONS=%~2
    shift
    shift
    goto parse_args
)
if /i "%~1"=="--json-output" (
    set JSON_OUTPUT=%~2
    shift
    shift
    goto parse_args
)
if /i "%~1"=="--image-output" (
    set IMAGE_OUTPUT=%~2
    shift
    shift
    goto parse_args
)
if /i "%~1"=="--vsix" (
    set VSIX_PATH=%~2
    shift
    shift
    goto parse_args
)
if /i "%~1"=="--skip-install" (
    set SKIP_INSTALL=1
    shift
    goto parse_args
)
if /i "%~1"=="--help" goto show_help
if /i "%~1"=="-h" goto show_help
echo Unknown option: %~1
echo Run with --help for usage information
exit /b 1

:show_help
echo Testers.AI Extension - Installation and Execution Script
echo.
echo Usage:
echo   install-and-run.bat [options]
echo.
echo Options:
echo   --url ^<url^>              URL to test (can be specified multiple times)
echo   --instructions ^<text^>     Instructions for the test
echo   --json-output ^<dir^>       Directory to save JSON results
echo   --image-output ^<dir^>      Directory to save PNG screenshots
echo   --vsix ^<path^>             Path to existing VSIX file (skips build)
echo   --skip-install              Skip VS Code and extension installation
echo   --help, -h                  Show this help message
echo.
echo Examples:
echo   # Install and run test
echo   install-and-run.bat --url https://example.com --json-output ./results
echo.
echo   # Use existing VSIX file
echo   install-and-run.bat --vsix ./testers-ai-ide-0.0.1.vsix --url https://example.com
exit /b 0

:end_parse

echo Testers.AI Extension - Installation and Execution
echo ==================================================
echo.

REM Check for VS Code
where code >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "delims=" %%v in ('code --version 2^>^&1 ^| findstr /r "^[0-9]"') do (
        set VSCODE_VERSION=%%v
        goto :vscode_found
    )
    :vscode_found
    echo [OK] VS Code found: !VSCODE_VERSION!
) else (
    echo [WARN] VS Code not found in PATH
    if !SKIP_INSTALL! EQU 0 (
        echo Attempting to find VS Code installation...
        
        REM Check common installation paths
        if exist "C:\Program Files\Microsoft VS Code\bin\code.cmd" (
            set "PATH=C:\Program Files\Microsoft VS Code\bin;%PATH%"
            echo [OK] VS Code found in default location
        ) else if exist "C:\Program Files (x86)\Microsoft VS Code\bin\code.cmd" (
            set "PATH=C:\Program Files (x86)\Microsoft VS Code\bin;%PATH%"
            echo [OK] VS Code found in default location
        ) else if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd" (
            set "PATH=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin;%PATH%"
            echo [OK] VS Code found in user location
        ) else (
            echo [ERROR] VS Code not found. Please install it manually:
            echo   1. Download from https://code.visualstudio.com
            echo   2. Run the installer
            echo   3. Make sure "Add to PATH" is checked during installation
            echo   4. Run this script again
            exit /b 1
        )
    )
)

REM Check for Node.js
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js not found. Please install Node.js ^(v16 or higher^) from https://nodejs.org
    exit /b 1
)
for /f "delims=" %%n in ('node --version 2^>^&1') do set NODE_VERSION=%%n
echo [OK] Node.js found: !NODE_VERSION!

REM Check for npm
where npm >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] npm not found. Please install npm
    exit /b 1
)
for /f "delims=" %%n in ('npm --version 2^>^&1') do set NPM_VERSION=%%n
echo [OK] npm found: !NPM_VERSION!

REM Build VSIX if not provided
if "!VSIX_PATH!"=="" (
    echo.
    echo [INFO] Building extension...
    
    REM Install dependencies if needed
    if not exist "node_modules" (
        echo Installing dependencies...
        call npm install
    )
    
    REM Compile TypeScript
    echo Compiling TypeScript...
    call npm run compile
    
    REM Install vsce if needed
    where vsce >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Installing @vscode/vsce...
        call npm install -g @vscode/vsce
    )
    
    REM Build VSIX
    echo Building VSIX package...
    call npx @vscode/vsce package --out ./testers-ai-ide-0.0.1.vsix --yarn false
    
    if not exist "testers-ai-ide-0.0.1.vsix" (
        echo [ERROR] Failed to build VSIX package
        exit /b 1
    )
    
    set VSIX_PATH=testers-ai-ide-0.0.1.vsix
    echo [OK] VSIX built: !VSIX_PATH!
) else (
    if not exist "!VSIX_PATH!" (
        echo [ERROR] VSIX file not found: !VSIX_PATH!
        exit /b 1
    )
    echo [OK] Using existing VSIX: !VSIX_PATH!
)

REM Install extension
if !SKIP_INSTALL! EQU 0 (
    echo.
    echo [INFO] Installing extension...
    code --install-extension "!VSIX_PATH!" --force
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Extension installed
    ) else (
        echo [WARN] Extension installation may have failed, but continuing...
    )
)

REM Run test if URLs provided
if not "!URLS!"=="" (
    echo.
    echo [INFO] Running test...
    
    REM Set environment variables
    set TESTERS_AI_URLS=!URLS!
    if not "!INSTRUCTIONS!"=="" set TESTERS_AI_INSTRUCTIONS=!INSTRUCTIONS!
    if not "!JSON_OUTPUT!"=="" set TESTERS_AI_JSON_OUTPUT=!JSON_OUTPUT!
    if not "!IMAGE_OUTPUT!"=="" set TESTERS_AI_IMAGE_OUTPUT=!IMAGE_OUTPUT!
    
    REM Run the CLI command
    code --command testersAi.runTestCLI
    
    echo [OK] Test execution initiated
    echo.
    echo Check VS Code's Output channel ('Testers.AI CLI') for progress and results.
) else (
    echo.
    echo [OK] Installation complete!
    echo.
    echo To run a test, use:
    echo   testers-ai-cli.bat --url https://example.com --json-output ./results
)

echo.
echo [OK] Done!

endlocal

