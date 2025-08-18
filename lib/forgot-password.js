// forgot-password.js
// DOM Elements
const emailStep = document.getElementById('emailStep');
const codeVerificationSection = document.getElementById('codeVerificationSection');
const successMessage = document.getElementById('successMessage');
const forgotPasswordForm = document.getElementById('forgotPasswordForm');
const sendCodeBtn = document.getElementById('sendCodeBtn');
const resetPasswordBtn = document.getElementById('resetPasswordBtn');
const backToEmailBtn = document.getElementById('backToEmailBtn');
const resendCodeBtn = document.getElementById('resendCodeBtn');

// Step indicators
const step1 = document.getElementById('step1');
const step2 = document.getElementById('step2');
const step3 = document.getElementById('step3');
const line1 = document.getElementById('line1');
const line2 = document.getElementById('line2');

// Utility Functions
function togglePasswordVisibility(inputId, iconElement) {
    const passwordInput = document.getElementById(inputId);
    if (!passwordInput) return;
    const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
    passwordInput.setAttribute('type', type);
    iconElement.classList.toggle('ri-eye-off-line');
    iconElement.classList.toggle('ri-eye-line');
}

function updateStepIndicator(currentStep) {
    // Reset all steps
    [step1, step2, step3].forEach(step => {
        step.classList.remove('active');
        step.classList.add('inactive');
    });
    [line1, line2].forEach(line => {
        line.classList.remove('active');
    });

    // Activate current and previous steps
    if (currentStep >= 1) {
        step1.classList.add('active');
        step1.classList.remove('inactive');
    }
    if (currentStep >= 2) {
        line1.classList.add('active');
        step2.classList.add('active');
        step2.classList.remove('inactive');
    }
    if (currentStep >= 3) {
        line2.classList.add('active');
        step3.classList.add('active');
        step3.classList.remove('inactive');
    }
}

function showLoading(button) {
    button.disabled = true;
    button.classList.add('loading');
    button.querySelector('.btn-text').classList.add('hidden');
    button.querySelector('.btn-loading').classList.remove('hidden');
}

