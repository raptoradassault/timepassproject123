const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const userSchema = new Schema({
  // Firebase Integration


  fullName: {
    type: String,
    required: [true, 'Full name is required.'],
    trim: true
  },

  email: {
    type: String,
    required: [true, 'Email is required.'],
    unique: true,
    trim: true,
    lowercase: true,
    match: [/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu$/, 'Please fill a valid .edu email address (e.g., student@vit.edu)']
  },

  // Student Information
  studentId: {
    type: String,
    required: [true, 'Student ID is required.'],
    trim: true
  },

  phoneNumber: {
    type: String,
    required: [true, 'Phone number is required for OTP verification.'],
    trim: true
  },

  // College Information (Multi-college support)
  college: {
    type: String,
    required: [true, 'College name is required.'],
    trim: true
  },

  collegeDomain: {
    type: String,
    required: [true, 'College domain is required.'],
    trim: true,
    lowercase: true
  },

  gradYear: {
    type: Number,
    required: [true, 'Graduation year is required.'],
    min: [new Date().getFullYear(), 'Graduation year cannot be in the past.'],
    max: [new Date().getFullYear() + 6, 'Graduation year seems too far in the future.']
  },

  // Legacy password field (kept for backward compatibility)
  password: {
    type: String,
    default: '', // Firebase handles auth, so this is optional
    minlength: [0, 'Password must be at least 8 characters long.']
  },

  // NEW EMAIL VERIFICATION FIELDS (ADD THESE)
  emailVerificationToken: {
    type: String,
    default: null
  },

  emailVerificationExpires: {
    type: Date,
    default: null
  },

  isEmailVerifiedCustom: {
    type: Boolean,
    default: false
  },

  profilePictureUrl: {
    type: String,
    default: 'https://via.placeholder.com/120'
  },

  ridePreferences: {
    preferredPickupLocations: {
      type: String,
      default: ''
    },
    musicPreference: {
      type: String,
      enum: ['No Preference', 'Yes', 'No'],
      default: 'No Preference'
    },
    chatPreference: {
      type: String,
      enum: ['No Preference', 'Yes', 'No'],
      default: 'No Preference'
    },
    maxPassengers: {
      type: Number,
      default: 4,
      min: 1,
      max: 8
    }
  },

  accountStats: {
    totalRides: {
      type: Number,
      default: 0
    },
    averageRating: {
      type: Number,
      default: 0
    },
    totalSavings: {
      type: Number,
      default: 0
    },
    co2Saved: {
      type: Number,
      default: 0
    }
  },

  verification: {
    isEmailVerified: {
      type: Boolean,
      default: false
    },
    isPhoneVerified: {
      type: Boolean,
      default: false
    },
    studentIdVerified: {
      type: Boolean,
      default: false
    },
    driverLicenseVerified: {
      type: Boolean,
      default: false
    }
  },

  createdAt: {
    type: Date,
    default: Date.now
  },

  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Update the updatedAt field before saving
userSchema.pre('save', function (next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('User', userSchema);
