# Run this script to create the local database with migrations
# PowerShell script

Write-Host "Creating local SQLite database..." -ForegroundColor Green

# Check if sqlite3 is available
$sqlite3Path = Get-Command sqlite3 -ErrorAction SilentlyContinue

if ($sqlite3Path) {
    Write-Host "Using sqlite3 to create database..." -ForegroundColor Yellow
    sqlite3 forum.db < migrations/0001_initial_schema.sql
    Write-Host "✅ Database created successfully!" -ForegroundColor Green
} else {
    Write-Host "sqlite3 not found in PATH. Using Node.js..." -ForegroundColor Yellow
    
    # Use Node.js to create the database
    node -e "const Database = require('better-sqlite3'); const db = new Database('./forum.db'); const fs = require('fs'); const migration = fs.readFileSync('./migrations/0001_initial_schema.sql', 'utf8'); db.exec(migration); db.close(); console.log('✅ Database created successfully!');"
}

Write-Host ""
Write-Host "Next step: Run seed script" -ForegroundColor Cyan
Write-Host "  npm run db:seed:local" -ForegroundColor White
