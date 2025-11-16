# TAAI - The AI Grader

An AI-powered educational assistant that integrates with Google Classroom to automate and assist in grading student homework and assignments.

## Features

- **Smart Grading**: AI analyzes student submissions using customizable grading criteria
- **Google Classroom Integration**: Seamlessly sync assignments and grades
- **Multi-Instructor Support**: Grade assignments from any instructor in shared courses
- **Knowledge Base**: Upload slides and documents for AI reference
- **Flexible Grading Criteria**: Create and customize rubrics for each assignment
- **Late Submission Policies**: Configure automatic penalty deductions
- **Feedback Loop**: Improve AI accuracy through user feedback
- **Export Functionality**: Export grades to Google Sheets

## Tech Stack

### Frontend
- Vue 3 with TypeScript
- Vite for build tooling
- Tailwind CSS for styling
- Vue Router for navigation
- Pinia for state management
- Supabase client for authentication and database

### Backend
- Python with FastAPI
- Supabase for database and authentication
- Google Classroom API integration
- Anthropic Claude API for AI grading
- OCR support for PDF and image submissions

## Project Structure

```
.
├── frontend/           # Vue 3 frontend application
│   ├── src/
│   │   ├── views/      # Page components
│   │   ├── components/ # Reusable components
│   │   ├── stores/     # Pinia stores
│   │   ├── router/     # Vue Router configuration
│   │   ├── services/   # API and service clients
│   │   └── types/      # TypeScript type definitions
│   └── package.json
│
├── backend/            # Python FastAPI backend
│   ├── routers/        # API route handlers
│   ├── services/       # Business logic
│   ├── models/         # Data models
│   ├── main.py         # Application entry point
│   └── requirements.txt
│
└── .env                # Environment variables

## Setup Instructions

### Prerequisites

- Node.js 18+ and npm
- Python 3.9+
- Supabase account
- Google Cloud Platform account (for Classroom API)
- Anthropic API key (for Claude AI)

### Environment Variables

Create a `.env` file in the project root with:

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_SUPABASE_ANON_KEY=your_supabase_anon_key
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
ANTHROPIC_API_KEY=your_anthropic_api_key
```

### Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

### Backend Setup

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Database Setup

The database schema is automatically created via Supabase migrations. All tables include:
- Row Level Security (RLS) policies
- Proper foreign key constraints
- Indexes for performance
- Secure user data access controls

## Database Schema

### Core Tables

- `users` - User profiles linked to Google accounts
- `google_classrooms` - Connected Google Classroom courses
- `classroom_members` - User memberships with roles
- `assignments` - Assignment information
- `submissions` - Student submissions
- `grades` - Grading results
- `grading_criteria` - Rubrics and criteria
- `knowledge_bases` - Reference materials
- `baseline_solutions` - Model solutions
- `late_submission_policies` - Late penalty configurations
- `google_tokens` - OAuth tokens (encrypted)

## Security

- All database tables use Row Level Security (RLS)
- Google OAuth for authentication
- Encrypted token storage
- Role-based access control
- Compliance with student data privacy laws

## Development

### Frontend Development

```bash
cd frontend
npm run dev     # Start dev server
npm run build   # Build for production
npm run preview # Preview production build
```

### Backend Development

```bash
cd backend
uvicorn main:app --reload  # Start with hot reload
```

## License

GNU General Public License v3.0 - see LICENSE file for details

## Copyright

TAAI - The AI Grader integrated with Google Classroom
Copyright (C) 2025 Teerapat Trepopsakulsin

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
