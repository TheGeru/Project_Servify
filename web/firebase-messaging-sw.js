importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

// TUS CREDENCIALES (Cópialas de tu archivo lib/firebase_options.dart sección 'web')
firebase.initializeApp({
  apiKey: "AIzaSyBbQpvMg781SNQsJxTlr30yhySpZvqUJl0",
  authDomain: "servify-app-4b50f.firebaseapp.com",
  projectId: "servify-app-4b50f",
  storageBucket: "servify-app-4b50f.firebasestorage.app",
  messagingSenderId: "498006993645",
  appId: "1:498006993645:web:da538875bf3255de1efae4"
});

const messaging = firebase.messaging();

// Manejador de notificaciones en segundo plano
messaging.onBackgroundMessage((payload) => {
  console.log("Notificación recibida en background:", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png' // Asegúrate de que este icono exista
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});