# Część projektu poświęcona Backend-owi AI (ollama)

Do testów proszę pamiętać, żeby wybrać model/modele, które są mniejsze (GB) niż ilość pamięci VRAM GPU/RAM CPU.
Im mniejszy model, tym więcej błędów będzie popełniał.
Im większy model, tym wolniej będzie działał.

### Program wymaga uruchomienia w systemie Linux, lub w systemie Windows przez WSL

Program jest w stanie sam wykryć GPU NVIDIA/AMD/INTEL. W przypadku braku posiadania GPU NVIDIA/AMD/INTEL program sam się uruchomi w trybie CPU.
1. Linux:
 - Automatyczne wykrywanie:

	```bash
 	./start.sh --build -d
  	```
 - Wymuszenie trybu CPU:
	
   	```bash
    ./start.sh --cpu --build -d
	```

 - Wymuszenie trybu NVIDIA:

	```bash
 	./start.sh --nvidia --build -d
 	```
 - Wymuszenie trybu AMD:

	```bash
 	./start.sh --amd --build -d
 	```

 - Wymuszenie trybu INTEL:

	```bash
 	./start.sh --intel --build -d
 	```
2. Windows:
 - Automatyczne wykrywanie:
   Należy uruchomić plik `start.bat`. Program automatycznie spawdzi, czy na komputerze jest zainstalowany i skonfigurowany WSL2. Jeśli nie, to wyświetli instrukcję, jak to zrobić. Następnie sprawdzi, czy jest zainstalowany `Docker Desktop`. Na samym końcu gdy będą te dwa kroki już zrobione, to program uruchomi wewnątrz WSL2 skrypt `start.sh`.
 
 - Wymuszenie trybu CPU:

	```DOS
	.\start.bat --cpu --build -d
	```

 - Wymuszenie trybu NVIDIA:

	```DOS
	.\start.bat --nvidia --build -d
	```

 - Wymuszenie trybu AMD:

	```DOS
	.\start.bat --amd --build -d
	```

 - Wymuszenie trybu INTEL:

	```DOS
	.\start.bat --intel --build -d
	```

### Wybór modelu/modeli
Wybrać można którykolwiek model spośród biblioteki ollama https://ollama.com/search . Testowane modele to:
1. llama3.2 - popularny model stworzony przez firmę Meta (dawniej Facebook). Testowany był w dwóch wariantach:
  - llama3.2 (3b) 2.0GB - Na podstawie tego modelu został stworzony asystent-projektu, który ma za zadanie specjalizować się w tematyce związanej z tym projektem.
  - llama3.2:1b 1.3GB
2. gemma3 - popularny model stworzony przez firmę Google na podwalinach flagowego modelu Gemini. Testowany był w jednym wariancie:
  - gemma3:4b 3.3GB
3. dolphincoder - model oparty na StarCoder2 7b oraz 15b. Został stworzony z myślą o pisaniu kodu. Testowany był w jednym wariancie:
  - dolphincoder:7b 4.2GB
4. deepseek-r1 - popularny chiński model stworzony by konkurował z modelami od OpenAI. Testowany był w trzech wariantach:
  - deepseek-r1:7b 4.7GB
  - deepseek-r1:14b 9.0GB
  - deepseek-r1:70b 43GB

### Wymagania
- Docker i Docker Compose
- Poprawnie skonfigurowany NVIDIA Container Toolkit (w przypadku GPU NVIDIA)
- Sterowniki `CUDA NVIDIA`/`AMDGPU ROCm AMD`


### Konfiguracja modeli
By program pobrał modele, należy stworzyć plik `.env` w głównej ścieżce ze zmienną `OLLAMA_MODELS`. Jeśli plik nie zostanie stworzony ręcznie, program sam stworzy wymagany plik na podstawie .env.example:

	
	OLLAMA_MODELS=<tu należy zdefiniować które modele zostaną ściągnięcie. Proszę o oddzielanie modeli przecinkami `,`>
	
 Przykład poprawnie zdefiniowanej zmiennej:
 
 	
  	OLLAMA_MODELS=llama3.2,gemma3:4b,dolphincoder:7b
   	


Aby pobrać nowe modele, należy zrestartować serwis komendą:

	
	docker compose down
	
## Uruchomienie
Aby uruchomić serwis, należy w głównym folderze projektu wykonać komendę:

	
	./start.sh -d --build


Sprawdzenie czy `ollama` skończyła przygotowywać model/modele:

	docker compose logs -f ollama-ai
	
 

### Testowanie

1. Sprawdzenie listy pobranych modeli:

		docker compose exec ollama-ai ollama list

2. Po uruchomieniu i pobraniu modeli, można przetestować API za pomocą `curl`:

	
		curl http://localhost:11434/api/generate -d '{
		"model": "asystent-projektu",
		"prompt": "Czym jest konteneryzacja w kontekscie Dockera?",
		"stream": false
		}'

3. Skrypt testujący wydajność zapamiętywania kontekstu:

		./test_wydajnosci.sh

Jeśli z biegiem testu czas trwania (ms) rosną, to oznacza, że podel poprawnie "zapamiętuje" historie rozmowy.
By test poprawnie działał, należy mieć zainstalowane narzędzie jq.

Instalacja jq:
1. Ubuntu/Debian

		sudo apt install jq

2. Fedora

		sudo dnf install jq

3. Arch

		sudo pacman -S jq