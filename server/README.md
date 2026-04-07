# StudyMate AI proxy (OpenRouter)

This folder runs a local proxy to avoid browser CORS and to keep API keys out of the Flutter web app.

## Run

```bat
cd "c:\Users\Сабит\Desktop\Ernur Project\studymate_ai\server"
set OPENROUTER_API_KEY=YOUR_KEY_HERE
set OPENROUTER_MODEL=openai/gpt-4o-mini
npm start
```

Then the proxy is available at `http://localhost:8787/chat`.

## Optional headers (recommended by OpenRouter)

```bat
set APP_URL=http://localhost:xxxxx
set APP_NAME=StudyMate AI
```

