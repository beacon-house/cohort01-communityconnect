/*
  # Create Test Accounts

  ## Overview
  Creates two test accounts for demo purposes:
  1. NGO account: tech@beaconhouse.in
  2. Volunteer account: nkgoutham@gmail.com

  ## Details
  
  ### NGO Account
  - Organization: Beacon House Foundation
  - Email: tech@beaconhouse.in
  - Password: Test@123
  - Location: Bangalore
  - Cause Areas: Education, Healthcare, Environment
  
  ### Volunteer Account
  - Name: Goutham NK
  - Email: nkgoutham@gmail.com
  - Password: Test@123
  - Location: Bangalore
  - Skills: Teaching, Web Development, Content Writing
  
  ## Important Notes
  - These accounts are created for testing/demo purposes
  - Passwords are set via Supabase Auth Admin API (not in this migration)
  - This migration only creates the profile data with placeholder IDs
  - Actual user creation must be done through the application's registration flow or Supabase dashboard
*/

-- Note: We cannot create auth.users directly via SQL migration
-- These accounts need to be created manually through:
-- 1. The application's registration UI, OR
-- 2. Supabase Dashboard > Authentication > Users > Add User

-- This migration serves as documentation of the test accounts needed
-- The actual account creation should be done through Supabase Dashboard

-- Instructions for manual setup:
-- 1. Go to Supabase Dashboard > Authentication > Users
-- 2. Click "Add User" and create:
--    - Email: tech@beaconhouse.in, Password: Test@123, Auto Confirm Email: Yes
--    - Email: nkgoutham@gmail.com, Password: Test@123, Auto Confirm Email: Yes
-- 3. After creating each user, note their UUID
-- 4. Insert their profiles using the UUIDs from step 3

SELECT 'Test accounts need to be created via Supabase Dashboard' as instruction;
