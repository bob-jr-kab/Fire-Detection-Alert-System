// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBEs__lwo-SXMkA4fpm2JHqsHg7CmbwI6U",
  authDomain: "fire-app-66a76.firebaseapp.com",
  projectId: "fire-app-66a76",
  storageBucket: "fire-app-66a76.firebasestorage.app",
  messagingSenderId: "1064007582333",
  appId: "1:1064007582333:web:22ef6f646b69b777dee714",
  measurementId: "G-0PGT96N435",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
// Initialize Cloud Firestore and get a reference to the service
const db = getFirestore(app);

export { db };
export default app;
