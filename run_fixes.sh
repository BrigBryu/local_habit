#!/bin/bash

# Database connection details
DB_HOST="db.ffemtzuqmgqkitbyfvrn.supabase.co"
DB_PORT="5432"
DB_NAME="postgres"
DB_USER="postgres"
DB_PASSWORD="S0S0tuff123!"

echo "🔧 Running Supabase Database Fixes..."
echo "Host: $DB_HOST"
echo ""

# Test connection first
echo "Testing connection..."
PGPASSWORD="$DB_PASSWORD" psql "postgresql://$DB_USER@$DB_HOST:$DB_PORT/$DB_NAME" -c "SELECT version();" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Connection successful!"
    echo "🚀 Running fix script..."
    
    PGPASSWORD="$DB_PASSWORD" psql "postgresql://$DB_USER@$DB_HOST:$DB_PORT/$DB_NAME" -f /Users/bridger/Documents/programming_projects/habit/habit_level_up/SQL_snippets/01-realtime-publication-fix.sql
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 Database fixes applied successfully!"
        echo "✅ Realtime publication created"
        echo "✅ SECURITY DEFINER functions updated" 
        echo "✅ Permissions granted"
        echo ""
        echo "Your apps should now be able to:"
        echo "  - Sign in/create accounts"
        echo "  - Link partners"
        echo "  - Sync in real-time"
    else
        echo "❌ Failed to apply fixes"
    fi
else
    echo "❌ Connection failed. Please check:"
    echo "  - Database host: $DB_HOST"
    echo "  - Password: $DB_PASSWORD"
    echo "  - Network connectivity"
    echo ""
    echo "🔧 Alternative: Copy this SQL and run in Supabase Dashboard:"
    echo "────────────────────────────────────────────────────────"
    cat /Users/bridger/Documents/programming_projects/habit/habit_level_up/SQL_snippets/01-realtime-publication-fix.sql
fi