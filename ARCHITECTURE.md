# TAAI Architecture Overview

## System Architecture

TAAI is built as a modern web application with a clear separation between frontend, backend, and database layers.

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Vue 3 + TypeScript + Tailwind CSS                  │   │
│  │  - Vue Router (Navigation)                          │   │
│  │  - Pinia (State Management)                         │   │
│  │  - Supabase Client (Auth & DB)                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ HTTPS/WebSocket
                          │
┌─────────────────────────────────────────────────────────────┐
│                         Backend                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  FastAPI (Python)                                   │   │
│  │  - Google Classroom API Integration                 │   │
│  │  - Anthropic Claude API (AI Grading)                │   │
│  │  - OCR Processing (Tesseract/pdf2image)             │   │
│  │  - File Upload/Processing                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ PostgreSQL Protocol
                          │
┌─────────────────────────────────────────────────────────────┐
│                    Database (Supabase)                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  PostgreSQL + Row Level Security                    │   │
│  │  - User & Auth Management                           │   │
│  │  - Classroom & Assignment Data                      │   │
│  │  - Grading & Submission Records                     │   │
│  │  - Real-time Subscriptions                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Frontend Architecture

### Component Structure

```
src/
├── views/              # Page-level components
│   ├── HomeView.vue
│   ├── LoginView.vue
│   ├── DashboardView.vue
│   ├── ClassroomsView.vue
│   ├── ClassroomDetailView.vue
│   ├── AssignmentDetailView.vue
│   ├── GradingView.vue
│   └── AuthCallbackView.vue
│
├── components/         # Reusable components
│   ├── common/        # Shared UI components
│   ├── classroom/     # Classroom-specific
│   └── grading/       # Grading-specific
│
├── stores/            # Pinia state management
│   ├── auth.ts        # Authentication state
│   ├── classroom.ts   # Classroom data
│   └── grading.ts     # Grading state
│
├── router/            # Vue Router configuration
│   └── index.ts       # Route definitions & guards
│
├── services/          # API & external services
│   ├── supabase.ts    # Supabase client
│   ├── api.ts         # Backend API client
│   └── google.ts      # Google Classroom
│
└── types/             # TypeScript definitions
    ├── models.ts      # Data models
    └── api.ts         # API types
```

### State Management Flow

```
User Action → Component → Store → Service → API
                                     ↓
User Update ← Component ← Store ← Response
```

### Key Features

1. **Reactive UI**: Vue 3 Composition API for optimal reactivity
2. **Type Safety**: Full TypeScript coverage
3. **Route Guards**: Authentication-based navigation
4. **Real-time Updates**: Supabase subscriptions for live data
5. **Responsive Design**: Tailwind CSS with mobile-first approach

## Backend Architecture

### API Structure

```
backend/
├── main.py            # FastAPI application entry
├── routers/           # API endpoints
│   ├── auth.py        # Authentication
│   ├── classrooms.py  # Classroom management
│   ├── assignments.py # Assignment CRUD
│   ├── grading.py     # Grading operations
│   └── files.py       # File upload/processing
│
├── services/          # Business logic
│   ├── google_classroom.py
│   ├── ai_grading.py
│   ├── ocr_processor.py
│   └── export.py
│
└── models/            # Data models
    ├── schemas.py     # Pydantic models
    └── database.py    # DB models
```

### API Endpoints

#### Authentication
- `POST /api/auth/google` - Google OAuth sign-in
- `POST /api/auth/logout` - Sign out

#### Classrooms
- `GET /api/classrooms` - List classrooms
- `GET /api/classrooms/{id}` - Get classroom details

#### Assignments
- `GET /api/assignments/classroom/{id}` - List assignments
- `GET /api/assignments/{id}` - Get assignment details
- `POST /api/assignments` - Create assignment

#### Grading
- `GET /api/grading/criteria/assignment/{id}` - Get criteria
- `POST /api/grading/criteria` - Create criteria
- `POST /api/grading/grades` - Submit grade
- `GET /api/grading/grades/submission/{id}` - Get grade

#### Files
- `POST /api/files/upload` - Upload file

### External Integrations

#### Google Classroom API
- Sync courses and assignments
- Retrieve student submissions
- Post grades back to Classroom
- Manage course rosters

#### Anthropic Claude API
- Analyze submission content
- Generate grading suggestions
- Provide feedback based on criteria
- Learn from user corrections

#### OCR Processing
- Extract text from PDF files (pdf2image)
- Process handwritten submissions (Tesseract)
- Convert images to analyzable text

## Database Schema

### Core Entities

1. **Users** - Teacher and student profiles
2. **Google Classrooms** - Connected courses
3. **Classroom Members** - User-classroom relationships with roles
4. **Assignments** - Assignment definitions
5. **Submissions** - Student work
6. **Grades** - Grading results
7. **Grading Criteria** - Rubrics and evaluation criteria

### Relationships

```
Users ─┬─ Google Classrooms (owner)
       ├─ Classroom Members
       ├─ Assignments (creator)
       ├─ Submissions (student)
       ├─ Grades (grader)
       ├─ Knowledge Bases (uploader)
       └─ Grade Feedback

Google Classrooms ─┬─ Classroom Members
                   ├─ Assignments
                   └─ Late Submission Policies

Assignments ─┬─ Submissions
             ├─ Grading Criteria
             ├─ Knowledge Bases
             ├─ Baseline Solutions
             └─ Late Submission Policies

Submissions ─┬─ Grades
             └─ Grade Criteria Scores

Grades ─┬─ Grade Criteria Scores
        └─ Grade Feedback
```

