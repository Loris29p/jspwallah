// Guild PVP Killfeed System - Original Implementation
// Custom fade system with unique structure

let killDisplayArea = null;
let feedVisible = true;
const KILL_TIMEOUT = 7000; // 2 seconds
const MAX_VISIBLE_KILLS = 5;
let killCounter = 0;

// Function to process player names and preserve color formatting
function processPlayerName(name) {
    if (!name) return { segments: [] };
    
    // Split the name into segments with their colors
    const segments = [];
    let currentIndex = 0;
    
    // Get all FONT tags and their content
    const regex = /<FONT color=['"]([^'"]+)['"]>([^<]+)<\/FONT>/g;
    let match;
    let lastIndex = 0;
    
    // Add any text before the first FONT tag
    const beforeFirst = name.split(/<FONT/)[0];
    if (beforeFirst) {
        segments.push({ text: beforeFirst, color: null });
    }
    
    // Process each FONT tag
    while ((match = regex.exec(name)) !== null) {
        const color = match[1];
        const text = match[2];
        segments.push({ text, color });
    }
    
    return { segments };
}

// Initialize the killfeed display area
function SetupKillDisplay() {
    if (!killDisplayArea) {
        killDisplayArea = document.createElement('div');
        killDisplayArea.className = 'kill-display-area';
        
        // Styles pour forcer la visibilité (sans debug)
        killDisplayArea.style.cssText = `
            display: block !important;
            position: fixed !important;
            top: 8vh !important;
            right: 2vh !important;
            z-index: 9999 !important;
            min-width: 300px !important;
            padding: 10px !important;
            font-family: 'Exo', sans-serif !important;
            color: white !important;
            width: auto !important;
            height: auto !important;
            visibility: visible !important;
            opacity: 1 !important;
            flex-direction: column !important;
            gap: 0.8vh !important;
            pointer-events: none !important;
            user-select: none !important;
        `;
        
        document.body.appendChild(killDisplayArea);
    }
    
    // Apply visibility setting
    ApplyFeedVisibility();
}

// Control feed visibility
function ApplyFeedVisibility() {
    if (!killDisplayArea) return;
    
    // Forcer la visibilité (on peut remettre la logique normale plus tard)
    killDisplayArea.style.display = feedVisible ? 'block' : 'none';
    killDisplayArea.style.visibility = 'visible';
}

// Create a new kill notification
function AddKillNotification(attackerName, attackerColor, weaponPath, victimName, victimColor, redZoneKill, victimPrestige, attackerPrestige, ffaMode) {
    if (!killDisplayArea) {
        SetupKillDisplay();
    }
    
    killDisplayArea.style.display = 'block';
    killDisplayArea.style.visibility = 'visible';
    
    console.log(attackerName, "ATTACKER NAME")
    console.log(victimName, "VICTIM NAME")
    
    // Process player names and extract colors
    const processedAttacker = processPlayerName(attackerName);
    const processedVictim = processPlayerName(victimName);
    
    // Clean up old notifications if we have too many
    const currentNotifications = killDisplayArea.querySelectorAll('.kill-notification');
    if (currentNotifications.length >= MAX_VISIBLE_KILLS) {
        const oldestNotification = currentNotifications[currentNotifications.length - 1];
        if (oldestNotification) {
            killDisplayArea.removeChild(oldestNotification);
        }
    }
    
    // Update fade levels for existing notifications
    currentNotifications.forEach((notification, index) => {
        const fadeLevel = index + 2;
        notification.setAttribute('data-fade-level', fadeLevel);
        notification.style.opacity = CalculateFadeOpacity(fadeLevel);
    });
    
    // Determine notification background
    let notificationBg = 'rgba(0, 0, 0, 0.8)';
    if (redZoneKill) {
        notificationBg = 'rgba(158, 15, 15, 0.8)';
    } else if (ffaMode) {
        notificationBg = 'rgba(74, 183, 255, 0.8)';
    }
    
    // Create the notification element
    const killNotification = document.createElement('div');
    killNotification.className = 'kill-notification';
    killNotification.setAttribute('data-fade-level', '1');
    killNotification.setAttribute('data-kill-id', ++killCounter);
    
    // Build prestige elements
    const attackerPrestigeElement = attackerPrestige > 0 
        ? `<div class="prestige-badge attacker-badge"><img src="./assets/badges/badge_${attackerPrestige}.png" alt="Badge"></div>`
        : '';
    
    const victimPrestigeElement = victimPrestige > 0 
        ? `<div class="prestige-badge victim-badge"><img src="./assets/badges/badge_${victimPrestige}.png" alt="Badge"></div>`
        : '';
    
    // Build attacker text with multiple colors
    const attackerTextHtml = processedAttacker.segments.map(segment => 
        segment.color 
            ? `<span style="color: ${segment.color}">${segment.text}</span>`
            : segment.text
    ).join('');
    
    // Build victim text with multiple colors
    const victimTextHtml = processedVictim.segments.map(segment => 
        segment.color 
            ? `<span style="color: ${segment.color}">${segment.text}</span>`
            : segment.text
    ).join('');
    
    // Build the notification structure
    killNotification.innerHTML = `
        <div class="notification-content" style="background-color: ${notificationBg};">
            ${attackerPrestigeElement}
            <span class="attacker-text">${attackerTextHtml}</span>
            <div class="weapon-display">
                <img src="${weaponPath}" alt="Weapon" class="weapon-image" style="transform: scaleX(-1);">
            </div>
            <span class="victim-text">${victimTextHtml}</span>
            ${victimPrestigeElement}
        </div>
    `;
    
    // Set initial opacity
    killNotification.style.opacity = CalculateFadeOpacity(1);
    
    // Add to display area at the top
    killDisplayArea.insertBefore(killNotification, killDisplayArea.firstChild);
    
    // Schedule removal
    setTimeout(() => {
        if (killNotification && killNotification.parentNode === killDisplayArea) {
            killDisplayArea.removeChild(killNotification);
        }
    }, KILL_TIMEOUT);
}

// Calculate opacity based on fade level
function CalculateFadeOpacity(level) {
    switch (level) {
        case 1: return 1.0;
        case 2: return 0.9;
        case 3: return 0.7;
        case 4: return 0.6;
        case 5: return 0.3;
        default: return 0.1;
    }
}

// Handle game messages
window.addEventListener('message', function(event) {
    const messageData = event.data;
    
    switch (messageData.type) {
        case 'killfeed':
            AddKillNotification(
                messageData.killer,
                "#ffffff",
                './assets/items/' + messageData.weapon + '.png',
                messageData.victim,
                "#cc0000",
                messageData.isRedzone,
                messageData.prestige,
                messageData.killerPrestige,
                messageData.isFFA
            );
            break;
            
        case 'killfeed_status':
            feedVisible = messageData.status;
            ApplyFeedVisibility();
            break;
    }
});

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    feedVisible = true; // Force la killfeed à être visible par défaut
    SetupKillDisplay();
});
