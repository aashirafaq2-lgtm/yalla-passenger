# IQ Al-Massar Master App

**Entire Project Flutter Migration - Completed**

This project has been fully converted from Next.js/Capacitor to a native Flutter application.

## 🚀 Key Features
*   **Unified Master App**: Single codebase handling Driver, Passenger, and Admin roles.
*   **Premium Graphics**: Ported the luxury aesthetic from Next.js (Glassmorphism, Kinetic Typography).
*   **High Performance**: Native rendering ensures smooth map interactions and real-time tracking.
*   **Admin Mobile Cloud**: Full administration suite ported to mobile-first Flutter UI.

## 📂 Architecture
*   `lib/features/auth`: Multi-role onboarding and Role Selection.
*   `lib/features/driver`: Fleet dispatching and earnings dashboard.
*   `lib/features/passenger`: Ride hailing and service selection.
*   `lib/features/admin`: Platform stats and fleet integrity monitoring.
*   `lib/core`: Shared UI tokens, typography, and socket services.

## 🛠️ Infrastructure
*   **State Management**: Provider
*   **Networking**: Dio
*   **Real-time**: Socket.io
*   **Animations**: animate_do & staggered animations
