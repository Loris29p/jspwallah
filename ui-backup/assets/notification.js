/**
 * Modern Notification System
 * Features:
 * - Fade in from bottom, fade out to top animation
 * - Customizable notification color
 * - Customizable duration with progress bar
 * - Customizable progress bar color
 * - Sound effect on notification appearance
 * - Responsive design
 * - FiveM color code support (~r~, ~b~, etc.)
 * - Enhanced text visibility with shadows and improved contrast
 */

// Notification state and configuration
let notificationTimeout = null;
let notificationSound = null;

// Listen for notification events from the game
window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'notification') {
        showNotification(data.text, {
            color: data.color || 'default',
            progressColor: data.progressColor || null,
            duration: data.duration || 5000,
            sound: data.sound || 'notification.ogg'
        });
    }
});

/**
 * Convert FiveM color codes to HTML
 * 
 * @param {string} text - Text with FiveM color codes
 * @returns {string} - HTML formatted text with color spans
 */
function convertFiveMColors(text) {
    if (!text) return '';
    
    // Define color mapping (FiveM code to hex)
    const colorMap = {
        '~r~': '#FF0000', // Red
        '~b~': '#0000FF', // Blue
        '~g~': '#00FF00', // Green
        '~y~': '#FFFF00', // Yellow
        '~p~': '#800080', // Purple
        '~c~': '#00FFFF', // Cyan
        '~m~': '#FF00FF', // Magenta
        '~u~': '#000000', // Black
        '~o~': '#FFA500', // Orange
        '~s~': '#808080', // Gray
        '~w~': '#FFFFFF', // White
        '~h~': '#FFFFFF',  // Highlight (white/bold)

        '~p~': '#b88fff',
    };
    
    let formattedText = text;
    let currentColor = null;
    let result = '';
    let i = 0;
    
    while (i < formattedText.length) {
        // Check if current position is a color code
        if (i + 2 < formattedText.length && formattedText[i] === '~') {
            let potentialColorCode = formattedText.substring(i, i + 3);
            
            if (colorMap[potentialColorCode]) {
                // If a color span is already open, close it
                if (currentColor) {
                    result += '</span>';
                }
                
                // Open a new color span with text shadow for better visibility
                currentColor = colorMap[potentialColorCode];
                result += `<span style="color: ${currentColor}; text-shadow: 0 0 1px #000, 0 0 2px #000;">`;
                i += 3; // Skip the color code
                continue;
            }
        }
        
        // Add the current character to the result
        result += formattedText[i];
        i++;
    }
    
    // Close any open span
    if (currentColor) {
        result += '</span>';
    }
    
    return result;
}

/**
 * Show a notification with custom options
 * 
 * @param {string} message - Text message to display
 * @param {Object} options - Notification options
 * @param {string} options.color - Color theme ('success', 'error', 'info', 'warning', or hex color)
 * @param {string} options.progressColor - Color for the progress bar (hex color or null to match notification color)
 * @param {number} options.duration - Duration in ms before notification disappears
 * @param {string} options.sound - Path to sound file to play
 * @returns {void}
 */
function showNotification(message, options = {}) {
    // Default options
    const config = {
        color: options.color || 'default',
        progressColor: options.progressColor || null,
        duration: options.duration || 5000,
        sound: options.sound || 'notification.ogg'
    };

    // Get notification elements
    const notificationEl = document.getElementById('modern-notification');
    const messageEl = notificationEl.querySelector('.notification-message');
    const progressEl = notificationEl.querySelector('.notification-progress');
    
    // Convert FiveM color codes and set message
    const formattedMessage = convertFiveMColors(message);
    messageEl.innerHTML = formattedMessage;
    
    // Apply enhanced text styles for better visibility
    messageEl.style.fontSize = '1.1rem';
    messageEl.style.fontWeight = '600';
    messageEl.style.textShadow = '0 0 2px rgba(0, 0, 0, 0.7)';
    messageEl.style.letterSpacing = '0.02em';
    
    // Clear any existing timeouts
    if (notificationTimeout) {
        clearTimeout(notificationTimeout);
    }
    
    // Reset classes and add appropriate color class
    notificationEl.classList.remove('hidden', 'show', 'hide', 'success', 'error', 'info', 'warning');
    
    // Reset progress bar color
    document.documentElement.style.setProperty('--progress-bar-color', '');
    
    // Determine notification color
    let notificationColor = null;
    
    // Apply color to notification
    if (['success', 'error', 'info', 'warning'].includes(config.color)) {
        notificationEl.classList.add(config.color);
        
        // Set default progress bar colors based on notification type
        switch(config.color) {
            case 'success':
                notificationColor = '#28a745';
                break;
            case 'error':
                notificationColor = '#dc3545';
                break;
            case 'info':
                notificationColor = '#17a2b8';
                break;
            case 'warning':
                notificationColor = '#ffc107';
                break;
            default:
                notificationColor = '#4CAF50'; // Default green
        }
    } else if (config.color !== 'default') {
        // Apply custom color
        notificationEl.style.backgroundColor = config.color;
        notificationColor = config.color;
    } else {
        notificationColor = '#4CAF50'; // Default green
    }
    
    // Apply progress bar color (either custom or matching notification)
    const progressBarColor = config.progressColor || notificationColor;
    document.documentElement.style.setProperty('--progress-bar-color', progressBarColor);
    
    // Play sound if specified
    if (config.sound) {
        if (notificationSound) {
            notificationSound.pause();
            notificationSound.currentTime = 0;
        }
        
        notificationSound = new Audio(`./assets/sounds/${config.sound}`);
        notificationSound.volume = 0.5;
        notificationSound.play().catch(e => console.error('Error playing notification sound:', e));
    }
    
    // Set animation duration for progress bar
    document.documentElement.style.setProperty('--notification-duration', `${config.duration}ms`);
    
    // Animation sequence
    setTimeout(() => {
        notificationEl.classList.remove('hidden');
        requestAnimationFrame(() => {
            notificationEl.classList.add('show');
        });
    }, 10);
    
    // Set timeout to hide notification
    notificationTimeout = setTimeout(() => {
        notificationEl.classList.remove('show');
        notificationEl.classList.add('hide');
        
        // Remove notification after animation finishes
        setTimeout(() => {
            notificationEl.classList.add('hidden');
        }, 400); // Match the CSS transition duration
    }, config.duration);
}

