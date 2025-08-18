const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const SignupOTP = require('./models/SignupOTP');
const mongoose = require('mongoose');
const path = require('path');
const nodemailer = require('nodemailer'); // ADD THIS LINE
const crypto = require('crypto'); // ADD THIS LINE
require('dotenv').config();
console.log('EMAIL_USER:', '"' + process.env.EMAIL_USER + '"');
console.log('EMAIL_PASS:', '"' + process.env.EMAIL_PASS + '"');

// --- Initialize Express App ---
const app = express();
const PORT = process.env.PORT || 3000;

// --- Environment Variables ---
const JWT_SECRET = process.env.JWT_SECRET;
const MONGODB_URI = process.env.MONGODB_URI;

if (!JWT_SECRET || !MONGODB_URI) {
  console.error("FATAL ERROR: JWT_SECRET or MONGODB_URI is not defined in .env file.");
  process.exit(1);
}

// --- Connect to MongoDB ---
mongoose.connect(MONGODB_URI)
  .then(() => console.log('✅ Successfully connected to MongoDB'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  });

// --- Email Configuration ---
const transporter = nodemailer.createTransport({
  service: process.env.EMAIL_SERVICE || 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// Verify email configuration
transporter.verify((error, success) => {
  if (error) {
    console.error('❌ Email configuration error:', error);
  } else {
    console.log('✅ Email service is ready');
  }
});

// Email helper function
async function sendOTPEmail(email, otp, fullName) {
  const mailOptions = {
    from: {
      name: 'Uni-Rides',
      address: process.env.EMAIL_USER
    },
    to: email,
    subject: 'Your Uni-Rides Signup Verification Code',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #4F46E5;">Welcome to Uni-Rides!</h2>
        <p>Hi ${fullName},</p>
        <p>Thank you for signing up! Please use the verification code below to complete your registration:</p>
        <div style="background-color: #f3f4f6; padding: 20px; text-align: center; margin: 20px 0; border-radius: 8px;">
          <h1 style="color: #4F46E5; font-size: 32px; letter-spacing: 8px; margin: 0;">${otp}</h1>
        </div>
        <p><strong>Important:</strong> This code will expire in 10 minutes for security purposes.</p>
        <p>If you didn't request this code, please ignore this email.</p>
        <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;">
        <p style="color: #6b7280; font-size: 14px;">
          Best regards,<br>
          The Uni-Rides Team
        </p>
      </div>
    `,
    text: `Welcome to Uni-Rides! Your verification code is: ${otp}. This code will expire in 10 minutes. If you didn't request this code, please ignore this email.`
  };

  await transporter.sendMail(mailOptions);
}



// --- Import Models ---
const User = require('./models/User');
const Ride = require('./models/Ride');
const RideRequest = require('./models/RideRequest');
const PasswordReset = require('./models/PasswordReset'); // Added from first file

// --- Middleware ---
app.use(cors());
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, '../Frontend')));

// --- Authentication Middleware ---
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'No token provided, authorization denied.' });
  }

  jwt.verify(token, JWT_SECRET, (err, decodedToken) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ message: 'Token expired, please login again.' });
      }
      return res.status(403).json({ message: 'Token is not valid.' });
    }
    req.user = decodedToken;
    next();
  });
};

// --- User Authentication Endpoints ---


