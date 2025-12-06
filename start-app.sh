#!/bin/bash

docker compose up --remove-orphans -d

docker exec -it ollama bash -c 'while ! curl -s http://localhost:11434 > /dev/null; do echo "Waiting for Ollama server..."; sleep 2; done; echo "Ollama server is running. Pulling model..."; ollama pull hf.co/mradermacher/Arctic-Text2SQL-R1-7B-GGUF:Arctic-Text2SQL-R1-7B.Q8_0.gguf'
