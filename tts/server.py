import os
import tempfile

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
from starlette.background import BackgroundTask
from gtts import gTTS


app = FastAPI(title="UTH ChatBot TTS")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["POST", "OPTIONS"],
    allow_headers=["*"],
)


class TextRequest(BaseModel):
    text: str


def cleanup_file(path: str) -> None:
    try:
        if os.path.exists(path):
            os.remove(path)
    except OSError:
        pass


@app.get("/health")
async def health() -> dict:
    return {"ok": True}


@app.post("/api/tts")
async def text_to_speech(request: TextRequest) -> FileResponse:
    text = request.text.strip()
    if not text:
        raise HTTPException(status_code=400, detail="Vui lòng cung cấp văn bản để đọc.")

    text = text[:4000]
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".mp3")
    tmp_path = tmp.name
    tmp.close()

    try:
        tts = gTTS(text=text, lang="vi", slow=False)
        tts.save(tmp_path)
        return FileResponse(
            tmp_path,
            media_type="audio/mpeg",
            filename="response.mp3",
            background=BackgroundTask(cleanup_file, tmp_path),
        )
    except Exception as exc:
        cleanup_file(tmp_path)
        raise HTTPException(status_code=500, detail=str(exc)) from exc
