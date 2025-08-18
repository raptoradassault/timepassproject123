- **Backend**: Node.js, Express.js
- **Database**: MongoDB with Mongoose ODM
- **Development**: JavaScript ES6+
- **Package Management**: npm

to install flutter please reffer this video----> [https://youtu.be/QG9bw4rWqrg](https://youtu.be/QG9bw4rWqrg)

Dependencies for node ------->
    "bcryptjs": "^2.4.3",
    "body-parser": "^1.20.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "express": "^4.19.2",
    "jsonwebtoken": "^9.0.2",
    "mongoose": "^8.0.0",
    "nodemailer": "^7.0.5"


Dependencies for flutter ---------->
  please reffer the pubspec.yaml file for the same, you can very well copy the same file for convinience.
  Run flutter pub get in the frontend directory to ensure dependencies are properly linked // **Very IMP**

Your ideal file structure----->

uni-rides-v3/                     # Root project directory
├── frontend/                     # Flutter app directory
│   ├── lib/                      # Flutter source code
│   │   ├── main.dart             # App entry point
│   │   ├── login.dart            # Login page
│   │   ├── signup-with-otp.dart  # Registration page
│   │   ├── forgot-password.dart  # Password reset page
│   │   ├── homepage.dart         # Dashboard
│   │   
│   ├── test/
│   │   └── widget_test.dart      # Flutter tests
│   ├── .vscode/
│   │   └── launch.json           # VS Code configurations
│   ├── pubspec.yaml              # Flutter dependencies
│   ├── pubspec.lock              # Locked versions
│   └── README.md                 # Frontend documentation
│
├── backend/                      # Node.js backend directory
│   ├── server.js                 # Express server
│   ├── models/                   # MongoDB models
│   │   ├── User.js
│   │   ├── Ride.js
│   │   ├── RideRequest.js
│   │   ├── SignupOTP.js
│   │   └── PasswordReset.js
│   ├── .env                      # Environment variables
│   ├── package.json              # Backend dependencies
│   └── README.md                 # Backend documentation
│
└── README.md                     # Project-wide documentation

Use this test account to log in ------>
email
"kkkkkkkk@vit.edu"
Password
123456789
only authentication work has been completed the rest work is still under progress🙃

