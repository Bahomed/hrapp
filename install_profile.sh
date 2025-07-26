#!/bin/bash

# Script to help install provisioning profile manually
echo "=== WiFi Entitlement Setup Helper ==="
echo ""
echo "Steps to complete manually:"
echo ""
echo "1. Go to https://developer.apple.com/account/"
echo "2. Navigate to 'Certificates, Identifiers & Profiles'"
echo "3. Click 'Identifiers' and find/create: com.injazathr.injazatHrApp"
echo "4. Edit the App ID and enable 'Access WiFi Information'"
echo "5. Go to 'Profiles' and create a new Development profile"
echo "6. Select your App ID, certificates, and devices"
echo "7. Download the .mobileprovision file"
echo "8. Double-click the downloaded file to install it"
echo ""
echo "Bundle Identifier: com.injazathr.injazatHrApp"
echo "Team ID: 6C775MR5SY"
echo ""
echo "After installing the profile, run:"
echo "flutter run --release -d [device-id]"
echo ""
echo "Current devices:"
flutter devices