// Add endpoint to resend signup OTP
app.post('/api/signup/send-otp', async (req, res) => {
  // ✅ FIXED: Extract ALL required fields
  const { fullName, email, password,  gradYear, studentId, phoneNumber, collegeDomain } = req.body;

  // ✅ FIXED: Validate ALL required fields
  if (!fullName || !email || !password ||  !gradYear || !studentId || !phoneNumber) {
    return res.status(400).json({ message: 'All fields are required.' });
  }

  // Validate email domain
  if (!email.toLowerCase().endsWith('.edu')) {
    return res.status(400).json({ message: 'Please use a valid .edu email address.' });
  }

  try {
    // Check if user already exists
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(409).json({ message: 'Email already registered.' });
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Hash password before storing temporarily
    const hashedPassword = await bcrypt.hash(password, 10);

    // Delete any existing OTP for this email
    await SignupOTP.deleteMany({ email: email.toLowerCase() });

    // ✅ FIXED: Store ALL user data including studentId and phoneNumber
    const signupOTP = new SignupOTP({
      email: email.toLowerCase(),
      otp: otp,
      userData: {
        fullName,
        email: email.toLowerCase(),
        password: hashedPassword,
        college: 'VIT University',                // Maps to 'college' in User schema
        collegeDomain: collegeDomain || 'vit.edu',
        gradYear: parseInt(gradYear),
        studentId,                               // ✅ NOW INCLUDED
        phoneNumber                              // ✅ NOW INCLUDED
      }
    });

    await signupOTP.save();

    // Send OTP email
    try {
      await sendOTPEmail(email.toLowerCase(), otp, fullName);
      console.log(`✅ OTP email sent successfully to ${email}`);
      
      res.json({
        message: 'OTP sent to your email address. Please verify to complete registration.'
      });
    } catch (emailError) {
      console.error('❌ Error sending OTP email:', emailError);
      // Clean up the stored OTP since email failed
      await SignupOTP.deleteOne({ email: email.toLowerCase() });
      return res.status(500).json({ 
        message: 'Failed to send verification email. Please try again later.' 
      });
    }

  } catch (error) {
    console.error('Send signup OTP error:', error.message);
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(val => val.message);
      return res.status(400).json({ message: messages.join(' ') });
    }
    res.status(500).json({ message: 'Server error during signup. Please try again later.' });
  }
});


app.post('/api/signup/verify-otp', async (req, res) => {
  const { email, otp } = req.body;

  if (!email || !otp) {
    return res.status(400).json({ message: 'Email and OTP are required.' });
  }

  if (otp.length !== 6) {
    return res.status(400).json({ message: 'Please enter a valid 6-digit OTP.' });
  }

  try {
    // Find the signup OTP record
    const signupRecord = await SignupOTP.findOne({
      email: email.toLowerCase(),
      otp: otp
    });

    if (!signupRecord) {
      return res.status(400).json({ message: 'Invalid or expired OTP.' });
    }

    // Check if user was created in the meantime
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      await SignupOTP.deleteOne({ _id: signupRecord._id });
      return res.status(409).json({ message: 'Email already registered.' });
    }

    // Create the user account
    const newUser = new User(signupRecord.userData);
    await newUser.save();

    // Delete the used OTP record
    await SignupOTP.deleteOne({ _id: signupRecord._id });

    console.log('User signed up successfully:', { id: newUser._id, email: newUser.email });
    res.status(201).json({
      message: 'Account created successfully! You can now login with your credentials.'
    });

  } catch (error) {
    console.error('Verify signup OTP error:', error.message);
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(val => val.message);
      return res.status(400).json({ message: messages.join(' ') });
    }
    res.status(500).json({ message: 'Server error during account creation. Please try again later.' });
  }
});


app.post('/api/signup/resend-otp', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email is required.' });
  }

  try {
    // Find existing signup record
    const existingRecord = await SignupOTP.findOne({ email: email.toLowerCase() });
    if (!existingRecord) {
      return res.status(404).json({ message: 'No pending signup found for this email.' });
    }

    // Generate new OTP
    const newOTP = Math.floor(100000 + Math.random() * 900000).toString();

    // Update the record with new OTP
    existingRecord.otp = newOTP;
    existingRecord.createdAt = new Date(); // Reset expiry time
    await existingRecord.save();

    // Send new OTP email
    try {
      await sendOTPEmail(email.toLowerCase(), newOTP, existingRecord.userData.fullName);
      console.log(`✅ New OTP email sent to ${email}`);

      res.json({
        message: 'New OTP sent to your email address.'
        // Remove this line in production:
        // otp: newOTP // Only for testing
      });
    } catch (emailError) {
      console.error('❌ Error sending new OTP email:', emailError);
      return res.status(500).json({
        message: 'Failed to send new verification email. Please try again later.'
      });
    }

  } catch (error) {
    console.error('Resend signup OTP error:', error.message);
    res.status(500).json({ message: 'Server error. Please try again later.' });
  }
});

