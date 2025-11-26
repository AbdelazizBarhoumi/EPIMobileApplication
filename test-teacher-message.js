// Test script to simulate teacher sending a message
// This will trigger real notifications in the student app

const admin = require('firebase-admin');
const serviceAccount = require('./functions/serviceAccountKey.json'); // You need to download this

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://epimobileapplication-14233-default-rtdb.europe-west1.firebasedatabase.app'
});

const db = admin.firestore();

async function sendTeacherMessage() {
  try {
    const conversationId = 'X7x4qxaz7FOARjrXVNh3'; // Replace with actual conversation ID
    const teacherId = 'teacher_1';
    const studentId = 'F8JrDuY6gKND35uqby4W3z20yDH3';
    
    console.log('🚀 Simulating teacher message...');

    // Create message
    const messageId = Date.now().toString();
    const messageData = {
      id: messageId,
      senderId: teacherId,
      content: '📱 This is a real test from teacher! You should receive a push notification.',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
      status: 'sent',
      type: 'text'
    };

    // Add message to Firestore
    await db.collection('messages')
      .doc(conversationId)
      .collection('messages')
      .doc(messageId)
      .set(messageData);

    console.log('✅ Message added to Firestore');

    // Update student's conversation
    await db.collection('chats')
      .doc(studentId)
      .collection('conversations')
      .doc(conversationId)
      .set({
        lastMessage: {
          text: messageData.content,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          senderId: teacherId,
        },
        unreadCount: admin.firestore.FieldValue.increment(1),
      }, { merge: true });

    console.log('✅ Student conversation updated');

    // Get student's FCM token
    const userDoc = await db.collection('users').doc(studentId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (fcmToken) {
      console.log('📲 Sending push notification...');
      
      // Send push notification
      const response = await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: 'Dr. Sarah Johnson',
          body: messageData.content,
        },
        data: {
          type: 'chat',
          conversationId: conversationId,
          senderId: teacherId,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'chat_messages',
            sound: 'default',
            color: '#C62828',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      });

      console.log('✅ Push notification sent successfully!');
      console.log('Response:', response);
    } else {
      console.log('⚠️ No FCM token found for student');
    }

    console.log('\n🎉 Done! Check your phone for the notification.');
    process.exit(0);

  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

sendTeacherMessage();
