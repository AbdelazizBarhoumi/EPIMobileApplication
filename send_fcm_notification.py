#!/usr/bin/env python3
"""
Send FCM notification directly to test push notifications
This simulates what happens when a teacher sends a message
"""

import requests
import time

# Firebase Configuration
PROJECT_ID = "epimobileapplication-14233"
API_KEY = "AIzaSyC6kx0jX0Jtp2EqSxQUnl2_-yIy4OeqYko"
SERVER_KEY = "YOUR_SERVER_KEY_HERE"  # Get from Firebase Console > Project Settings > Cloud Messaging

# Test Data
CONVERSATION_ID = "RbTHlucHbN9213Gi6R7P"
TEACHER_ID = "teacher_1"
STUDENT_ID = "F8JrDuY6gKND35uqby4W3z20yDH3"

def get_student_fcm_token():
    """Get student's FCM token from Firestore"""
    print("📲 Getting student's FCM token...")
    
    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/users/{STUDENT_ID}"
    
    response = requests.get(url, params={"key": API_KEY})
    
    if response.status_code == 200:
        data = response.json()
        token = data.get('fields', {}).get('fcmToken', {}).get('stringValue')
        if token:
            print(f"✅ Found FCM token: {token[:50]}...")
            return token
        else:
            print("❌ No FCM token found in user document")
            return None
    else:
        print(f"❌ Failed to get user data: {response.status_code}")
        print(f"   Response: {response.text}")
        return None

def send_fcm_notification(fcm_token, message_content):
    """Send FCM push notification"""
    print(f"\n📤 Sending FCM notification...")
    
    # FCM v1 API endpoint
    url = f"https://fcm.googleapis.com/v1/projects/{PROJECT_ID}/messages:send"
    
    headers = {
        "Authorization": f"Bearer {SERVER_KEY}",  # This needs OAuth2 token, not server key
        "Content-Type": "application/json"
    }
    
    payload = {
        "message": {
            "token": fcm_token,
            "notification": {
                "title": "Dr. Sarah Johnson",
                "body": message_content
            },
            "data": {
                "type": "chat",
                "conversationId": CONVERSATION_ID,
                "senderId": TEACHER_ID,
                "click_action": "FLUTTER_NOTIFICATION_CLICK"
            },
            "android": {
                "priority": "high",
                "notification": {
                    "channel_id": "chat_messages",
                    "sound": "default",
                    "color": "#C62828"
                }
            }
        }
    }
    
    response = requests.post(url, json=payload, headers=headers)
    
    if response.status_code == 200:
        print("✅ FCM notification sent successfully!")
        return True
    else:
        print(f"❌ Failed to send FCM notification: {response.status_code}")
        print(f"   Response: {response.text}")
        return False

def main():
    print("=" * 60)
    print("🔔 FCM NOTIFICATION TEST")
    print("=" * 60)
    
    # Step 1: Get FCM token
    fcm_token = get_student_fcm_token()
    
    if not fcm_token:
        print("\n" + "=" * 60)
        print("❌ Cannot send notification: No FCM token found")
        print("=" * 60)
        print("\nMake sure:")
        print("1. The student app has been opened at least once")
        print("2. Notification permissions were granted")
        print("3. FCM token was stored in Firestore")
        return
    
    # Step 2: Send notification
    message_content = "📱 Test notification! You should see this on your phone."
    success = send_fcm_notification(fcm_token, message_content)
    
    if success:
        print("\n" + "=" * 60)
        print("🎉 SUCCESS!")
        print("=" * 60)
        print("\n📱 Check your phone for the notification!")
    else:
        print("\n" + "=" * 60)
        print("❌ FAILED")
        print("=" * 60)
        print("\nNote: FCM v1 API requires OAuth2 authentication.")
        print("The easier way is to use the Cloud Function or the bug button in the app.")

if __name__ == "__main__":
    main()
