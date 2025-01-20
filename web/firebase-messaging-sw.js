importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
apiKey: "AIzaSyBLFJsorOHaFc4nrRNtZ-eGpaq5CyqJbDs",
authDomain: "talabatcom-b7817.firebaseapp.com",
projectId: "talabatcom-b7817",
storageBucket: "talabatcom-b7817.firebasestorage.app",
messagingSenderId: "1064328943216",
appId: "1:1064328943216:web:fbec53c91c90c793e306b5"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});