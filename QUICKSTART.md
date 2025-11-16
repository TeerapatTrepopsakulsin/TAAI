# TAAI Quick Start Guide

Get up and running with TAAI in 5 minutes!

## Prerequisites

- Node.js 18+ and npm installed
- Python 3.9+ and pip installed
- A Supabase account (free tier)
- Google Cloud Platform account
- Anthropic API key

## Quick Setup (5 Steps)

### 1. Install Dependencies

```bash
# Install frontend dependencies
cd frontend
npm install
cd ..

# Install backend dependencies
cd backend
pip install -r requirements.txt
cd ..
```

### 2. Configure Environment

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` with your credentials:

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_SUPABASE_ANON_KEY=your_supabase_anon_key
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
ANTHROPIC_API_KEY=your_anthropic_api_key
```

### 3. Setup Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. The database schema is already applied via migrations
3. Enable Google OAuth in Authentication > Providers

### 4. Configure Google Cloud

1. Enable Google Classroom API in [Google Cloud Console](https://console.cloud.google.com)
2. Create OAuth 2.0 credentials
3. Add redirect URI: `http://localhost:5173/auth/callback`
4. Copy Client ID and Secret to `.env`

### 5. Run the Application

Open two terminals:

**Terminal 1 - Frontend:**
```bash
cd frontend
npm run dev
```
Visit: http://localhost:5173

**Terminal 2 - Backend:**
```bash
cd backend
uvicorn main:app --reload
```
API at: http://localhost:8000

## First Login

1. Go to http://localhost:5173
2. Click "Sign In"
3. Authenticate with Google
4. Grant Google Classroom permissions
5. You're in! Start using TAAI

## What's Next?

- **Add Classrooms**: Connect your Google Classroom courses
- **Create Criteria**: Define grading rubrics for assignments
- **Upload Materials**: Add knowledge bases and baseline solutions
- **Start Grading**: Let AI help grade student submissions

## Need Help?

- Read the detailed [SETUP.md](./SETUP.md) guide
- Check [ARCHITECTURE.md](./ARCHITECTURE.md) for technical details
- Review the [README.md](./README.md) for feature overview

## Common Issues

**Port already in use?**
```bash
# Change frontend port
cd frontend
npm run dev -- --port 3000

# Change backend port
cd backend
uvicorn main:app --reload --port 8001
```

**Dependencies not installing?**
```bash
# Clear npm cache
npm cache clean --force

# Clear pip cache
pip cache purge
```

**Database connection failing?**
- Verify Supabase URL and key in `.env`
- Check your Supabase project is active
- Ensure migrations were applied

## Production Deployment

Ready for production? Check out:
- [SETUP.md](./SETUP.md) - Production deployment section
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Scalability considerations

---

**Happy Grading!** 🎓
