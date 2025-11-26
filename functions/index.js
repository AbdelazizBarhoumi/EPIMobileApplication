const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Auto-reply function for testing chat without teacher app
exports.autoReplyToStudentMessage = onDocumentCreated(
  "messages/{conversationId}/messages/{messageId}",
  async (event) => {
    try {
      const messageData = event.data.data();
      const conversationId = event.params.conversationId;
      const messageId = event.params.messageId;

      logger.info("Processing message:", { conversationId, messageId, messageData });

      // Skip if this is already an auto-reply or from teacher
      if (messageData.senderId === 'auto_teacher' || messageData.isAutoReply) {
        logger.info("Skipping auto-reply for teacher or auto-reply message");
        return;
      }

      // Get conversation participants by querying any user's conversation with this ID
      // We need to find at least one user's conversation doc to get participant list
      const chatsSnapshot = await admin.firestore()
        .collectionGroup('conversations')
        .where(admin.firestore.FieldPath.documentId(), '==', conversationId)
        .limit(1)
        .get();
      
      if (chatsSnapshot.empty) {
        logger.error("Conversation not found:", conversationId);
        return;
      }

      const conversationData = chatsSnapshot.docs[0].data();
      logger.info("Conversation data:", conversationData);

      // Generate smart response based on message content
      const studentMessage = messageData.content.toLowerCase();
      let replyContent;
      
      if (studentMessage.includes('hello') || studentMessage.includes('hi') || studentMessage.includes('hey')) {
        replyContent = "Hello! How can I help you today? 😊";
      } else if (studentMessage.includes('assignment') || studentMessage.includes('homework')) {
        replyContent = "I see you're asking about assignments. Please check your course materials and let me know if you have specific questions.";
      } else if (studentMessage.includes('grade') || studentMessage.includes('score')) {
        replyContent = "Regarding your grades, please log into the student portal for the most up-to-date information.";
      } else if (studentMessage.includes('help') || studentMessage.includes('problem')) {
        replyContent = "I'm here to help! Can you please provide more details about what you're struggling with?";
      } else if (studentMessage.includes('test') || studentMessage.includes('exam')) {
        replyContent = "For test information, please refer to the course schedule. If you have specific questions, feel free to ask.";
      } else if (studentMessage.includes('time') || studentMessage.includes('when')) {
        replyContent = "Please check the course schedule for timing information. Office hours are available if you need to discuss further.";
      } else {
        replyContent = "Thank you for your message. I'll review it and get back to you soon. If this is urgent, please don't hesitate to reach out during office hours.";
      }

      // Wait 2-5 seconds to simulate realistic response time
      const delay = Math.floor(Math.random() * 3000) + 2000; // 2-5 seconds
      await new Promise(resolve => setTimeout(resolve, delay));

      // Create teacher reply message
      const replyData = {
        senderId: 'auto_teacher',
        content: replyContent,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
        status: 'sent',
        isAutoReply: true,
        type: 'text'
      };

      // Add reply to messages collection (using correct path)
      const replyMessageRef = admin.firestore()
        .collection('messages')
        .doc(conversationId)
        .collection('messages')
        .doc();
      
      await replyMessageRef.set(replyData);
      logger.info("Auto-reply message created:", replyMessageRef.id);

      // Prepare last message data for conversation updates
      const lastMessageData = {
        text: replyContent,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        senderId: 'auto_teacher',
      };

      // Update conversation for ALL participants (in their respective chats subcollections)
      const batch = admin.firestore().batch();
      
      if (conversationData.participantIds && Array.isArray(conversationData.participantIds)) {
        for (const participantId of conversationData.participantIds) {
          const participantConvRef = admin.firestore()
            .collection('chats')
            .doc(participantId)
            .collection('conversations')
            .doc(conversationId);

          // Only increment unread count for non-teacher participants
          if (participantId !== 'auto_teacher') {
            batch.set(participantConvRef, {
              lastMessage: lastMessageData,
              unreadCount: admin.firestore.FieldValue.increment(1),
            }, { merge: true });
          } else {
            batch.set(participantConvRef, {
              lastMessage: lastMessageData,
            }, { merge: true });
          }
        }
      }

      await batch.commit();
      logger.info("Conversation updated with auto-reply for all participants");

      // Send push notifications to participants (except auto_teacher)
      if (conversationData.participantIds && Array.isArray(conversationData.participantIds)) {
        for (const participantId of conversationData.participantIds) {
          if (participantId !== 'auto_teacher' && participantId !== messageData.senderId) {
            try {
              // Get user's FCM token
              const userDoc = await admin.firestore().collection('users').doc(participantId).get();
              const fcmToken = userDoc.data()?.fcmToken;

              if (fcmToken) {
                // Send notification
                await admin.messaging().send({
                  token: fcmToken,
                  notification: {
                    title: conversationData.professorInfo?.name || 'New Message',
                    body: replyContent,
                  },
                  data: {
                    type: 'chat',
                    conversationId: conversationId,
                    senderId: 'auto_teacher',
                  },
                  android: {
                    priority: 'high',
                  },
                  apns: {
                    payload: {
                      aps: {
                        sound: 'default',
                      },
                    },
                  },
                });
                logger.info(`Push notification sent to user: ${participantId}`);
              } else {
                logger.info(`No FCM token found for user: ${participantId}`);
              }
            } catch (notifError) {
              logger.error(`Error sending notification to ${participantId}:`, notifError);
            }
          }
        }
      }

    } catch (error) {
      logger.error("Error in autoReplyToStudentMessage:", error);
    }
  }
);

// Sync conversation updates for all participants when any message is created
exports.syncConversationOnMessage = onDocumentCreated(
  "messages/{conversationId}/messages/{messageId}",
  async (event) => {
    try {
      const messageData = event.data.data();
      const conversationId = event.params.conversationId;
      const messageId = event.params.messageId;

      logger.info("Syncing conversation for message:", { conversationId, messageId });

      // Get conversation participants
      const chatsSnapshot = await admin.firestore()
        .collectionGroup('conversations')
        .where(admin.firestore.FieldPath.documentId(), '==', conversationId)
        .limit(1)
        .get();
      
      if (chatsSnapshot.empty) {
        logger.warn("Conversation not found for sync:", conversationId);
        return;
      }

      const conversationData = chatsSnapshot.docs[0].data();
      const participantIds = conversationData.participantIds || [];

      if (participantIds.length === 0) {
        logger.warn("No participants found in conversation:", conversationId);
        return;
      }

      // Prepare last message data
      const lastMessageData = {
        text: messageData.content,
        timestamp: messageData.timestamp || admin.firestore.FieldValue.serverTimestamp(),
        senderId: messageData.senderId,
      };

      // Update conversation for all participants EXCEPT the sender (sender already updated their own)
      const batch = admin.firestore().batch();
      
      for (const participantId of participantIds) {
        // Skip the sender - they already updated their conversation in the client
        if (participantId === messageData.senderId) {
          logger.info(`Skipping sender ${participantId} - already updated by client`);
          continue;
        }

        const participantConvRef = admin.firestore()
          .collection('chats')
          .doc(participantId)
          .collection('conversations')
          .doc(conversationId);

        // Increment unread count for recipients
        batch.set(participantConvRef, {
          lastMessage: lastMessageData,
          unreadCount: admin.firestore.FieldValue.increment(1),
        }, { merge: true });
        
        logger.info(`Queued conversation update for participant: ${participantId}`);
      }

      await batch.commit();
      logger.info("Conversation synced successfully for all recipients");

    } catch (error) {
      logger.error("Error in syncConversationOnMessage:", error);
    }
  }
);