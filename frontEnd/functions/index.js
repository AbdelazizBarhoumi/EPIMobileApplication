const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Auto-reply Cloud Function for testing student chat
exports.autoReplyToStudentMessages = functions.firestore
  .document('messages/{conversationId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const message = snap.data();
      const conversationId = context.params.conversationId;
      
      // Only respond to student messages (not teacher messages)
      if (message.senderId === 'teacher_1') {
        console.log('Ignoring teacher message');
        return null;
      }

      console.log('Student message received:', message.content);

      // Generate realistic teacher responses based on message content
      const teacherResponses = [
        'Hello! I received your message. How can I help you today?',
        'Thank you for reaching out. Let me check on that for you.',
        'That\'s a great question! Let me explain...',
        'I understand your concern. Here\'s what I recommend...',
        'Good work on your assignment! Keep it up.',
        'Please see me during office hours for more detailed help.',
        'Make sure to review the lecture materials we covered.',
        'Your progress is looking good. Any specific questions?',
        'I\'ll get back to you with more details shortly.',
        'Great participation in class today!'
      ];

      // Smart response selection based on keywords
      let response = '';
      const content = message.content.toLowerCase();
      
      if (content.includes('hello') || content.includes('hi')) {
        response = 'Hello! How can I assist you today?';
      } else if (content.includes('assignment') || content.includes('homework')) {
        response = 'Regarding your assignment, please check the submission guidelines and let me know if you need clarification.';
      } else if (content.includes('grade') || content.includes('score')) {
        response = 'I\'ll review your grades and provide feedback soon. Keep up the good work!';
      } else if (content.includes('help') || content.includes('question')) {
        response = 'I\'m here to help! Can you be more specific about what you need assistance with?';
      } else if (content.includes('exam') || content.includes('test')) {
        response = 'For exam preparation, review chapters 1-5 and practice problems. My office hours are Monday 2-4 PM.';
      } else {
        // Random response for other messages
        response = teacherResponses[Math.floor(Math.random() * teacherResponses.length)];
      }

      // Add some delay to simulate realistic response time (2-5 seconds)
      const delay = Math.floor(Math.random() * 3000) + 2000;
      
      await new Promise(resolve => setTimeout(resolve, delay));

      // Create teacher reply message
      const teacherMessage = {
        id: `msg_${Date.now()}`,
        content: response,
        senderId: 'teacher_1',
        timestamp: admin.firestore.Timestamp.now(),
        type: 'text',
        read: false,
        status: 'sent',
        reactions: {}
      };

      // Add teacher message to conversation
      await admin.firestore()
        .collection('messages')
        .doc(conversationId)
        .collection('messages')
        .doc(teacherMessage.id)
        .set(teacherMessage);

      // Update conversation for student with new message
      const studentConversationRef = admin.firestore()
        .collection('chats')
        .doc(message.senderId)
        .collection('conversations')
        .doc(conversationId);

      await studentConversationRef.update({
        lastMessage: {
          text: response,
          timestamp: teacherMessage.timestamp,
          senderId: 'teacher_1'
        },
        unreadCount: admin.firestore.FieldValue.increment(1)
      });

      // Update conversation for teacher (mark as read since auto-replied)
      const teacherConversationRef = admin.firestore()
        .collection('chats')
        .doc('teacher_1')
        .collection('conversations')
        .doc(conversationId);

      await teacherConversationRef.set({
        lastMessage: {
          text: response,
          timestamp: teacherMessage.timestamp,
          senderId: 'teacher_1'
        },
        unreadCount: 0,
        participantIds: [message.senderId, 'teacher_1'],
        professorInfo: {
          name: 'Dr. Sarah Johnson',
          course: 'Database Systems',
          avatar: '',
          building: 'CS Building',
          room: 'Room 301'
        },
        status: 'active'
      }, { merge: true });

      // Send push notification to student
      try {
        const studentTokenDoc = await admin.firestore()
          .collection('users')
          .doc(message.senderId)
          .get();

        if (studentTokenDoc.exists && studentTokenDoc.data().fcmToken) {
          await admin.messaging().send({
            token: studentTokenDoc.data().fcmToken,
            notification: {
              title: 'Dr. Sarah Johnson',
              body: response.length > 50 ? response.substring(0, 50) + '...' : response,
            },
            data: {
              conversationId: conversationId,
              senderId: 'teacher_1'
            }
          });
        }
      } catch (notificationError) {
        console.log('Failed to send notification:', notificationError);
      }

      console.log('Auto-reply sent:', response);
      return null;

    } catch (error) {
      console.error('Error in auto-reply function:', error);
      return null;
    }
  });

// Function to simulate teacher typing indicator
exports.simulateTeacherTyping = functions.https.onRequest(async (req, res) => {
  try {
    const { conversationId } = req.body;
    
    if (!conversationId) {
      return res.status(400).json({ error: 'conversationId required' });
    }

    // Set teacher as typing
    await admin.firestore()
      .collection('typing')
      .doc(conversationId)
      .collection('users')
      .doc('teacher_1')
      .set({
        isTyping: true,
        timestamp: admin.firestore.Timestamp.now()
      });

    // Remove typing indicator after 3 seconds
    setTimeout(async () => {
      await admin.firestore()
        .collection('typing')
        .doc(conversationId)
        .collection('users')
        .doc('teacher_1')
        .delete();
    }, 3000);

    res.json({ success: true });
  } catch (error) {
    console.error('Error simulating typing:', error);
    res.status(500).json({ error: error.message });
  }
});