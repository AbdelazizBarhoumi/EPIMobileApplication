# Database Requirements for Notifications and Chats (Firebase)

## Notifications
- **Notification ID**: Unique identifier for each notification
- **Title**: Short title of the notification (e.g., "Payment Reminder", "New Grade Posted")
- **Message**: Detailed message content
- **Timestamp**: Date and time when notification was created
- **Type**: Category (e.g., payment, grade, event, schedule, club)
- **Read Status**: Boolean indicating if user has read the notification
- **Icon/Color**: Visual indicators for different types
- **Action URL**: Optional link to related page or action

## Chats/Messaging
- **Conversation ID**: Unique identifier for each chat thread
- **Participant IDs**: IDs of users in the conversation (student + professor)
- **Messages**:
  - Message ID
  - Sender ID
  - Content (text)
  - Timestamp
  - Read status
  - Message type (text, image, file)
- **Last Message**: Preview of most recent message
- **Unread Count**: Number of unread messages for the student
- **Professor Info**: Name, course, avatar, building
- **Chat Status**: Active/inactive status

## Firebase Collections Structure
- `notifications/{userId}/items/{notificationId}`
- `chats/{userId}/conversations/{conversationId}`
- `messages/{conversationId}/messages/{messageId}`
