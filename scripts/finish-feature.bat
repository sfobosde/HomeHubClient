@echo off

for /f %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i

if "%CURRENT_BRANCH%"=="develop" (
    echo You are already on develop.
    exit /b 1
)

git diff --quiet
if errorlevel 1 (
    echo Working tree is not clean.
    echo Commit or stash your changes first.
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
git merge --no-ff "$CURRENT_BRANCH" --no-edit
if errorlevel 1 exit /b 1

echo Pushing develop...
git push origin develop
if errorlevel 1 exit /b 1

echo Returning to %CURRENT_BRANCH%...
git checkout %CURRENT_BRANCH%
if errorlevel 1 exit /b 1

echo.
echo Feature successfully merged into develop.
echo GitHub Actions will now deploy develop.

pause