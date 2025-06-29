#!/bin/bash

# Sprawdzenie czy istnieje plik .env
if [ ! -f .env]; then
    echo "Plik .env nie istnieje. Tworzenie pliku na podstawie szablonu .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "Plik .env zostal utworzony."
    else
        echo "UWAGA: Nie odnaleziono pliku .env.example! Uzyte zostana domyslne wartosci."
    fi
fi

# Domyślna konfiguracja to plik bazowy (CPU)
COMPOSE_FILES="-f docker-compose.yml"
MODE="CPU"

# --- Zunifikowana logika wyboru trybu ---

# Sprawdź, czy użytkownik podał flagę wyboru
if [[ "$1" == "--nvidia" ]]; then
    echo "Wymuszono tryb NVIDIA."
    COMPOSE_FILES="-f docker-compose.yml -f docker-compose.nvidia.yml"
    MODE="NVIDIA"
elif [[ "$1" == "--amd" ]]; then
    echo "Wymuszono tryb AMD."
    COMPOSE_FILES="-f docker-compose.yml -f docker-compose.amd.yml"
    MODE="AMD"
elif [[ "$1" == "--intel" ]]; then
    echo "Wymuszono tryb INTEL."
    COMPOSE_FILES="-f docker-compose.yml -f docker-compose.intel.yml"
    MODE="INTEL"
elif [[ "$1" == "--cpu" ]]; then
    echo "Wymuszono tryb CPU."
    # Nic nie trzeba dodawać, plik bazowy jest już wybrany
else
    # Jeśli nie podano flagi, uruchom auto-detekcję
    echo "Trwa automatyczne wykrywanie GPU"
    if command -v nvidia-smi &> /dev/null; then
        echo "Wykryto GPU NVIDIA. Używam konfiguracji NVIDIA."
        COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.nvidia.yml"
        MODE="NVIDIA"
    elif [ -e /dev/kfd ]; then
        echo "Wykryto GPU AMD. Używam konfiguracji AMD."
        COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.amd.yml"
        MODE="AMD"
    elif lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq "intel"; then
        echo "Wykryto GPU INTEL. Używam konfiguracji INTEL."
        COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.intel.yml"
        MODE="INTEL"
    else
        echo "Nie wykryto kompatybilnego GPU. Używam konfiguracji CPU."
    fi
fi

# --- Uruchomienie docker-compose z wybraną konfiguracją ---
echo "____________________________________________________"
echo "Uruchamianie serwisu w trybie: $MODE"
echo "____________________________________________________"

# Przekaż argumenty (np. -d, --build) do docker-compose
# Jeśli podano flagę trybu, pomiń ją ($@:2), w przeciwnym razie przekaż wszystko ($@)
if [[ "$1" == --* ]]; then
    docker compose $COMPOSE_FILES up "${@:2}"
else
    docker compose $COMPOSE_FILES up "$@"
fi