app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    const tokenPayload = {
      userId: user._id,
      email: user.email,
      fullName: user.fullName
    };
    const token = jwt.sign(tokenPayload, JWT_SECRET, { expiresIn: '1h' });

    console.log('User logged in:', { id: user._id, email: user.email });
    res.json({
      message: 'Login successful!',
      token: token,
      userName: user.fullName
    });
  } catch (error) {
    console.error('Login server error:', error.message);
    res.status(500).json({ message: 'Server error during login. Please try again later.' });
  }
});

// --- Password Reset Endpoints (Added from first file) ---

// Request password reset
app.post('/api/forgot-password', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email is required.' });
  }

  try {
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(404).json({ message: 'No account found with this email address.' });
    }

    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();

    await PasswordReset.deleteMany({ userId: user._id });

    const passwordReset = new PasswordReset({
      userId: user._id,
      email: user.email,
      resetCode: resetCode
    });

    await passwordReset.save();

    // In a real app, you would send an email here.
    console.log(`Password reset code for ${email}: ${resetCode}`);

    res.json({
      message: 'Password reset code sent to your email address.',
      // Remove this line in production for security:
      resetCode: resetCode
    });

  } catch (error) {
    console.error('Forgot password error:', error.message);
    res.status(500).json({ message: 'Server error. Please try again later.' });
  }
});

// Verify reset code
app.post('/api/verify-reset-code', async (req, res) => {
  const { email, resetCode } = req.body;

  if (!email || !resetCode) {
    return res.status(400).json({ message: 'Email and reset code are required.' });
  }

  try {
    const passwordReset = await PasswordReset.findOne({
      email: email.toLowerCase(),
      resetCode: resetCode
    });

    if (!passwordReset) {
      return res.status(400).json({ message: 'Invalid or expired reset code.' });
    }

    res.json({
      message: 'Reset code verified successfully.',
      userId: passwordReset.userId
    });

  } catch (error) {
    console.error('Verify reset code error:', error.message);
    res.status(500).json({ message: 'Server error. Please try again later.' });
  }
});

// Reset password with code
app.post('/api/reset-password', async (req, res) => {
  const { email, resetCode, newPassword } = req.body;

  if (!email || !resetCode || !newPassword) {
    return res.status(400).json({ message: 'Email, reset code, and new password are required.' });
  }

  if (newPassword.length < 6) {
    return res.status(400).json({ message: 'Password must be at least 6 characters long.' });
  }

  try {
    const passwordReset = await PasswordReset.findOne({
      email: email.toLowerCase(),
      resetCode: resetCode
    });

    if (!passwordReset) {
      return res.status(400).json({ message: 'Invalid or expired reset code.' });
    }

    const user = await User.findById(passwordReset.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    user.password = hashedPassword;
    await user.save();

    await PasswordReset.deleteOne({ _id: passwordReset._id });

    console.log('Password reset successful for:', user.email);
    res.json({ message: 'Password reset successful! You can now login with your new password.' });

  } catch (error) {
    console.error('Reset password error:', error.message);
    res.status(500).json({ message: 'Server error. Please try again later.' });
  }
});


// --- User Profile Endpoints ---
app.get('/api/user-profile', authenticateToken, async (req, res) => {
  try {
    const userProfile = await User.findById(req.user.userId).select('-password');
    if (!userProfile) {
      return res.status(404).json({ message: "User profile not found." });
    }

    res.json({
      message: `Profile data for ${userProfile.fullName}.`,
      user: {
        id: userProfile._id,
        fullName: userProfile.fullName,
        email: userProfile.email,
        
        gradYear: userProfile.gradYear,
        phone: userProfile.phone || '',
        profilePictureUrl: userProfile.profilePictureUrl,
        ridePreferences: userProfile.ridePreferences,
        accountStats: userProfile.accountStats,
        verification: userProfile.verification,
        createdAt: userProfile.createdAt,
        updatedAt: userProfile.updatedAt
      }
    });
  } catch (error) {
    console.error('User profile fetch error:', error.message);
    res.status(500).json({ message: 'Error fetching user profile.' });
  }
});

app.put('/api/user-profile', authenticateToken, async (req, res) => {
  try {
    const {
      fullName,
      phone,
      ridePreferences,
      profilePictureUrl
    } = req.body;

    const updateData = {};
    if (fullName) updateData.fullName = fullName;
    if (phone !== undefined) updateData.phone = phone;
    if (profilePictureUrl) updateData.profilePictureUrl = profilePictureUrl;
    if (ridePreferences) updateData.ridePreferences = ridePreferences;

    const updatedUser = await User.findByIdAndUpdate(
      req.user.userId,
      updateData,
      { new: true, runValidators: true }
    ).select('-password');

    if (!updatedUser) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.json({
      message: 'Profile updated successfully!',
      user: {
        id: updatedUser._id,
        fullName: updatedUser.fullName,
        email: updatedUser.email,
        
        gradYear: updatedUser.gradYear,
        phone: updatedUser.phone,
        profilePictureUrl: updatedUser.profilePictureUrl,
        ridePreferences: updatedUser.ridePreferences,
        accountStats: updatedUser.accountStats,
        verification: updatedUser.verification,
        updatedAt: updatedUser.updatedAt
      }
    });
  } catch (error) {
    console.error('Profile update error:', error.message);
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(val => val.message);
      return res.status(400).json({ message: messages.join(' ') });
    }
    res.status(500).json({ message: 'Error updating profile.' });
  }
});

