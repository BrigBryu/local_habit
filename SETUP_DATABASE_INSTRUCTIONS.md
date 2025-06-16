# Database Setup Instructions

## Quick Setup

Your habit tracking app needs a properly configured database to work. Follow these steps:

### 1. Open Supabase SQL Editor

1. Go to your Supabase dashboard: https://supabase.com/dashboard
2. Select your project (or create a new one if needed)
3. Click on **"SQL Editor"** in the left sidebar
4. Click **"New Query"**

### 2. Run the Database Setup Script

Copy the entire contents of `SQL_snippets/00-complete-database-setup.sql` and paste it into the SQL editor, then click **"Run"**.

This script will:
- ✅ Create all required tables (`accounts`, `habits`, `habit_completions`, `relationships`)
- ✅ Set up proper indexes for performance
- ✅ Create RPC functions for authentication and partner management
- ✅ Configure Row Level Security (RLS) policies

### 3. Verify Setup

After running the script, you should see output like:
```
Database setup completed successfully!
```

The script will also show you the table structures and confirm all tables are empty and ready for use.

### 4. Update Your App

Make sure your app's `.env` file has the correct Supabase credentials:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## What This Fixes

### Habit Creation Issues
- ✅ **Proper table schema**: Creates `habits` table with all required fields
- ✅ **Complete data mapping**: Saves habit type, description, and all tracking fields
- ✅ **UUID handling**: Proper UUID generation and validation

### Partner Linking Issues  
- ✅ **RPC functions**: Creates `link_partner`, `get_partners`, and `remove_partner` functions
- ✅ **Username lookup**: Proper username-to-UUID resolution for partner linking
- ✅ **Bidirectional relationships**: Creates both directions of partner relationships

### Authentication Issues
- ✅ **Username-based auth**: Creates `create_account` and `login_account` RPC functions
- ✅ **Password security**: Proper password hash storage and validation
- ✅ **User ID consistency**: Ensures consistent UUID format throughout the system

## Testing

After setup, test the functionality:

1. **Create an account** in the app
2. **Create a habit** - it should now appear in your habits list
3. **Link a partner** by username - they should appear in the partner tab
4. **View partner habits** - should show habits from linked partners

## Troubleshooting

If you encounter issues:

1. **Check the SQL output** for any error messages
2. **Verify your Supabase credentials** in the app's environment variables
3. **Check the app logs** for specific error details
4. **Re-run the setup script** if needed (it's safe to run multiple times)

The setup script is designed to be idempotent - you can run it multiple times without issues.