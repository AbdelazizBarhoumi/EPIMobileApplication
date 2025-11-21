# PowerShell script to fix EPI App files
Write-Host "Fixing EPI App Files..." -ForegroundColor Green

# Delete the corrupted home_page.dart
if (Test-Path "lib\home_page.dart") {
    Remove-Item "lib\home_page.dart"
    Write-Host "✓ Deleted corrupted home_page.dart" -ForegroundColor Yellow
}

# Rename the new clean version
if (Test-Path "lib\home_page_new.dart") {
    Rename-Item "lib\home_page_new.dart" "home_page.dart"
    Write-Host "✓ Renamed home_page_new.dart to home_page.dart" -ForegroundColor Green
}

# Delete backup file
if (Test-Path "lib\home_page_backup.dart") {
    Remove-Item "lib\home_page_backup.dart"
    Write-Host "✓ Deleted backup file" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Done! Your app structure is now fixed." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run: flutter pub get" -ForegroundColor White
Write-Host "  2. Then: flutter run" -ForegroundColor White
Write-Host ""

