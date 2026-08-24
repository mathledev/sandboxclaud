@echo off
setlocal
cd /d "%~dp0"

set "DEPOT=https://github.com/mathledev/sandboxclaud.git"
set "PAGE=https://github.com/mathledev/sandboxclaud"

echo ==========================================
echo   Envoi des modifications sur GitHub
echo ==========================================
echo.

where git >nul 2>&1
if errorlevel 1 (
  echo [ERREUR] git n'est pas installe, ou pas dans le PATH.
  echo Installe Git for Windows : https://git-scm.com/download/win
  echo Pendant l'installation, garde toutes les options par defaut.
  echo Ferme puis rouvre cette fenetre apres l'installation.
  echo.
  pause
  exit /b 1
)

if not exist ".git" (
  echo Initialisation du depot local...
  git init >nul || goto :err
)

git config user.email >nul 2>&1
if errorlevel 1 (
  echo Configuration de l'identite git pour ce depot...
  git config user.name "mathledev"
  git config user.email "mathledev@users.noreply.github.com"
)

git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo Liaison au depot distant %DEPOT% ...
  git remote add origin "%DEPOT%" || goto :err
)

git rev-parse --verify HEAD >nul 2>&1
if errorlevel 1 (
  echo Premiere synchronisation avec GitHub...
  git fetch origin || goto :err
  git symbolic-ref HEAD refs/heads/main
  git reset origin/main || goto :err
)

for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD') do set "BRANCHE=%%b"
if not "%BRANCHE%"=="main" (
  echo Renommage de la branche %BRANCHE% en main...
  git branch -M main || goto :err
)

set "MSG=%*"
if "%MSG%"=="" set "MSG=Mise a jour du %DATE% a %TIME%"

git add -A || goto :err

git diff --cached --quiet
if not errorlevel 1 (
  echo Aucune modification a envoyer : tout est deja a jour.
  echo.
  pause
  exit /b 0
)

echo.
echo Fichiers concernes :
git diff --cached --name-status
echo.

git commit -m "%MSG%" || goto :err
git pull --rebase origin main || goto :err
git push -u origin main || goto :err

echo.
echo ==========================================
echo   OK - modifications envoyees sur GitHub
echo   %PAGE%
echo ==========================================
echo.
pause
exit /b 0

:err
echo.
echo [ERREUR] Une commande git a echoue. Le message juste au-dessus
echo indique la cause. En cas de conflit, previens Claude en copiant
echo le message.
echo.
pause
exit /b 1
