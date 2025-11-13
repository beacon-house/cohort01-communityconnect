# Test Accounts Setup

This document provides instructions for creating test accounts for demo purposes.

## Required Test Accounts

### 1. NGO Account
- **Email:** tech@beaconhouse.in
- **Password:** Test@123

**Profile Details:**
- Organization Name: Beacon House Foundation
- Contact Person: Tech Team
- Phone: +91 9876543210
- City: Bangalore
- Description: Beacon House Foundation works towards empowering underprivileged communities through education, healthcare, and sustainable livelihood programs. We believe in creating lasting social impact through community-driven initiatives.
- Cause Areas: Education, Healthcare, Environment
- Website: https://beaconhouse.in

### 2. Volunteer Account
- **Email:** nkgoutham@gmail.com
- **Password:** Test@123

**Profile Details:**
- First Name: Goutham
- Last Name: NK
- Phone: +91 9876543211
- City: Bangalore
- Bio: Passionate about making a difference in my community through volunteer work.
- Skills: Teaching, Web Development, Content Writing
- Availability: Weekends, 10 hours/week

## Setup Instructions

### Option 1: Using the Application (Recommended)

1. Go to the registration page for NGO: `/register-ngo`
2. Fill in the NGO details as specified above
3. Go to the registration page for Volunteer: `/register-volunteer`
4. Fill in the volunteer details as specified above

### Option 2: Using Supabase Dashboard

1. Open your Supabase project dashboard
2. Navigate to **Authentication** > **Users**
3. Click **"Add User"** button

#### For NGO Account:
- Email: tech@beaconhouse.in
- Password: Test@123
- Auto Confirm Email: **Yes** (check this box)
- Click "Create User"
- Note the UUID generated for this user
- Go to **Database** > **Table Editor** > **ngo_profiles**
- Insert a new row with the UUID and profile details above

#### For Volunteer Account:
- Email: nkgoutham@gmail.com
- Password: Test@123
- Auto Confirm Email: **Yes** (check this box)
- Click "Create User"
- Note the UUID generated for this user
- Go to **Database** > **Table Editor** > **volunteer_profiles**
- Insert a new row with the UUID and profile details above

## Testing

After creating both accounts, you can test the login flow:

1. Go to `/login`
2. Select "NGO" tab and login with tech@beaconhouse.in / Test@123
3. Logout
4. Select "Volunteer" tab and login with nkgoutham@gmail.com / Test@123

Both accounts should successfully authenticate and redirect to their respective dashboards.