function hideLoading(button) {
    button.disabled = false;
    button.classList.remove('loading');
    button.querySelector('.btn-text').classList.remove('hidden');
    button.querySelector('.btn-loading').classList.add('hidden');
}

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 p-4 rounded-md shadow-lg z-50 ${
        type === 'success' ? 'bg-green-500 text-white' :
        type === 'error' ? 'bg-red-500 text-white' :
        'bg-blue-500 text-white'
    }`;
    notification.innerHTML = `
        <div class="flex items-center">
            <i class="ri-${type === 'success' ? 'check' : type === 'error' ? 'error-warning' : 'information'}-line mr-2"></i>
            <span>${message}</span>
        </div>
    `;
    
    document.body.appendChild(notification);
    
    // Remove notification after 5 seconds
    setTimeout(() => {
        notification.remove();
    }, 5000);
}

// Step 1: Send reset code
forgotPasswordForm.addEventListener('submit', async (e) => {
    e.preventDefault(); // This is crucial!
    e.stopPropagation(); // Additional prevention
    
    const email = document.getElementById('resetEmail').value.trim();
    
    if (!email) {
        showNotification('Please enter your email address', 'error');
        return false; // Prevent any further processing
    }

    showLoading(sendCodeBtn);
    
    try {
        console.log('Sending request to:', '/api/forgot-password'); // Debug log
        console.log('Email:', email); // Debug log
        
        // Request reset code from server
        const response = await fetch('/api/forgot-password', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email })
        });
        
        console.log('Response status:', response.status); // Debug log
        const result = await response.json();
        console.log('Response data:', result); // Debug log
        
        if (response.ok) {
            // Send email using EmailJS
            await emailjs.send('service_4mymvbp', 'template_j5h8wdn', {
                to_email: email,
                reset_code: result.resetCode,
                user_name: email.split('@')[0]
            });
            
            showNotification('Reset code sent to your email!', 'success');
            
            // Show code verification step
            emailStep.classList.add('hidden');
            codeVerificationSection.classList.remove('hidden');
            updateStepIndicator(2);
        } else {
            showNotification(result.message || 'Failed to send reset code', 'error');
        }
    } catch (error) {
        console.error('Error:', error);
        showNotification('Failed to send reset code. Please check your connection and try again.', 'error');
    } finally {
        hideLoading(sendCodeBtn);
    }
    
    return false; // Ensure no form submission
});

// Step 2: Reset password (THIS WAS MISSING!)
resetPasswordBtn.addEventListener('click', async () => {
    const email = document.getElementById('resetEmail').value.trim();
    const resetCode = document.getElementById('resetCode').value.trim();
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    
    // Validation
    if (!resetCode || resetCode.length !== 6) {
        showNotification('Please enter a valid 6-digit code', 'error');
        document.getElementById('resetCode').focus();
        return;
    }
    
    if (!newPassword || newPassword.length < 6) {
        showNotification('Password must be at least 6 characters long', 'error');
        document.getElementById('newPassword').focus();
        return;
    }
    
    if (newPassword !== confirmPassword) {
        showNotification('Passwords do not match', 'error');
        document.getElementById('confirmPassword').focus();
        return;
    }
    
    showLoading(resetPasswordBtn);
    
    try {
        const response = await fetch('/api/reset-password', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, resetCode, newPassword })
        });
        
        const result = await response.json();
        
        if (response.ok) {
            // Show success message
            codeVerificationSection.classList.add('hidden');
            successMessage.classList.remove('hidden');
            updateStepIndicator(3);
            showNotification('Password reset successful!', 'success');
        } else {
            showNotification(result.message || 'Failed to reset password', 'error');
        }
    } catch (error) {
        console.error('Error:', error);
        showNotification('Failed to reset password. Please try again.', 'error');
    } finally {
        hideLoading(resetPasswordBtn);
    }
});

// Back to email step (THIS WAS MISSING!)
backToEmailBtn.addEventListener('click', () => {
    codeVerificationSection.classList.add('hidden');
    emailStep.classList.remove('hidden');
    updateStepIndicator(1);
    
    // Clear form fields
    document.getElementById('resetCode').value = '';
    document.getElementById('newPassword').value = '';
    document.getElementById('confirmPassword').value = '';
});

// Resend code
resendCodeBtn.addEventListener('click', async () => {
    const email = document.getElementById('resetEmail').value.trim();
    
    if (!email) {
        showNotification('Email address is required', 'error');
        return;
    }

    try {
        const response = await fetch('/api/forgot-password', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email })
        });
        
        const result = await response.json();
        
        if (response.ok) {
            await emailjs.send('service_4mymvbp', 'template_j5h8wdn', {
                to_email: email,
                reset_code: result.resetCode,
                user_name: email.split('@')[0]
            });
            
            showNotification('New reset code sent!', 'success');
        } else {
            showNotification(result.message || 'Failed to resend code', 'error');
        }
    } catch (error) {
        console.error('Error:', error);
        showNotification('Failed to resend code. Please try again.', 'error');
    }
});

// Auto-format reset code input (numbers only)
document.getElementById('resetCode').addEventListener('input', (e) => {
    e.target.value = e.target.value.replace(/[^0-9]/g, '');
});

// Real-time password validation
document.getElementById('confirmPassword').addEventListener('input', (e) => {
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = e.target.value;
    
    if (confirmPassword && newPassword !== confirmPassword) {
        e.target.style.borderColor = '#ef4444';
    } else {
        e.target.style.borderColor = '#d1d5db';
    }
});

// Initialize step indicator
updateStepIndicator(1);

// Add debug logging to check if script loads
console.log('forgot-password.js loaded successfully');
