from fastapi import APIRouter, HTTPException, Depends, Header
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from supabase import Client
from routers.auth import get_supabase

router = APIRouter()

class AssignmentResponse(BaseModel):
    id: str
    google_assignment_id: str
    classroom_id: str
    creator_id: Optional[str]
    title: str
    description: Optional[str]
    max_points: float
    due_date: Optional[str]
    created_at: str
    updated_at: str

class CreateAssignmentRequest(BaseModel):
    google_assignment_id: str
    classroom_id: str
    title: str
    description: Optional[str] = None
    max_points: float = 100.0
    due_date: Optional[str] = None

@router.get("/classroom/{classroom_id}", response_model=List[AssignmentResponse])
async def get_assignments_by_classroom(
    classroom_id: str,
    authorization: str = Header(None),
    supabase: Client = Depends(get_supabase)
):
    try:
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization header required")

        result = supabase.table("assignments").select("*").eq("classroom_id", classroom_id).execute()
        return result.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{assignment_id}", response_model=AssignmentResponse)
async def get_assignment(
    assignment_id: str,
    authorization: str = Header(None),
    supabase: Client = Depends(get_supabase)
):
    try:
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization header required")

        result = supabase.table("assignments").select("*").eq("id", assignment_id).maybeSingle().execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Assignment not found")

        return result.data
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/", response_model=AssignmentResponse)
async def create_assignment(
    assignment: CreateAssignmentRequest,
    authorization: str = Header(None),
    supabase: Client = Depends(get_supabase)
):
    try:
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization header required")

        result = supabase.table("assignments").insert(assignment.model_dump()).execute()
        return result.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
