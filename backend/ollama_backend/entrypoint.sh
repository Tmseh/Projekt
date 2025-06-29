#!/bin/bash
set -e

# Uruchom główny proces Ollama w tle
/bin/ollama serve &
pid=$!
sleep 5

# Pobieranie modeli zdefiniowanych w .env
MODELS_TO_PULL=$(echo $OLLAMA_MODELS | sed 's/,/ /g')
echo ">>> Rozpoczynam pobieranie modeli bazowych: $OLLAMA_MODELS"
for model in $MODELS_TO_PULL
do
  echo "--- Sprawdzanie modelu: $model ---"
  ollama pull $model
done
echo ">>> Zakończono sprawdzanie modeli bazowych."
echo ""

# Definicja naszego spersonalizowanego modelu
CUSTOM_MODEL_NAME="asystent-projektu"
MODELFILE_PATH="/ollama_backend/Modelfile"

echo ">>> Sprawdzanie spersonalizowanego modelu: $CUSTOM_MODEL_NAME..."

# Sprawdź, czy spersonalizowany model już istnieje
if ! ollama list | grep -q "$CUSTOM_MODEL_NAME"; then
    echo "Model '$CUSTOM_MODEL_NAME' nie istnieje. Tworzenie na podstawie $MODELFILE_PATH..."

    # Sprawdź, czy plik Modelfile na pewno istnieje w kontenerze
    if [ -f "$MODELFILE_PATH" ]; then
        ollama create "$CUSTOM_MODEL_NAME" -f "$MODELFILE_PATH"
        echo "Model '$CUSTOM_MODEL_NAME' zostal pomyślnie utworzony."
    else
        echo "BŁĄD: Nie można utworzyć modelu, ponieważ nie znaleziono pliku '$MODELFILE_PATH' wewnątrz kontenera!"
    fi
else
    echo "Model '$CUSTOM_MODEL_NAME' już istnieje. Pomijam tworzenie."
fi

echo ""
echo ">>> Serwis jest gotowy do pracy."

# Czekaj na zakończenie głównego procesu Ollama
wait $pid
