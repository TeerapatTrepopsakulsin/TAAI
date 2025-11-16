from fastapi import APIRouter, HTTPException, Depends, Header
from pydantic import BaseModel
from typing import List, Optional
from supabase import Client
from routers.auth import get_supabase

router = APIRouter()

class ClassroomResponse(BaseModel):
    id: str
    google_course_id: str
    name: str
    section: Optional[str]
    description: Optional[str]
    owner_id: str
    created_at: str
    updated_at: str

@router.get("/", response_model=List[ClassroomResponse])
async def get_classrooms(
    authorization: str = Header(None),
    supabase: Client = Depends(get_supabase)
):
    try:
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization header required")

        result = supabase.table("google_classrooms").select("*").execute()
        return result.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{classroom_id}", response_model=ClassroomResponse)
async def get_classroom(
    classroom_id: str,
    authorization: str = Header(None),
    supabase: Client = Depends(get_supabase)
):
    try:
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization header required")

        result = supabase.table("google_classrooms").select("*").eq("id", classroom_id).maybeSingle().execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Classroom not found")

        return result.data
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
