/*
  # Create User Profiles Tables

  ## Overview
  Creates separate tables for NGO and Volunteer profiles that extend Supabase Auth users.
  
  ## New Tables
  
  ### `ngo_profiles`
  - `id` (uuid, primary key) - References auth.users(id)
  - `organization_name` (text) - Name of the NGO
  - `contact_person` (text) - Primary contact name
  - `phone` (text) - Contact phone number
  - `city` (text) - City location
  - `description` (text) - About the organization
  - `cause_areas` (text[]) - Array of cause areas
  - `website` (text, nullable) - Organization website
  - `logo` (text, nullable) - Logo URL
  - `created_at` (timestamptz) - Account creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp
  
  ### `volunteer_profiles`
  - `id` (uuid, primary key) - References auth.users(id)
  - `first_name` (text) - Volunteer's first name
  - `last_name` (text) - Volunteer's last name
  - `phone` (text) - Contact phone number
  - `city` (text) - City location
  - `bio` (text) - Personal bio
  - `skills` (text[]) - Array of skills
  - `availability` (text) - Availability description
  - `created_at` (timestamptz) - Account creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp
  
  ## Security
  - Enable RLS on both tables
  - Users can read their own profile
  - Users can update their own profile
  - NGO profiles are publicly readable (for volunteers browsing)
  - Volunteer profiles are publicly readable (for NGOs reviewing applications)
*/

-- Create NGO profiles table
CREATE TABLE IF NOT EXISTS ngo_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  organization_name text NOT NULL,
  contact_person text NOT NULL,
  phone text NOT NULL,
  city text NOT NULL,
  description text NOT NULL,
  cause_areas text[] NOT NULL DEFAULT '{}',
  website text,
  logo text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create Volunteer profiles table
CREATE TABLE IF NOT EXISTS volunteer_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name text NOT NULL,
  last_name text NOT NULL,
  phone text NOT NULL,
  city text NOT NULL,
  bio text NOT NULL,
  skills text[] NOT NULL DEFAULT '{}',
  availability text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE ngo_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE volunteer_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for ngo_profiles
CREATE POLICY "NGO profiles are publicly readable"
  ON ngo_profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert their own NGO profile"
  ON ngo_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own NGO profile"
  ON ngo_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- RLS Policies for volunteer_profiles
CREATE POLICY "Volunteer profiles are publicly readable"
  ON volunteer_profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert their own volunteer profile"
  ON volunteer_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own volunteer profile"
  ON volunteer_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS ngo_profiles_city_idx ON ngo_profiles(city);
CREATE INDEX IF NOT EXISTS ngo_profiles_cause_areas_idx ON ngo_profiles USING GIN(cause_areas);
CREATE INDEX IF NOT EXISTS volunteer_profiles_city_idx ON volunteer_profiles(city);
CREATE INDEX IF NOT EXISTS volunteer_profiles_skills_idx ON volunteer_profiles USING GIN(skills);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER update_ngo_profiles_updated_at
  BEFORE UPDATE ON ngo_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_volunteer_profiles_updated_at
  BEFORE UPDATE ON volunteer_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();