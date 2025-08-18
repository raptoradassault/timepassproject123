const mongoose = require('mongoose');

const rideRequestSchema = new mongoose.Schema({
    ride: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Ride',
        required: true,
    },
    passenger: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    driver: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    message: {
        type: String,
        trim: true,
        default: '',
    },
    status: {
        type: String,
        enum: ['pending', 'accepted', 'rejected', 'cancelled'], // Added 'cancelled' to the enum
        default: 'pending',
    },
}, {
    timestamps: true
});

// Compound index to prevent duplicate requests from the same passenger for the same ride
// This constraint is only effective for requests that are not in a 'rejected' or 'cancelled' state
rideRequestSchema.index({ ride: 1, passenger: 1 }, { unique: true, partialFilterExpression: { status: { $in: ['pending', 'accepted'] } } });

const RideRequest = mongoose.model('RideRequest', rideRequestSchema);
module.exports = RideRequest;