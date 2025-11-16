/*
  # TAAI Initial Database Schema

  ## Overview
  This migration creates the complete database schema for the TAAI (AI Grader) application,
  which integrates with Google Classroom to automate grading of student assignments.

  ## New Tables

  ### 1. `users`
  Stores user profile information linked to Google accounts
  - `id` (uuid, primary key) - Unique user identifier
  - `google_id` (text, unique) - Google OAuth ID
  - `email` (text, unique) - User email address
  - `name` (text) - User's full name
  - `profile_picture` (text) - URL to profile image
  - `created_at` (timestamptz) - Account creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 2. `google_classrooms`
  Stores connected Google Classroom courses
  - `id` (uuid, primary key)
  - `google_course_id` (text, unique) - Google Classroom course ID
  - `name` (text) - Course name
  - `section` (text) - Course section
  - `description` (text) - Course description
  - `owner_id` (uuid, foreign key to users) - Course owner
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 3. `classroom_members`
  Junction table for users and their classroom memberships with roles
  - `id` (uuid, primary key)
  - `classroom_id` (uuid, foreign key to google_classrooms)
  - `user_id` (uuid, foreign key to users)
  - `role` (text) - Role: TEACHER, CO_TEACHER, TEACHING_ASSISTANT, STUDENT
  - `created_at` (timestamptz)

  ### 4. `assignments`
  Stores assignment information from Google Classroom
  - `id` (uuid, primary key)
  - `google_assignment_id` (text, unique) - Google Classroom assignment ID
  - `classroom_id` (uuid, foreign key to google_classrooms)
  - `creator_id` (uuid, foreign key to users) - Assignment creator
  - `title` (text) - Assignment title
  - `description` (text) - Assignment description
  - `max_points` (numeric) - Maximum points possible
  - `due_date` (timestamptz) - Due date
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 5. `knowledge_bases`
  Stores uploaded slides/documents for assignment context
  - `id` (uuid, primary key)
  - `assignment_id` (uuid, foreign key to assignments)
  - `uploaded_by` (uuid, foreign key to users)
  - `file_name` (text) - Original filename
  - `file_url` (text) - Storage URL
  - `file_type` (text) - MIME type
  - `content_text` (text) - Extracted text content
  - `created_at` (timestamptz)

  ### 6. `baseline_solutions`
  Stores model solutions for assignments
  - `id` (uuid, primary key)
  - `assignment_id` (uuid, foreign key to assignments)
  - `uploaded_by` (uuid, foreign key to users)
  - `file_name` (text)
  - `file_url` (text)
  - `content_text` (text)
  - `created_at` (timestamptz)

  ### 7. `grading_criteria`
  Stores grading rubrics and criteria for assignments
  - `id` (uuid, primary key)
  - `assignment_id` (uuid, foreign key to assignments)
  - `created_by` (uuid, foreign key to users)
  - `subtask_name` (text) - Name of the subtask
  - `description` (text) - Criteria description
  - `max_points` (numeric) - Maximum points for this criterion
  - `order_index` (integer) - Display order
  - `is_ai_generated` (boolean) - Whether AI suggested this criterion
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 8. `submissions`
  Stores student submissions
  - `id` (uuid, primary key)
  - `google_submission_id` (text, unique) - Google Classroom submission ID
  - `assignment_id` (uuid, foreign key to assignments)
  - `student_id` (uuid, foreign key to users)
  - `submitted_at` (timestamptz) - Submission timestamp
  - `is_late` (boolean) - Late submission flag
  - `file_url` (text) - Submission file URL
  - `file_type` (text) - File MIME type
  - `extracted_text` (text) - OCR/extracted content
  - `created_at` (timestamptz)

  ### 9. `grades`
  Stores calculated grades for submissions
  - `id` (uuid, primary key)
  - `submission_id` (uuid, foreign key to submissions)
  - `graded_by` (uuid, foreign key to users)
  - `total_points` (numeric) - Total points awarded
  - `late_penalty` (numeric) - Points deducted for lateness
  - `final_score` (numeric) - Final score after penalties
  - `feedback` (text) - Overall feedback
  - `is_ai_generated` (boolean) - Whether grade was AI-generated
  - `graded_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 10. `grade_criteria_scores`
  Stores individual criterion scores for each grade
  - `id` (uuid, primary key)
  - `grade_id` (uuid, foreign key to grades)
  - `criteria_id` (uuid, foreign key to grading_criteria)
  - `points_awarded` (numeric) - Points for this criterion
  - `feedback` (text) - Specific feedback for this criterion
  - `created_at` (timestamptz)

  ### 11. `grade_feedback`
  Stores user feedback on AI-generated grades for model improvement
  - `id` (uuid, primary key)
  - `grade_id` (uuid, foreign key to grades)
  - `user_id` (uuid, foreign key to users)
  - `feedback_type` (text) - CORRECTION, SUGGESTION, COMMENT
  - `feedback_text` (text) - Detailed feedback
  - `suggested_score` (numeric) - User's suggested score (if applicable)
  - `created_at` (timestamptz)

  ### 12. `late_submission_policies`
  Configurable late submission penalty rules per assignment
  - `id` (uuid, primary key)
  - `assignment_id` (uuid, foreign key to assignments, unique)
  - `created_by` (uuid, foreign key to users)
  - `penalty_type` (text) - PERCENTAGE, FIXED_POINTS, NONE
  - `penalty_amount` (numeric) - Amount to deduct
  - `grace_period_minutes` (integer) - Grace period before penalties apply
  - `max_days_accepted` (integer) - Maximum days late accepted
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 13. `google_tokens`
  Securely stores Google OAuth tokens per user
  - `id` (uuid, primary key)
  - `user_id` (uuid, foreign key to users, unique)
  - `access_token` (text) - Encrypted access token
  - `refresh_token` (text) - Encrypted refresh token
  - `token_expiry` (timestamptz) - Token expiration time
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ## Security
  - All tables have Row Level Security (RLS) enabled
  - Policies enforce authentication requirements
  - Users can only access data they have permission to view
  - Multi-instructor grading is supported through classroom_members roles
  - Google tokens are stored securely with encryption at rest

  ## Important Notes
  1. Google IDs and assignment IDs are stored to maintain sync with Google Classroom
  2. OCR text extraction is stored for AI processing
  3. Late policies are configurable per assignment
  4. Feedback loop enables continuous AI improvement
  5. All timestamps use timestamptz for timezone awareness
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  google_id text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  name text NOT NULL,
  profile_picture text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Create google_classrooms table (without policies yet)
CREATE TABLE IF NOT EXISTS google_classrooms (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  google_course_id text UNIQUE NOT NULL,
  name text NOT NULL,
  section text,
  description text,
  owner_id uuid REFERENCES users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE google_classrooms ENABLE ROW LEVEL SECURITY;

-- Create classroom_members table
CREATE TABLE IF NOT EXISTS classroom_members (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  classroom_id uuid REFERENCES google_classrooms(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  role text NOT NULL CHECK (role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT', 'STUDENT')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(classroom_id, user_id)
);

ALTER TABLE classroom_members ENABLE ROW LEVEL SECURITY;

-- Now add policies for google_classrooms that reference classroom_members
CREATE POLICY "Users can view classrooms they are members of"
  ON google_classrooms FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM classroom_members
      WHERE classroom_members.classroom_id = google_classrooms.id
      AND classroom_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Classroom owners can update their classrooms"
  ON google_classrooms FOR UPDATE
  TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Authenticated users can insert classrooms"
  ON google_classrooms FOR INSERT
  TO authenticated
  WITH CHECK (owner_id = auth.uid());

-- Add policies for classroom_members
CREATE POLICY "Users can view memberships in their classrooms"
  ON classroom_members FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM classroom_members cm
      WHERE cm.classroom_id = classroom_members.classroom_id
      AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can manage classroom members"
  ON classroom_members FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM classroom_members
      WHERE classroom_id = classroom_members.classroom_id
      AND user_id = auth.uid()
      AND role IN ('TEACHER', 'CO_TEACHER')
    )
  );

-- Create assignments table
CREATE TABLE IF NOT EXISTS assignments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  google_assignment_id text UNIQUE NOT NULL,
  classroom_id uuid REFERENCES google_classrooms(id) ON DELETE CASCADE NOT NULL,
  creator_id uuid REFERENCES users(id) ON DELETE SET NULL,
  title text NOT NULL,
  description text,
  max_points numeric DEFAULT 100,
  due_date timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Classroom members can view assignments"
  ON assignments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM classroom_members
      WHERE classroom_members.classroom_id = assignments.classroom_id
      AND classroom_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can create assignments"
  ON assignments FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM classroom_members
      WHERE classroom_members.classroom_id = assignments.classroom_id
      AND classroom_members.user_id = auth.uid()
      AND classroom_members.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

CREATE POLICY "Teachers can update assignments"
  ON assignments FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM classroom_members
      WHERE classroom_members.classroom_id = assignments.classroom_id
      AND classroom_members.user_id = auth.uid()
      AND classroom_members.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM classroom_members
      WHERE classroom_members.classroom_id = assignments.classroom_id
      AND classroom_members.user_id = auth.uid()
      AND classroom_members.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

-- Create knowledge_bases table
CREATE TABLE IF NOT EXISTS knowledge_bases (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  assignment_id uuid REFERENCES assignments(id) ON DELETE CASCADE NOT NULL,
  uploaded_by uuid REFERENCES users(id) ON DELETE SET NULL,
  file_name text NOT NULL,
  file_url text NOT NULL,
  file_type text NOT NULL,
  content_text text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE knowledge_bases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can view knowledge bases for their assignments"
  ON knowledge_bases FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = knowledge_bases.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

CREATE POLICY "Teachers can upload knowledge bases"
  ON knowledge_bases FOR INSERT
  TO authenticated
  WITH CHECK (
    uploaded_by = auth.uid() AND
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = knowledge_bases.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

-- Create baseline_solutions table
CREATE TABLE IF NOT EXISTS baseline_solutions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  assignment_id uuid REFERENCES assignments(id) ON DELETE CASCADE NOT NULL,
  uploaded_by uuid REFERENCES users(id) ON DELETE SET NULL,
  file_name text NOT NULL,
  file_url text NOT NULL,
  content_text text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE baseline_solutions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can view baseline solutions"
  ON baseline_solutions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = baseline_solutions.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

CREATE POLICY "Teachers can upload baseline solutions"
  ON baseline_solutions FOR INSERT
  TO authenticated
  WITH CHECK (
    uploaded_by = auth.uid() AND
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = baseline_solutions.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

-- Create grading_criteria table
CREATE TABLE IF NOT EXISTS grading_criteria (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  assignment_id uuid REFERENCES assignments(id) ON DELETE CASCADE NOT NULL,
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  subtask_name text NOT NULL,
  description text NOT NULL,
  max_points numeric NOT NULL,
  order_index integer DEFAULT 0,
  is_ai_generated boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE grading_criteria ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Classroom members can view grading criteria"
  ON grading_criteria FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = grading_criteria.assignment_id
      AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can create grading criteria"
  ON grading_criteria FOR INSERT
  TO authenticated
  WITH CHECK (
    created_by = auth.uid() AND
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = grading_criteria.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

CREATE POLICY "Teachers can update grading criteria"
  ON grading_criteria FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = grading_criteria.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = grading_criteria.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

-- Create submissions table
CREATE TABLE IF NOT EXISTS submissions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  google_submission_id text UNIQUE NOT NULL,
  assignment_id uuid REFERENCES assignments(id) ON DELETE CASCADE NOT NULL,
  student_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  submitted_at timestamptz DEFAULT now(),
  is_late boolean DEFAULT false,
  file_url text,
  file_type text,
  extracted_text text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view own submissions"
  ON submissions FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

CREATE POLICY "Teachers can view submissions for their assignments"
  ON submissions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = submissions.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

CREATE POLICY "Students can insert own submissions"
  ON submissions FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid());

-- Create grades table
CREATE TABLE IF NOT EXISTS grades (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  submission_id uuid REFERENCES submissions(id) ON DELETE CASCADE NOT NULL,
  graded_by uuid REFERENCES users(id) ON DELETE SET NULL,
  total_points numeric NOT NULL DEFAULT 0,
  late_penalty numeric DEFAULT 0,
  final_score numeric NOT NULL DEFAULT 0,
  feedback text,
  is_ai_generated boolean DEFAULT false,
  graded_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE grades ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view their own grades"
  ON grades FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM submissions s
      WHERE s.id = grades.submission_id
      AND s.student_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can view grades for their assignments"
  ON grades FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM submissions s
      JOIN assignments a ON a.id = s.assignment_id
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE s.id = grades.submission_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

CREATE POLICY "Teachers can create grades"
  ON grades FOR INSERT
  TO authenticated
  WITH CHECK (
    graded_by = auth.uid() AND
    EXISTS (
      SELECT 1 FROM submissions s
      JOIN assignments a ON a.id = s.assignment_id
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE s.id = grades.submission_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

CREATE POLICY "Teachers can update grades"
  ON grades FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM submissions s
      JOIN assignments a ON a.id = s.assignment_id
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE s.id = grades.submission_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM submissions s
      JOIN assignments a ON a.id = s.assignment_id
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE s.id = grades.submission_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

-- Create grade_criteria_scores table
CREATE TABLE IF NOT EXISTS grade_criteria_scores (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  grade_id uuid REFERENCES grades(id) ON DELETE CASCADE NOT NULL,
  criteria_id uuid REFERENCES grading_criteria(id) ON DELETE CASCADE NOT NULL,
  points_awarded numeric NOT NULL DEFAULT 0,
  feedback text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE grade_criteria_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view criteria scores for grades they can view"
  ON grade_criteria_scores FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM grades g
      JOIN submissions s ON s.id = g.submission_id
      WHERE g.id = grade_criteria_scores.grade_id
      AND (
        s.student_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM assignments a
          JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
          WHERE a.id = s.assignment_id
          AND cm.user_id = auth.uid()
          AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
        )
      )
    )
  );

CREATE POLICY "Teachers can create criteria scores"
  ON grade_criteria_scores FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM grades g
      JOIN submissions s ON s.id = g.submission_id
      JOIN assignments a ON a.id = s.assignment_id
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE g.id = grade_criteria_scores.grade_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

-- Create grade_feedback table
CREATE TABLE IF NOT EXISTS grade_feedback (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  grade_id uuid REFERENCES grades(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  feedback_type text NOT NULL CHECK (feedback_type IN ('CORRECTION', 'SUGGESTION', 'COMMENT')),
  feedback_text text NOT NULL,
  suggested_score numeric,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE grade_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view feedback on grades they can view"
  ON grade_feedback FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM grades g
      JOIN submissions s ON s.id = g.submission_id
      JOIN assignments a ON a.id = s.assignment_id
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE g.id = grade_feedback.grade_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

CREATE POLICY "Teachers can create grade feedback"
  ON grade_feedback FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM grades g
      JOIN submissions s ON s.id = g.submission_id
      JOIN assignments a ON a.id = s.assignment_id
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE g.id = grade_feedback.grade_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

-- Create late_submission_policies table
CREATE TABLE IF NOT EXISTS late_submission_policies (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  assignment_id uuid REFERENCES assignments(id) ON DELETE CASCADE UNIQUE NOT NULL,
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  penalty_type text NOT NULL CHECK (penalty_type IN ('PERCENTAGE', 'FIXED_POINTS', 'NONE')),
  penalty_amount numeric DEFAULT 0,
  grace_period_minutes integer DEFAULT 0,
  max_days_accepted integer DEFAULT 7,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE late_submission_policies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Classroom members can view late policies"
  ON late_submission_policies FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = late_submission_policies.assignment_id
      AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can create late policies"
  ON late_submission_policies FOR INSERT
  TO authenticated
  WITH CHECK (
    created_by = auth.uid() AND
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = late_submission_policies.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

CREATE POLICY "Teachers can update late policies"
  ON late_submission_policies FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = late_submission_policies.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classroom_members cm ON cm.classroom_id = a.classroom_id
      WHERE a.id = late_submission_policies.assignment_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('TEACHER', 'CO_TEACHER', 'TEACHING_ASSISTANT')
    )
  );

-- Create google_tokens table
CREATE TABLE IF NOT EXISTS google_tokens (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  access_token text NOT NULL,
  refresh_token text,
  token_expiry timestamptz NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE google_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tokens"
  ON google_tokens FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own tokens"
  ON google_tokens FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own tokens"
  ON google_tokens FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_classroom_members_classroom ON classroom_members(classroom_id);
CREATE INDEX IF NOT EXISTS idx_classroom_members_user ON classroom_members(user_id);
CREATE INDEX IF NOT EXISTS idx_assignments_classroom ON assignments(classroom_id);
CREATE INDEX IF NOT EXISTS idx_submissions_assignment ON submissions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_submissions_student ON submissions(student_id);
CREATE INDEX IF NOT EXISTS idx_grades_submission ON grades(submission_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_bases_assignment ON knowledge_bases(assignment_id);
CREATE INDEX IF NOT EXISTS idx_baseline_solutions_assignment ON baseline_solutions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_grading_criteria_assignment ON grading_criteria(assignment_id);
