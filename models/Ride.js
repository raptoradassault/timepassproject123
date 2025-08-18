const mongoose = require('mongoose');

const rideSchema = new mongoose.Schema({
    driver: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User', // This links the ride to a specific user (the driver)
        required: true,
    },
    departure: {
        type: String,
        required: [true, 'Departure location is required.'],
        trim: true,
    },
    destination: {
        type: String,
        required: [true, 'Destination is required.'],
        trim: true,
    },
    rideDate: {
        type: Date,
        required: [true, 'Ride date is required.'],
    },
    rideTime: {
        type: String, // Storing as a string like "14:30" is simple and effective
        required: [true, 'Ride time is required.'],
    },
    availableSeats: {
        type: Number,
        required: [true, 'Number of available seats is required.'],
        // --- FIX: Changed min value from 1 to 0 ---
        // This allows the number of seats to become 0 when the ride is full.
        min: 0,
    },
    price: {
        type: Number,
        required: [true, 'Price per passenger is required.'],
        min: 0,
    },
    tripType: {
        type: String,
        enum: ['one-way', 'round-trip'],
        default: 'one-way',
    },
    isRecurring: {
        type: Boolean,
        default: false,
    },
    vehicleModel: {
        type: String,
        required: [true, 'Vehicle make and model are required.'],
        trim: true,
    },
    vehicleColor: {
        type: String,
        trim: true,
    },
    licensePlate: {
        type: String,
        trim: true,
    },
    features: {
        type: [String], // An array of strings like ["Air Conditioning", "USB Charger"]
        default: [],
    },
    notes: {
        type: String,
        trim: true,
    },
    status: {
        type: String,
        enum: ['Offered', 'Full', 'Completed', 'Cancelled'],
        default: 'Offered',
    },
}, {
    timestamps: true // Automatically adds createdAt and updatedAt fields
});

const Ride = mongoose.model('Ride', rideSchema);

module.exports = Ride;