// Function to call from other scripts
window.notify = showNotification;

// Add animation property for progress bar
document.addEventListener('DOMContentLoaded', function() {
    const styleSheet = document.createElement('style');
    styleSheet.textContent = `
        :root {
            --notification-duration: 5000ms;
            --progress-bar-color: #4CAF50;
        }
        .notification-progress::before {
            transition-duration: var(--notification-duration);
            background-color: var(--progress-bar-color) !important;
        }
        
        /* Enhanced text readability styles */
        .notification-message {
            text-shadow: 0 0 2px rgba(0, 0, 0, 0.7);
            font-weight: 600;
            font-size: 1.1rem;
            letter-spacing: 0.02em;
            line-height: 1.4;
            padding: 10px;
        }
        
        /* Ensure dark backgrounds have better contrast with text */
        .notification-container {
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
        }
        
        /* Improved visibility for colored spans */
        .notification-message span {
            text-shadow: 0 0 2px rgba(0, 0, 0, 0.8), 0 0 3px rgba(0, 0, 0, 0.6);
            font-weight: bold;
        }
    `;
    document.head.appendChild(styleSheet);
    
    // Create sounds directory if needed (this is just a reminder, it won't execute in the browser)
    console.log('Remember to create the directory: server-data/resources/[pvp]/gamemode/ui/assets/sounds/ for notification sounds');
});

/**
 * Demo function for testing notifications
 * 
 * Examples:
 * - notifyDemo('Welcome to the server!', 'info', 5000, 'notification.ogg')
 * - notifyDemo('Mission completed!', 'success', 3000, 'success.ogg')
 * - notifyDemo('Warning: Red zone active!', 'warning', 7000, 'warning.ogg')
 * - notifyDemo('Error: Connection lost', 'error', 4000, 'error.ogg')
 * - notifyDemo('Custom notification', '#9c27b0', 5000, 'custom.ogg')
 * - notifyDemo('~r~Red ~b~Blue ~g~Green text', 'default', 5000, 'notification.ogg')
 */
function notifyDemo(message, color = 'default', duration = 5000, sound = 'notification.ogg', progressColor = null) {
    showNotification(message, {
        color: color,
        duration: duration,
        sound: sound,
        progressColor: progressColor
    });
}

// Examples of how to trigger notifications from the game side:
/*
    // In your client-side script:
    function showGameNotification(message, color, duration, sound, progressColor) {
        SendNUIMessage({
            type: 'notification',
            text: message,
            color: color,
            duration: duration,
            sound: sound,
            progressColor: progressColor
        });
    }

    // Examples:
    showGameNotification('Welcome to the server!', 'info', 5000, 'notification.ogg');
    showGameNotification('Mission completed!', 'success', 3000, 'success.ogg');
    showGameNotification('Warning: Red zone active!', 'warning', 7000, 'warning.ogg');
    showGameNotification('Error: Connection lost', 'error', 4000, 'error.ogg');
    showGameNotification('Custom notification', '#9c27b0', 5000, 'custom.ogg');
    showGameNotification('~r~Red ~b~Blue ~g~Green text', 'default', 5000, 'notification.ogg');
    showGameNotification('Custom progress bar color', 'default', 5000, 'notification.ogg', '#FF5722');
*/