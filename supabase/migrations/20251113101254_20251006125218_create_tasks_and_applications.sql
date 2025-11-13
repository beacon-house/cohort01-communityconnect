/*
  # Create Tasks and Applications Tables

  ## Overview
  Creates tables for volunteer tasks/opportunities and applications workflow.
  
  ## New Tables
  
  ### `tasks`
  - `id` (uuid, primary key) - Unique task identifier
  - `ngo_id` (uuid) - References NGO profile who created the task
  - `title` (text) - Task title
  - `description` (text) - Detailed task description
  - `cause_area` (text) - Primary cause area
  - `required_skills` (text[]) - Array of required skills
  - `location` (text) - Task location (city or "Remote")
  - `hours_per_week` (int) - Expected time commitment per week
  - `duration_months` (int) - Expected duration in months
  - `status` (text) - Task status: 'active' or 'inactive'
  - `created_at` (timestamptz) - Task creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp
  
  ### `applications`
  - `id` (uuid, primary key) - Unique application identifier
  - `task_id` (uuid) - References the task
  - `volunteer_id` (uuid) - References the volunteer
  - `message` (text, nullable) - Optional application message
  - `status` (text) - Application status: 'pending', 'accepted', or 'rejected'
  - `created_at` (timestamptz) - Application submission timestamp
  - `updated_at` (timestamptz) - Last update timestamp
  
  ## Security
  - Enable RLS on both tables
  - Tasks are publicly readable by authenticated users
  - NGOs can create, update, and delete their own tasks
  - Volunteers can apply to tasks (create applications)
  - Applications are visible to the volunteer who created them and the NGO who owns the task
  - NGOs can update application status (accept/reject)
  
  ## Important Notes
  - Tasks must have a valid cause_area and at least one required skill
  - Applications enforce a unique constraint (one application per volunteer per task)
  - Status fields use CHECK constraints to ensure valid values
*/

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ngo_id uuid NOT NULL REFERENCES ngo_profiles(id) ON DELETE CASCADE,
  title text NOT NULL CHECK (length(title) >= 10),
  description text NOT NULL CHECK (length(description) >= 100),
  cause_area text NOT NULL,
  required_skills text[] NOT NULL DEFAULT '{}',
  location text NOT NULL,
  hours_per_week int NOT NULL CHECK (hours_per_week >= 1 AND hours_per_week <= 40),
  duration_months int NOT NULL CHECK (duration_months >= 1 AND duration_months <= 24),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create applications table
CREATE TABLE IF NOT EXISTS applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  volunteer_id uuid NOT NULL REFERENCES volunteer_profiles(id) ON DELETE CASCADE,
  message text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(task_id, volunteer_id)
);

-- Enable RLS
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;

-- RLS Policies for tasks
CREATE POLICY "Active tasks are publicly readable"
  ON tasks FOR SELECT
  TO authenticated
  USING (status = 'active' OR ngo_id = auth.uid());

CREATE POLICY "NGOs can insert their own tasks"
  ON tasks FOR INSERT
  TO authenticated
  WITH CHECK (ngo_id = auth.uid());

CREATE POLICY "NGOs can update their own tasks"
  ON tasks FOR UPDATE
  TO authenticated
  USING (ngo_id = auth.uid())
  WITH CHECK (ngo_id = auth.uid());

CREATE POLICY "NGOs can delete their own tasks"
  ON tasks FOR DELETE
  TO authenticated
  USING (ngo_id = auth.uid());

-- RLS Policies for applications
CREATE POLICY "Volunteers can view their own applications"
  ON applications FOR SELECT
  TO authenticated
  USING (volunteer_id = auth.uid());

CREATE POLICY "NGOs can view applications for their tasks"
  ON applications FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM tasks
      WHERE tasks.id = applications.task_id
      AND tasks.ngo_id = auth.uid()
    )
  );

CREATE POLICY "Volunteers can create applications"
  ON applications FOR INSERT
  TO authenticated
  WITH CHECK (volunteer_id = auth.uid());

CREATE POLICY "NGOs can update application status for their tasks"
  ON applications FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM tasks
      WHERE tasks.id = applications.task_id
      AND tasks.ngo_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM tasks
      WHERE tasks.id = applications.task_id
      AND tasks.ngo_id = auth.uid()
    )
  );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS tasks_ngo_id_idx ON tasks(ngo_id);
CREATE INDEX IF NOT EXISTS tasks_status_idx ON tasks(status);
CREATE INDEX IF NOT EXISTS tasks_cause_area_idx ON tasks(cause_area);
CREATE INDEX IF NOT EXISTS tasks_location_idx ON tasks(location);
CREATE INDEX IF NOT EXISTS tasks_required_skills_idx ON tasks USING GIN(required_skills);
CREATE INDEX IF NOT EXISTS tasks_created_at_idx ON tasks(created_at DESC);

CREATE INDEX IF NOT EXISTS applications_task_id_idx ON applications(task_id);
CREATE INDEX IF NOT EXISTS applications_volunteer_id_idx ON applications(volunteer_id);
CREATE INDEX IF NOT EXISTS applications_status_idx ON applications(status);

-- Add updated_at triggers
CREATE TRIGGER update_tasks_updated_at
  BEFORE UPDATE ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_applications_updated_at
  BEFORE UPDATE ON applications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();