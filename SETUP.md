# TAAI Setup Guide

This guide will walk you through setting up the TAAI application from scratch.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js 18+** and npm
- **Python 3.9+** and pip
- A **Supabase** account (free tier works)
- A **Google Cloud Platform** account
- An **Anthropic** API key

## Step 1: Clone the Repository

```bash
git clone <repository-url>
cd taai
```

## Step 2: Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to Project Settings > API
3. Copy your Project URL and anon public key
4. The database schema has already been applied via migrations

### Enable Google OAuth in Supabase

1. Go to Authentication > Providers in your Supabase dashboard
2. Enable Google provider
3. Add your Google OAuth credentials (see step 3)

## Step 3: Google Cloud Platform Setup

### Create OAuth 2.0 Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select an existing one
3. Enable the Google Classroom API:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Classroom API"
   - Click "Enable"
4. Create OAuth 2.0 credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth client ID"
   - Choose "Web application"
   - Add authorized redirect URIs:
     - `http://localhost:5173/auth/callback` (development)
     - `https://your-domain.com/auth/callback` (production)
     - Your Supabase auth callback URL
   - Save the Client ID and Client Secret

### Configure OAuth Consent Screen

1. Go to "APIs & Services" > "OAuth consent screen"
2. Fill in the required information
3. Add scopes:
   - `https://www.googleapis.com/auth/classroom.courses.readonly`
   - `https://www.googleapis.com/auth/classroom.coursework.students`
   - `https://www.googleapis.com/auth/classroom.rosters.readonly`
4. Save changes

## Step 4: Anthropic API Key

1. Sign up at [Anthropic](https://www.anthropic.com)
2. Generate an API key from your account settings
3. Copy the API key for later use

## Step 5: Environment Configuration

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and fill in your credentials:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_SUPABASE_ANON_KEY=your_anon_key

GOOGLE_CLIENT_ID=your_google_client_id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your_google_client_secret

ANTHROPIC_API_KEY=sk-ant-api03-...
```

## Step 6: Install Dependencies

### Frontend

```bash
cd frontend
npm install
```

### Backend

```bash
cd backend
pip install -r requirements.txt
```

Or use virtual environment (recommended):

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Step 7: Run the Application

### Development Mode

Open two terminal windows:

**Terminal 1 - Frontend:**
```bash
cd frontend
npm run dev
```

The frontend will be available at http://localhost:5173

**Terminal 2 - Backend:**
```bash
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The backend API will be available at http://localhost:8000

### API Documentation

Once the backend is running, you can access:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Step 8: First Time Setup

1. Open http://localhost:5173 in your browser
2. Click "Sign In" and authenticate with Google
3. Grant the required permissions for Google Classroom
4. You'll be redirected to the dashboard

## Troubleshooting

### Frontend won't start
- Ensure all dependencies are installed: `npm install`
- Check that port 5173 is not in use
- Verify your `.env` file has correct Supabase credentials

### Backend won't start
- Ensure Python 3.9+ is installed: `python --version`
- Verify all dependencies are installed: `pip install -r requirements.txt`
- Check that port 8000 is not in use

### Google OAuth not working
- Verify redirect URIs in Google Cloud Console
- Check that Google Classroom API is enabled
- Ensure OAuth consent screen is properly configured
- Verify credentials in `.env` file

### Database connection issues
- Verify Supabase URL and anon key in `.env`
- Check that RLS policies are properly set up
- Ensure you're using the correct Supabase project

### Authentication errors
- Clear browser cookies and cache
- Verify Google OAuth provider is enabled in Supabase
- Check that redirect URLs match in both Google Console and Supabase

## Production Deployment

### Frontend (Recommended: Vercel, Netlify, or similar)

1. Build the frontend:
```bash
cd frontend
npm run build
```

2. Deploy the `dist` folder to your hosting service
3. Update environment variables with production values
4. Update Google OAuth redirect URIs

### Backend (Recommended: Railway, Render, or similar)

1. Deploy the backend folder to your hosting service
2. Set environment variables
3. Ensure Python 3.9+ runtime
4. Use production WSGI server (gunicorn or similar)

Example for gunicorn:
```bash
pip install gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker
```

### Database (Supabase)

Your database is already hosted on Supabase - no additional deployment needed!

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Google Classroom API](https://developers.google.com/classroom)
- [Anthropic API Documentation](https://docs.anthropic.com)
- [FastAPI Documentation](https://fastapi.tiangolo.com)
- [Vue 3 Documentation](https://vuejs.org)

## Support

For issues and questions:
1. Check existing documentation
2. Review error messages carefully
3. Consult the troubleshooting section above
4. Check application logs for detailed error information

## License

GPL-3.0 - See LICENSE file for details
