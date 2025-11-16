from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from supabase import create_client, Client
from main import settings

router = APIRouter()

def get_supabase() -> Client:
    return create_client(settings.supabase_url, settings.supabase_anon_key)

class GoogleAuthRequest(BaseModel):
    credential: str

class AuthResponse(BaseModel):
    access_token: str
    user: dict

@router.post("/google", response_model=AuthResponse)
async def google_auth(auth_request: GoogleAuthRequest, supabase: Client = Depends(get_supabase)):
    try:
        response = supabase.auth.sign_in_with_id_token({
            "provider": "google",
            "token": auth_request.credential
        })

        return AuthResponse(
            access_token=response.session.access_token,
            user={
                "id": response.user.id,
                "email": response.user.email,
                "name": response.user.user_metadata.get("full_name", ""),
                "picture": response.user.user_metadata.get("avatar_url", "")
            }
        )
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))

@router.post("/logout")
async def logout(supabase: Client = Depends(get_supabase)):
    try:
        supabase.auth.sign_out()
        return {"message": "Logged out successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