app.put('/api/change-password', authenticateToken, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({ message: 'Current password and new password are required.' });
    }

    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Current password is incorrect.' });
    }

    const hashedNewPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedNewPassword;
    await user.save();

    res.json({ message: 'Password changed successfully!' });
  } catch (error) {
    console.error('Password change error:', error.message);
    res.status(500).json({ message: 'Error changing password.' });
  }
});

// --- Ride Endpoints ---
app.post('/api/rides', authenticateToken, async (req, res) => {
  try {
    const {
      departure, destination, rideDate, rideTime, availableSeats,
      price, tripType, isRecurring, vehicleModel, vehicleColor,
      licensePlate, features, notes
    } = req.body;

    if (!departure || !destination || !rideDate || !rideTime || !availableSeats || price === undefined || !vehicleModel) {
      return res.status(400).json({ message: 'Please fill out all required fields.' });
    }

    const newRide = new Ride({
      driver: req.user.userId,
      departure, destination, rideDate, rideTime,
      availableSeats: parseInt(availableSeats),
      price: parseFloat(price),
      tripType, isRecurring, vehicleModel, vehicleColor,
      licensePlate, features, notes
    });

    const savedRide = await newRide.save();
    console.log('Ride created by:', req.user.fullName, '| Ride ID:', savedRide._id);
    res.status(201).json({ message: 'Ride published successfully!', ride: savedRide });
  } catch (error) {
    console.error('Create ride server error:', error.message);
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(val => val.message);
      return res.status(400).json({ message: messages.join(' ') });
    }
    res.status(500).json({ message: 'Server error while creating ride. Please try again.' });
  }
});

app.get('/api/rides', authenticateToken, async (req, res) => {
  try {
    const rides = await Ride.find({
      status: { $in: ['Offered'] },
      rideDate: { $gte: new Date() }
    })
      .populate('driver', 'fullName')
      .sort({ rideDate: 'asc' });
    res.status(200).json(rides);
  } catch (error) {
    console.error('Error fetching rides:', error.message);
    res.status(500).json({ message: 'Server error while fetching rides.' });
  }
});

app.get('/api/my-rides', authenticateToken, async (req, res) => {
  try {
    const myRides = await Ride.find({ driver: req.user.userId })
      .populate('driver', 'fullName')
      .sort({ rideDate: 'asc' });
    res.status(200).json(myRides);
  } catch (error) {
    console.error('Error fetching my rides:', error.message);
    res.status(500).json({ message: 'Server error while fetching your rides.' });
  }
});

app.delete('/api/rides/:rideId', authenticateToken, async (req, res) => {
  try {
    const { rideId } = req.params;

    const ride = await Ride.findById(rideId);
    if (!ride) {
      return res.status(404).json({ message: 'Ride not found.' });
    }

    if (ride.driver.toString() !== req.user.userId) {
      return res.status(403).json({ message: 'You can only cancel your own rides.' });
    }

    ride.status = 'Cancelled';
    await ride.save();

    await RideRequest.updateMany(
      { ride: rideId, status: 'pending' },
      { status: 'cancelled' }
    );

    console.log('Ride cancelled:', { rideId, driver: req.user.fullName });
    res.json({ message: 'Ride cancelled successfully!' });
  } catch (error) {
    console.error('Cancel ride error:', error.message);
    res.status(500).json({ message: 'Server error while cancelling ride.' });
  }
});

