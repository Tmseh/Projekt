#!/bin/bash
set -e

/bin/ollama serve &

sleep 5
echo "Pobieranie modelu qwen2.5vl..."
ollama pull qwen2.5vl

echo "Model pobrany. Serwer AI jest gotowy."

wait $!
