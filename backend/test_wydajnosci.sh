#!/bin/bash

# --- Konfiguracja Testu ---
# Zmień te wartości, aby testować różne scenariusze
MODEL_NAME="llama3.2:3b"
OLLAMA_HOST="http://localhost:11434"
NUM_TURNS=10 # Ile rund rozmowy chcesz zasymulować
INITIAL_PROMPT="Moim ulubionym instrumentem jest gitara klasyczna. Zapamiętaj tę informację."
FOLLOW_UP_PROMPT="Jaki jest mój ulubiony instrument?"
# -------------------------

# Inicjalizacja zmiennych
CONTEXT="" # Na początku kontekst jest pusty

echo "Rozpoczynam test wydajności dla modelu: $MODEL_NAME"
echo "Liczba tur w rozmowie: $NUM_TURNS"
echo "----------------------------------------------------"

# Pętla symulująca rozmowę
for i in $(seq 1 $NUM_TURNS)
do
    # Użyj innego promptu dla pierwszej i kolejnych tur
    if [ $i -eq 1 ]; then
        PROMPT=$INITIAL_PROMPT
    else
        PROMPT=$FOLLOW_UP_PROMPT
    fi

    echo -n "Tura $i: Wysyłanie zapytania... "

    # Bezpieczne budowanie obiektu JSON za pomocą jq
    # Sprawdza, czy zmienna CONTEXT jest pusta. Jeśli tak, nie dodaje klucza "context".
    if [ -z "$CONTEXT" ]; then
        JSON_PAYLOAD=$(jq -n \
                        --arg model "$MODEL_NAME" \
                        --arg prompt "$PROMPT" \
                        '{model: $model, prompt: $prompt, stream: false}')
    else
        JSON_PAYLOAD=$(jq -n \
                        --arg model "$MODEL_NAME" \
                        --arg prompt "$PROMPT" \
                        --argjson context "$CONTEXT" \
                        '{model: $model, prompt: $prompt, stream: false, context: $context}')
    fi

    # Wykonaj zapytanie i zapisz odpowiedź
    RESPONSE=$(curl -s "$OLLAMA_HOST/api/generate" -d "$JSON_PAYLOAD")

    # Wyciągnij nowy kontekst i czas trwania z odpowiedzi JSON za pomocą jq
    CONTEXT=$(echo "$RESPONSE" | jq '.context')
    DURATION_NS=$(echo "$RESPONSE" | jq '.total_duration')

    # Sprawdź, czy nie wystąpił błąd
    if [ "$CONTEXT" == "null" ]; then
        echo "BŁĄD! Nie otrzymano kontekstu. Odpowiedź serwera:"
        echo "$RESPONSE"
        exit 1
    fi

    # Przelicz czas z nanosekund na milisekundy dla czytelności
    DURATION_MS=$(echo "$DURATION_NS / 1000000" | bc)

    echo "Otrzymano odpowiedź. Czas trwania: $DURATION_MS ms"
done

echo "----------------------------------------------------"
echo "Test zakończony pomyślnie."
