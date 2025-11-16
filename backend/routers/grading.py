from fastapi import APIRouter, HTTPException, Depends, Header
from pydantic import BaseModel
from typing import List, Optional
from supabase import Client
from routers.auth import get_supabase

router = APIRouter()

class GradingCriteriaResponse(BaseModel):
    id: str
    assignment_id: str
    created_by: Optional[str]
    subtask_name: str
    description: str
    max_points: float
    order_index: int
    is_ai_generated: bool
    created_at: str
    updated_at: str

class CreateGradingCriteriaRequest(BaseModel):
    assignment_id: str
    subtask_name: str
    description: str
    max_points: float
    order_index: int = 0
    is_ai_generated: bool = False

class GradeResponse(BaseModel):
    id: str
    submission_id: str
    graded_by: Optional[str]
    total_points: float
    late_penalty: float
    final_score: float
    feedback: Optional[str]
    is_ai_generated: bool
    graded_at: str
    updated_at: str

class CreateGradeRequest(BaseModel):
    submission_id: str
    total_points: float
    late_penalty: float = 0.0
    final_score: float
    feedback: Optional[str] = None
    is_ai_generated: bool = False

@router.get("/criteria/assignment/{assignment_id}", response_model=List[GradingCriteriaResponse])
async def get_grading_criteria(
    assignment_id: str,
    authorization: str = Header(None),
    supabase: Client = Depends(get_supabase)
):
    try:
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization header required")

        result = supabase.table("grading_criteria").select("*").eq("assignment_id", assignment_id).order("order_index").execute()
        return result.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/criteria", response_model=GradingCriteriaResponse)
async def create_grading_criteria(
    criteria: CreateGradingCriteriaRequest,
    authorization: str = Header(None),
    supabase: Client = Depends(get_supabase)
):
    try:
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization header required")

        result = supabase.table("grading_criteria").insert(criteria.model_dump()).execute()
        return result.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/grades", response_model=GradeResponse)
async def create_grade(
    grade: CreateGradeRequest,
    authorization: str = Header(None),
    supabase: Client = Depends(get_supabase)
):
    try:
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization header required")

        result = supabase.table("grades").insert(grade.model_dump()).execute()
        return result.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/grades/submission/{submission_id}", response_model=GradeResponse)
async def get_grade_by_submission(
    submission_id: str,
    authorization: str = Header(None),
    supabase: Client = Depends(get_supabase)
):
    try:
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization header required")

        result = supabase.table("grades").select("*").eq("submission_id", submission_id).maybeSingle().execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Grade not found")

        return result.data
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
