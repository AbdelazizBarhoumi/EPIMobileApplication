importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBH7QjZ4ySF1HJGPnxQ_YE8RN5HGhXdZQo",
  authDomain: "epimobileapplication-14233.firebaseapp.com",
  projectId: "epimobileapplication-14233",
  storageBucket: "epimobileapplication-14233.firebasestorage.app",
  messagingSenderId: "67907098202",
  appId: "1:67907098202:web:abcdef1234567890",
  measurementId: "G-XXXXXXXXXX"
});

const messaging = firebase.messaging();