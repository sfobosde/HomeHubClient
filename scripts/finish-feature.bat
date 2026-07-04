@echo off
setlocal

:: Get current branch
for /f %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i

if "%CURRENT_BRANCH%"=="develop" (
    color 0C
    echo You are already on develop.
    color 07
    pause
    exit /b 1
)

:: Check for uncommitted changes
git diff-index --quiet HEAD --
if errorlevel 1 (
    color 0C
    echo Working tree is not clean.
    echo Commit or stash your changes first.
    color 07
    pause
    exit /b 1
)

echo Current branch: %CURRENT_BRANCH%
echo.

echo Switching to develop...
git checkout develop
if errorlevel 1 (
    pause
    exit /b 1
)

echo.
echo Updating develop...
git pull origin develop
if errorlevel 1 (
    git checkout %CURRENT_BRANCH%
    pause
    exit /b 1
)

echo.
echo Merging...
set "MERGE_MSG=Merge branch '%CURRENT_BRANCH%' into develop"
git merge --no-ff %CURRENT_BRANCH% -m "%MERGE_MSG%"

if errorlevel 1 (
    color 0C
    echo.
    echo ==============================================
    echo            MERGE CONFLICT DETECTED!
    echo ==============================================
    color 0A
    echo.
    echo Resolve the conflicts and continue manually.
    echo.
    echo Commands:
    echo.
    echo     git status
    echo     ^<resolve conflicts^>
    echo     git add .
    echo     git commit
    echo     git push origin develop
    echo.
    color 07
    pause
    exit /b 1
)

echo.
echo Pushing develop...
git push origin develop

if errorlevel 1 (
    color 0C
    echo Push failed.
    color 07
    git checkout %CURRENT_BRANCH%
    pause
    exit /b 1
)

echo.
echo Returning to %CURRENT_BRANCH%...
git checkout %CURRENT_BRANCH%

echo.
color 0A
echo ==============================================
echo Feature successfully merged into develop.
echo GitHub Actions will now deploy develop.
echo ==============================================
color 07

:: Open GitHub Actions page
for /f %%i in ('git remote get-url origin') do set REMOTE_URL=%%i

powershell -NoProfile -Command ^
"$u='%REMOTE_URL%';" ^
"$u=$u -replace '^git@github.com:','https://github.com/';" ^
"$u=$u -replace '\.git$','';" ^
"Start-Process ($u + '/actions')"

pause
endlocal