// --- Ride Request Endpoints ---
app.post('/api/ride-requests', authenticateToken, async (req, res) => {
  try {
    const { rideId, message } = req.body;

    if (!rideId) {
      return res.status(400).json({ message: 'Ride ID is required.' });
    }

    const ride = await Ride.findById(rideId).populate('driver', 'fullName');
    if (!ride) {
      return res.status(404).json({ message: 'Ride not found.' });
    }

    if (ride.status !== 'Offered') {
      return res.status(400).json({ message: 'This ride is no longer available.' });
    }

    if (ride.availableSeats <= 0) {
      return res.status(400).json({ message: 'This ride is full.' });
    }

    if (ride.driver._id.toString() === req.user.userId) {
      return res.status(400).json({ message: 'You cannot request your own ride.' });
    }

    const existingRequest = await RideRequest.findOne({
      ride: rideId,
      passenger: req.user.userId,
      status: { $in: ['pending', 'accepted'] }
    });

    if (existingRequest) {
      return res.status(409).json({ message: 'You have already requested this ride.' });
    }

    const newRequest = new RideRequest({
      ride: rideId,
      passenger: req.user.userId,
      driver: ride.driver._id,
      message: message || ''
    });

    await newRequest.save();
    console.log('Ride request created:', { requestId: newRequest._id, rideId, passenger: req.user.fullName });
    res.status(201).json({ message: 'Ride request sent successfully!' });
  } catch (error) {
    console.error('Create ride request error:', error.message);
    res.status(500).json({ message: 'Server error while sending ride request.' });
  }
});

app.get('/api/ride-requests/received', authenticateToken, async (req, res) => {
  try {
    const requests = await RideRequest.find({ driver: req.user.userId })
      .populate('passenger', 'fullName email')
      .populate('ride', 'departure destination rideDate rideTime price status')
      .sort({ createdAt: 'desc' });
    res.status(200).json(requests);
  } catch (error) {
    console.error('Error fetching received requests:', error.message);
    res.status(500).json({ message: 'Server error while fetching ride requests.' });
  }
});

app.get('/api/ride-requests/sent', authenticateToken, async (req, res) => {
  try {
    const requests = await RideRequest.find({ passenger: req.user.userId })
      .populate('driver', 'fullName email')
      .populate('ride', 'departure destination rideDate rideTime price status')
      .sort({ createdAt: 'desc' });
    res.status(200).json(requests);
  } catch (error) {
    console.error('Error fetching sent requests:', error.message);
    res.status(500).json({ message: 'Server error while fetching your ride requests.' });
  }
});

app.put('/api/ride-requests/:requestId', authenticateToken, async (req, res) => {
  const { requestId } = req.params;
  const { status } = req.body;

  if (!['accepted', 'rejected'].includes(status)) {
    return res.status(400).json({ message: 'Invalid status. Must be "accepted" or "rejected".' });
  }

  const session = await mongoose.startSession();

  try {
    session.startTransaction();

    const request = await RideRequest.findById(requestId)
      .populate('ride')
      .populate('passenger', 'fullName')
      .session(session);

    if (!request) {
      await session.abortTransaction();
      return res.status(404).json({ message: 'Ride request not found.' });
    }

    if (request.driver.toString() !== req.user.userId) {
      await session.abortTransaction();
      return res.status(403).json({ message: 'You can only update requests for your rides.' });
    }

    if (request.status !== 'pending') {
      await session.abortTransaction();
      return res.status(400).json({ message: 'This request has already been processed.' });
    }

    const ride = await Ride.findById(request.ride._id).session(session);
    if (!ride) {
      await session.abortTransaction();
      return res.status(404).json({ message: 'Associated ride not found.' });
    }

    if (ride.status === 'Cancelled' || ride.status === 'Completed') {
      request.status = 'rejected';
      await request.save({ session });
      await session.commitTransaction();
      return res.status(400).json({ message: 'This ride is no longer available, request has been automatically rejected.' });
    }

    if (status === 'accepted') {
      if (ride.availableSeats <= 0) {
        request.status = 'rejected';
        await request.save({ session });
        await session.commitTransaction();
        return res.status(400).json({ message: 'No seats available for this ride, request has been automatically rejected.' });
      }

      ride.availableSeats -= 1;

      if (ride.availableSeats === 0) {
        ride.status = 'Full';
      }

      await ride.save({ session });
    }

    request.status = status;
    await request.save({ session });

    await session.commitTransaction();

    console.log(`Ride request ${status}:`, {
      requestId,
      passenger: request.passenger.fullName,
      rideId: ride._id,
      remainingSeats: ride.availableSeats
    });

    res.json({
      message: `Ride request ${status} successfully!`,
      rideStatus: ride.status,
      availableSeats: ride.availableSeats
    });
  } catch (error) {
    await session.abortTransaction();
    console.error('Update ride request error:', error.message);
    res.status(500).json({ message: 'Server error while updating ride request. Please try again.' });
  } finally {
    session.endSession();
  }
});

