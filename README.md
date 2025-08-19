

# 🚗 Uni-Rides

> A university ride-sharing platform connecting students for safe, convenient, and eco-friendly campus transportation.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)

## 📖 Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Backend Setup](#backend-setup)
- [Frontend Setup](#frontend-setup)
- [Configuration](#configuration)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Contributing](#contributing)
- [License](#license)

 About

Uni-Rides is a comprehensive ride-sharing application designed specifically for university students. It provides a secure platform for students to share rides to campus, reducing transportation costs and promoting environmental sustainability.

**Key Highlights:**
-  Secure OTP-based authentication with university email verification
-  Exclusive access for verified .edu email addresses
-  Cross-platform Flutter mobile application
-  Robust Node.js backend with MongoDB database

##  Features

### Authentication & Security
- 📧 Email OTP verification for account creation using nodemailer + backend otp generation
- 🏫 University email domain validation (@vit.edu)
- 🔑 JWT-based secure authentication
- 👤 Student ID verification system

### Ride Management
-  Create and join ride requests
-  Location-based ride matching
-  User rating and review system

### User Experience
-  Modern Material Design 3 UI
- 📱 Responsive design for all screen sizes

## 📱 Screenshots
<img width="386" height="859" alt="image" src="https://github.com/user-attachments/assets/b1fc570b-5440-4659-b72f-4f69b27c4e67" />
<img width="388" height="859" alt="image" src="https://github.com/user-attachments/assets/a2dad2e7-7ac7-49c5-a94a-75048872d266" />
<img width="386" height="859" alt="image" src="https://github.com/user-attachments/assets/34ae4901-7d57-457c-8265-20a3ebc74960" />


*Screenshots will be added here*

## 🛠 Prerequisites

Before you begin, ensure you have the following installed:

### For Frontend (Flutter) 
- **Flutter SDK** (3.35.)(https://docs.flutter.dev/get-started/install/macos)
- **Dart SDK** (3.0.0 or higher)
- **Android Studio** / **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Xcode** (for iOS development - macOS only)(from Mac App Store)
- **If facing any problems please reffer this video as it can get very complex some times(https://youtu.be/QG9bw4rWqrg?si=x9qxe8lP1X2W5qfi)**
 **you can find the exact dependencies for flutter in my pubspec.yaml**

  

### For Backend (Node.js)
- **Node.js** (16.0.0 or higher)
- **npm** 
- **MongoDB** (local or MongoDB Atlas)
  Dependencies for node ------->
    "bcryptjs": "^2.4.3",
    "body-parser": "^1.20.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "express": "^4.19.2",
    "jsonwebtoken": "^9.0.2",
    "mongoose": "^8.0.0",
    "nodemailer": "^7.0.5"
**Your ideal file structure**
  <img width="666" height="692" alt="image" src="https://github.com/user-attachments/assets/b35aac5f-38b4-4ca5-9aae-c445badabd37" />




