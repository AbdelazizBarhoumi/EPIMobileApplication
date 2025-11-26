#!/usr/bin/env python3
"""
Test script to simulate teacher sending a message
This sends a real message and push notification to the student app
"""

import requests
import time
import json

# Firebase project configuration
PROJECT_ID = "epimobileapplication-14233"
API_KEY = "AIzaSyC6kx0jX0Jtp2EqSxQUnl2_-yIy4OeqYko"  # From firebase_options.dart

# OneSignal configuration
ONESIGNAL_APP_ID = "e66b5607-740b-4f85-9096-4b59eeb3b970"
ONESIGNAL_REST_KEY = "os_v2_app_4zvvmb3ubnhyleewjnm65m5zod6s67jug7qupv4cvynitcsryari4npmdv4nm56dwiajzm6uexnohiqo6dxycv5rcvjslmm27miyjpy"

# Test data (update these with actual values)
CONVERSATION_ID = "RbTHlucHbN9213Gi6R7P"  # The conversation you're testing
TEACHER_ID = "teacher_1"
STUDENT_ID = "F8JrDuY6gKND35uqby4W3z20yDH3"  # Get from app logs
MESSAGE_CONTENT = "📱 Hello! This is a test message from the teacher. Did you get the notification?"

def send_onesignal_notification():
    """Send push notification via OneSignal"""
    print("\n📲 Sending OneSignal push notification...")
    
    # Get the student's OneSignal player ID using external user ID
    onesignal_url = "https://onesignal.com/api/v1/players"
    params = {
        "app_id": ONESIGNAL_APP_ID,
        "external_user_id": STUDENT_ID
    }
    
    headers = {
        "Authorization": f"Basic {ONESIGNAL_REST_KEY}"
    }
    
    response = requests.get(onesignal_url, params=params, headers=headers)
    
    if response.status_code != 200:
        print(f"❌ Failed to get player data from OneSignal: {response.status_code}")
        print("   Response:", response.text)
        return
    
    player_data = response.json()
    if not player_data.get('players') or len(player_data['players']) == 0:
        print("❌ No OneSignal player found for student")
        print("   Student needs to open the app first to register with OneSignal")
        return
    
    player_id = player_data['players'][0]['id']
    print(f"   Found player ID: {player_id[:20]}...")
    
    # Send notification via OneSignal
    notification_url = "https://onesignal.com/api/v1/notifications"
    
    notification_data = {
        "app_id": ONESIGNAL_APP_ID,
        "include_player_ids": [player_id],
        "headings": {"en": "New Message"},
        "contents": {"en": MESSAGE_CONTENT},
        "data": {
            "type": "chat",
            "conversationId": CONVERSATION_ID,
            "senderId": TEACHER_ID
        }
    }
    
    response = requests.post(notification_url, json=notification_data, headers=headers)
    
    if response.status_code == 200:
        result = response.json()
        print("✅ OneSignal notification sent successfully!")
        print(f"   Recipients: {result.get('recipients', 0)}")
    else:
        print(f"❌ Failed to send OneSignal notification: {response.status_code}")
        print(f"   Response: {response.text}")

def send_teacher_message():
    print("🚀 Sending teacher message via Firestore REST API...")
    
    # Create message document
    message_id = str(int(time.time() * 1000))
    
    message_data = {
        "fields": {
            "id": {"stringValue": message_id},
            "senderId": {"stringValue": TEACHER_ID},
            "content": {"stringValue": MESSAGE_CONTENT},
            "timestamp": {"timestampValue": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())},
            "read": {"booleanValue": False},
            "status": {"stringValue": "sent"},
            "type": {"stringValue": "text"}
        }
    }
    
    # Add message to Firestore
    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/messages/{CONVERSATION_ID}/messages/{message_id}"
    
    response = requests.patch(
        url,
        params={"key": API_KEY},
        json=message_data
    )
    
    if response.status_code in [200, 201]:
        print("✅ Message added to Firestore")
        print(f"   Message ID: {message_id}")
        
        # Send OneSignal notification
        send_onesignal_notification()
    else:
        print(f"❌ Failed to add message: {response.status_code}")
        print(f"   Response: {response.text}")
        return
    
    # Update student's conversation
    print("\n📋 Updating student's conversation...")
    
    conversation_data = {
        "fields": {
            "lastMessage": {
                "mapValue": {
                    "fields": {
                        "text": {"stringValue": MESSAGE_CONTENT},
                        "timestamp": {"timestampValue": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())},
                        "senderId": {"stringValue": TEACHER_ID}
                    }
                }
            },
            "unreadCount": {"integerValue": "1"}  # This will need to be incremented manually
        }
    }
    
    conv_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/chats/{STUDENT_ID}/conversations/{CONVERSATION_ID}"
    
    response = requests.patch(
        conv_url,
        params={
            "key": API_KEY,
            "updateMask.fieldPaths": "lastMessage",
            "updateMask.fieldPaths": "unreadCount"
        },
        json=conversation_data
    )
    
    if response.status_code == 200:
        print("✅ Student conversation updated")
    else:
        print(f"⚠️ Failed to update conversation: {response.status_code}")
        print(f"   Response: {response.text}")
    
    print("\n" + "="*60)
    print("🎉 DONE!")
    print("="*60)
    print("\n📱 Check your phone:")
    print("   1. You should see the message appear in the chat")
    print("   2. You'll get a OneSignal push notification (even if app is closed!)")
    print("   3. Conversation list will update with new message")
    print("\n💡 Note: OneSignal notifications work even when the app is")
    print("   completely closed, unlike Firebase which needs the app running.")
    print("="*60)

if __name__ == "__main__":
    send_teacher_message()
