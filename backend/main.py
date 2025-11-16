from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic_settings import BaseSettings
import os
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    supabase_url: str = os.getenv("VITE_SUPABASE_URL", "")
    supabase_anon_key: str = os.getenv("VITE_SUPABASE_SUPABASE_ANON_KEY", "")
    google_client_id: str = os.getenv("GOOGLE_CLIENT_ID", "")
    google_client_secret: str = os.getenv("GOOGLE_CLIENT_SECRET", "")
    anthropic_api_key: str = os.getenv("ANTHROPIC_API_KEY", "")

settings = Settings()

app = FastAPI(title="TAAI API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "TAAI API is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

from routers import auth, classrooms, assignments, grading, files

app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(classrooms.router, prefix="/api/classrooms", tags=["Classrooms"])
app.include_router(assignments.router, prefix="/api/assignments", tags=["Assignments"])
app.include_router(grading.router, prefix="/api/grading", tags=["Grading"])
app.include_router(files.router, prefix="/api/files", tags=["Files"])