### Security Model

#### Row Level Security (RLS) Policies

Every table has RLS enabled with specific policies:

1. **Users**: Can view/update own profile
2. **Classrooms**: Can view if member, owners can update
3. **Assignments**: Members can view, teachers can create/update
4. **Submissions**: Students see own, teachers see all in their classes
5. **Grades**: Students see own, teachers see all they can grade

#### Multi-Instructor Support

Teachers can grade assignments created by other instructors if they have appropriate role in the classroom:
- TEACHER role
- CO_TEACHER role
- TEACHING_ASSISTANT role

This is enforced through RLS policies that check `classroom_members.role`.

## Data Flow Examples

### Assignment Grading Flow

1. Teacher uploads baseline solution (optional)
2. System or teacher creates grading criteria
3. Students submit assignments through Google Classroom
4. Submissions sync to TAAI database
5. AI analyzes submission against criteria
6. Teacher reviews/adjusts AI-generated grade
7. Grade stored in database
8. (Optional) Grade pushed back to Google Classroom
9. Teacher provides feedback on AI accuracy
10. System learns from feedback

### Google Classroom Sync Flow

1. User authenticates with Google OAuth
2. Backend retrieves user's courses via Classroom API
3. Courses stored/updated in `google_classrooms` table
4. Course members retrieved and stored
5. Assignments synced for each course
6. Student submissions retrieved
7. Files processed (OCR if needed)
8. Data available for grading

### Late Submission Processing

1. Teacher configures late policy for assignment
2. Student submits after due date
3. System calculates lateness
4. Grace period checked
5. If beyond grace period, penalty applied
6. Final score = total_points - late_penalty
7. Late status flagged in database

## Security Considerations

### Authentication
- Google OAuth 2.0 for secure sign-in
- JWT tokens for session management
- Token refresh handled automatically
- Secure token storage (httpOnly cookies)

### Authorization
- Role-based access control (RBAC)
- RLS policies at database level
- API-level permission checks
- Supabase handles auth state

### Data Protection
- Google tokens encrypted at rest
- HTTPS for all communications
- Input validation and sanitization
- SQL injection prevention (parameterized queries)
- XSS protection in frontend

### Privacy Compliance
- Student data handled per FERPA guidelines
- Minimal data collection
- Secure data transmission
- Access logs maintained
- Data retention policies

## Scalability

### Frontend
- Code splitting via Vue Router
- Lazy loading of components
- Image optimization
- CDN deployment ready
- Static asset caching

### Backend
- Async/await for non-blocking I/O
- Connection pooling for database
- Rate limiting on API endpoints
- Horizontal scaling ready
- Background job processing

### Database
- Indexed columns for fast queries
- Efficient join strategies
- Query optimization
- Connection pooling
- Supabase auto-scaling

## Monitoring & Observability

### Recommended Tools
- Frontend: Sentry for error tracking
- Backend: FastAPI built-in logging
- Database: Supabase dashboard
- Performance: Lighthouse, Web Vitals
- Uptime: UptimeRobot or similar

### Key Metrics
- API response times
- Database query performance
- Authentication success rate
- Grading accuracy (user feedback)
- System uptime
- Error rates

## Future Enhancements

### Planned Features
1. Real-time collaborative grading
2. Advanced AI models (fine-tuning)
3. Video submission support
4. Plagiarism detection integration
5. Analytics dashboard
6. Mobile applications
7. Batch grading operations
8. Integration with other LMS platforms

### Technical Improvements
1. GraphQL API option
2. Redis caching layer
3. WebSocket for real-time updates
4. Microservices architecture
5. Kubernetes deployment
6. CI/CD pipeline
7. Automated testing suite
8. Performance monitoring

## Development Guidelines

### Code Standards
- TypeScript strict mode enabled
- ESLint + Prettier for formatting
- Type definitions for all API responses
- Comprehensive error handling
- Clear component naming conventions

### Git Workflow
- Main branch for production
- Develop branch for staging
- Feature branches for new work
- Pull request reviews required
- Semantic versioning

### Testing Strategy
- Unit tests for business logic
- Integration tests for API endpoints
- E2E tests for critical user flows
- Component tests for UI
- Load testing for scalability

## Deployment

### Recommended Stack
- **Frontend**: Vercel or Netlify
- **Backend**: Railway or Render
- **Database**: Supabase (included)
- **Storage**: Supabase Storage (included)
- **CDN**: Cloudflare

### Environment Variables
All sensitive configuration managed via environment variables:
- Never commit secrets to repository
- Use different values per environment
- Rotate credentials regularly
- Use secret management service in production

### CI/CD Pipeline
1. Commit triggers build
2. Run tests
3. Build frontend
4. Deploy to staging
5. Run E2E tests
6. Deploy to production (manual approval)
7. Health checks
8. Rollback if issues detected

This architecture is designed to be maintainable, scalable, and secure while providing a great user experience for educators using AI-assisted grading.
