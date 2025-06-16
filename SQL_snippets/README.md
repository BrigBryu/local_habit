# SQL Database Setup

## Quick Start

**🚀 Run this first:** `00-complete-database-setup.sql`

This single script sets up your entire database and makes the habit tracking app work properly.

## What to Run

### 1. **Primary Setup (Required)**
- **`00-complete-database-setup.sql`** - **RUN THIS FIRST**
  - Creates all tables (`accounts`, `habits`, `habit_completions`, `relationships`)
  - Sets up all RPC functions for authentication and partner management
  - Configures proper indexes and security policies
  - This is all you need to get the app working!

### 2. **Individual Components (Optional)**
These are broken down for reference. **You don't need to run them if you already ran `00-complete-database-setup.sql`** (which includes everything):

- `01-accounts.sql` - Just the accounts table
- `02-relationships.sql` - Just the relationships table  
- `03-habits.sql` - Just the habits tables
- `04-functions.sql` - Just the RPC functions

### 3. **Health Check Script**
- **`99-database-health-check.sql`** - **Use this to verify your setup**
  - Checks if all required tables, functions, and indexes exist
  - Provides detailed status report with ✅, ⚠️, or ❌ indicators
  - Tells you exactly what's missing or misconfigured
  - Safe to run anytime (read-only, doesn't change anything)

### 4. **Archived Files**
- `_archived/` - Old/deprecated SQL files kept for reference

## How to Run

### For Setup:
1. **Open Supabase Dashboard**: https://supabase.com/dashboard
2. **Go to SQL Editor**: Click "SQL Editor" in left sidebar
3. **Create New Query**: Click "New Query"
4. **Copy & Paste**: Copy entire contents of `00-complete-database-setup.sql`
5. **Run**: Click "Run" button
6. **Verify**: Should see "Database setup completed successfully!"

### For Health Check:
1. **Same steps as above**, but use `99-database-health-check.sql`
2. **Review results**: Look for ✅ (good), ⚠️ (warning), or ❌ (error) indicators
3. **Follow recommendations**: The script tells you exactly what to fix

## What This Fixes

### ✅ Habit Creation
- Habits now save properly to database
- All habit fields (type, description, etc.) are preserved
- Habits appear immediately in the app

### ✅ Partner Linking  
- Link partners by username
- Partners appear in the partner tab
- Bidirectional relationships work correctly

### ✅ Authentication
- Username/password accounts work properly
- Secure password hashing
- Session persistence

## Troubleshooting

- **Error about existing tables/policies?** This is normal if you run scripts multiple times. The scripts are designed to handle existing objects safely.
- **"policy already exists" error?** This just means you already have the setup complete. You can ignore this error.
- **Permission errors?** Make sure you're the project owner in Supabase
- **Connection issues?** Check your Supabase project is active
- **Still not working?** Check the app logs for specific error messages

## Database Schema Overview

After running the setup script, you'll have:

```
accounts (id, username, password_hash, created_at, updated_at)
├── habits (id, user_id, name, description, type, ...)
├── habit_completions (id, habit_id, user_id, completed_at, ...)
└── relationships (id, user_id, partner_id, status, ...)
```

Plus RPC functions:
- `create_account(username, password_hash)`
- `login_account(username)`  
- `link_partner(user_id, partner_username)`
- `get_partners(user_id)`
- `remove_partner(user_id, partner_id)`