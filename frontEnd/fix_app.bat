@echo off
echo Fixing EPI App Files...

:: Delete the corrupted home_page.dart
if exist "lib\home_page.dart" (
    del "lib\home_page.dart"
    echo Deleted corrupted home_page.dart
)

:: Rename the new clean version
if exist "lib\home_page_new.dart" (
    ren "lib\home_page_new.dart" "home_page.dart"
    echo Renamed home_page_new.dart to home_page.dart
)

:: Delete backup file
if exist "lib\home_page_backup.dart" (
    del "lib\home_page_backup.dart"
    echo Deleted backup file
)

echo.
echo Done! Your app structure is now fixed.
echo.
echo Run: flutter pub get
echo Then: flutter run
pause
