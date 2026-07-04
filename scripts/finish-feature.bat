@echo off

for /f %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i

if "%CURRENT_BRANCH%"=="develop" (
    color 0C
    echo You are already on develop.
    color 07
    exit /b 1
)

git diff --quiet
if errorlevel 1 (
    color 0C
    echo Working tree is not clean.
    color 07
    exit /b 1
)

echo Current branch: %CURRENT_BRANCH%

echo Switching to develop...
git checkout develop
if errorlevel 1 exit /b 1

echo Updating develop...
git pull origin develop
if errorlevel 1 exit /b 1

echo Merging...
git merge --no-ff %CURRENT_BRANCH% -m "Merge branch '%CURRENT_BRANCH%' into develop"

if errorlevel 1 (
    color 0C
    echo.
    echo ==============================================
    echo            MERGE CONFLICT DETECTED!
    echo ==============================================
    color 0A
    echo.
    echo Resolve the conflicts and continue manually:
    echo.
    echo git status
    echo rem resolve conflicts
    echo git add .
    echo git commit
    echo git push origin develop
    color 07
    pause
    exit /b 1
)

echo Pushing develop...
git push origin develop
if errorlevel 1 exit /b 1

echo Returning to %CURRENT_BRANCH%...
git checkout %CURRENT_BRANCH%

echo.
echo Feature successfully merged into develop.
echo GitHub Actions will now deploy develop.

echo.
echo Feature successfully merged into develop.
echo GitHub Actions will now deploy develop.

for /f %%i in ('git remote get-url origin') do set REMOTE_URL=%%i

set ACTIONS_URL=%REMOTE_URL%

set ACTIONS_URL=%ACTIONS_URL:git@github.com:=https://github.com/%
set ACTIONS_URL=%ACTIONS_URL:https://github.com=https://github.com%
set ACTIONS_URL=%ACTIONS_URL:.git=%
set ACTIONS_URL=%ACTIONS_URL::=/%

start "" "%ACTIONS_URL%/actions"

pause