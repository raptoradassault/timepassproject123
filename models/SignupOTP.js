const mongoose = require('mongoose');

const signupOTPSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        lowercase: true
    },
    otp: {
        type: String,
        required: true
    },
    userData: {
        fullName:   { type: String, required: true },
        email:      { type: String, required: true },
        password:   { type: String, required: true },
        gradYear:   { type: Number, required: true },

        // Add the missing required fields:
        college:        { type: String, required: true },        // <--- add
        collegeDomain:  { type: String, required: true },        // <--- add
        phoneNumber:    { type: String, required: true },        // <--- add
        studentId:      { type: String, required: true }         // <--- add
    },
    createdAt: {
        type: Date,
        default: Date.now,
        expires: 600 // 10 minutes
    }
});

module.exports = mongoose.model('SignupOTP', signupOTPSchema);
