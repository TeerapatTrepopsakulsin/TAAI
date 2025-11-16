from fastapi import APIRouter, HTTPException, UploadFile, File, Depends, Header
from pydantic import BaseModel
from typing import Optional
from supabase import Client
from routers.auth import get_supabase
import base64

router = APIRouter()

class FileUploadResponse(BaseModel):
    file_url: str
    file_name: str
    file_type: str

@router.post("/upload", response_model=FileUploadResponse)
async def upload_file(
    file: UploadFile = File(...),
    authorization: str = Header(None),
    supabase: Client = Depends(get_supabase)
):
    try:
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization header required")

        contents = await file.read()

        file_path = f"uploads/{file.filename}"

        result = supabase.storage.from_("taai-files").upload(file_path, contents)

        public_url = supabase.storage.from_("taai-files").get_public_url(file_path)

        return FileUploadResponse(
            file_url=public_url,
            file_name=file.filename,
            file_type=file.content_type or "application/octet-stream"
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
