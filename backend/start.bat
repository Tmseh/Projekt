@echo off
REM --- Sprawdzanie czy istnieje plik .env ---
if not exist .env (
    echo Plik .env nie istnieje. Tworzenie pliku na podstawie .env.example...
    if exist .env.example (
        copy .env.example .env > nul
        echo Plik .env zostal utworzony.
    ) else (
        echo UWAGA: Nie odnaleziono pliku .env.example!
    )
)
REM ------------------------------------------
ECHO.
ECHO Sprawdzanie srodowiska Windows dla projektu lokalnego asystenta AI...
ECHO ===================================================================

REM Krok 1: Sprawdzanie, czy WSL jest zainstalowany i dostepny.
wsl.exe -l -v > nul 2> nul
if %errorlevel% neq 0 (
    ECHO.
    ECHO [BLAD] Windows Subsystem for Linux (WSL 2) nie jest zainstalowany lub skonfigurowany.
    ECHO To srodowisko jest wymagane do uruchomienia linuksowych kontenerow Docker.
    ECHO.
    ECHO Jak to naprawic?
    ECHO 1. Otworz PowerShell jako Administrator.
    ECHO 2. Wpisz komende: wsl --install
    ECHO 3. Uruchom ponownie komputer i sprobuj jeszcze raz.
    ECHO.
    pause
    exit /b 1
)
ECHO [OK] Wykryto Windows Subsystem for Linux (WSL 2).

REM Krok 2: Sprawdzanie, czy komenda 'docker' jest dostepna w systemie.
where docker > nul 2> nul
if %errorlevel% neq 0 (
    ECHO.
    ECHO [BLAD] Komenda 'docker' nie zostala znaleziona.
    ECHO Upewnij sie, ze masz zainstalowany Docker Desktop for Windows i jest on uruchomiony.
    ECHO Pobierz go ze strony: https://www.docker.com/products/docker-desktop/
    ECHO Po instalacji upewnij sie, ze w ustawieniach Docker Desktop jest wlaczona integracja z WSL 2.
    ECHO.
    pause
    exit /b 1
)
ECHO [OK] Wykryto instalacje Docker.

ECHO.
ECHO Srodowisko wyglada na gotowe. Przekazuje sterowanie do skryptu start.sh wewnatrz WSL...
ECHO ------------------------------------------------------------------------------------
ECHO.

REM Krok 3: Uruchomienie linuksowego skryptu start.sh wewnatrz WSL, przekazujac wszystkie argumenty.
REM %* to specjalna zmienna w plikach .bat, ktora oznacza "wszystkie argumenty przekazane do tego skryptu".
wsl.exe ./start.sh %*

ECHO.
ECHO ------------------------------------------------------------------------------------
ECHO Skrypt start.bat zakonczyl dzialanie.
pause