// Catch-all route to serve frontend homepage
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../Frontend/homepage.html'));
});

// --- Start the Server ---
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});

// --- Firebase Integration Endpoints ---

// Create user from Firebase signup
app.post('/api/users', async (req, res) => {
  try {
    const {

      email,
      fullName,
      studentId,
      phoneNumber,
      college,
      collegeDomain,
      graduationYear,
      createdAt,
      isEmailVerified,
      isPhoneVerified
    } = req.body;

    // Validate required fields
    if (!firebaseUid || !email || !fullName || !studentId || !phoneNumber || !college || !collegeDomain || !graduationYear) {
      return res.status(400).json({
        message: 'All required fields must be provided.'
      });
    }

    // Validate college domain
    if (!email.endsWith('@vit.edu')) {
      return res.status(400).json({
        message: 'Only @vit.edu emails are allowed.'
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({
      $or: [
        { firebaseUid: firebaseUid },
        { email: email.toLowerCase() },
        { studentId: studentId }
      ]
    });

    if (existingUser) {
      return res.status(409).json({
        message: 'User already exists with this Firebase UID, email, or student ID.'
      });
    }

    // Create new user
    const newUser = new User({
      firebaseUid,
      email: email.toLowerCase(),
      fullName,
      studentId,
      phoneNumber,
      college,
      collegeDomain: collegeDomain.toLowerCase(),
      gradYear: graduationYear,
      verification: {
        isEmailVerified: isEmailVerified || false,
        isPhoneVerified: isPhoneVerified || false,
        studentIdVerified: false,
        driverLicenseVerified: false
      },
      createdAt: createdAt ? new Date(createdAt) : new Date()
    });

    const savedUser = await newUser.save();

    console.log('New Firebase user created:', {
      id: savedUser._id,
      email: savedUser.email,
      college: savedUser.college,
      firebaseUid: savedUser.firebaseUid
    });

    res.status(201).json({
      message: 'User created successfully!',
      userId: savedUser._id,
      user: {
        id: savedUser._id,
        firebaseUid: savedUser.firebaseUid,
        email: savedUser.email,
        fullName: savedUser.fullName,
        college: savedUser.college,
        collegeDomain: savedUser.collegeDomain
      }
    });

  } catch (error) {
    console.error('Create Firebase user error:', error.message);

    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(val => val.message);
      return res.status(400).json({ message: messages.join(' ') });
    }

    if (error.code === 11000) {
      return res.status(409).json({
        message: 'User with this email, Firebase UID, or student ID already exists.'
      });
    }

    res.status(500).json({
      message: 'Server error during user creation. Please try again later.'
    });
  }
});



// Check if phone number exists (for forgot password)
app.post('/api/check-phone', async (req, res) => {
  try {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ message: 'Phone number is required.' });
    }

    const user = await User.findOne({ phoneNumber }).select('email fullName college');

    if (!user) {
      return res.status(404).json({
        message: 'No account found with this phone number.'
      });
    }

    res.json({
      message: 'Phone number found.',
      user: {
        email: user.email,
        fullName: user.fullName,
        college: user.college
      }
    });

  } catch (error) {
    console.error('Check phone error:', error.message);
    res.status(500).json({ message: 'Server error while checking phone number.' });
  }
});

// Update rides endpoint to filter by college

