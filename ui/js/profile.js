// Profile System for Guild PVP
// Enhanced player profile display with modern UI

let playerProfileData = null;
let profileCache = {
    data: null,
    timestamp: 0
};

const PROFILE_CACHE_DURATION = 10000; // 10 seconds cache

// Initialize profile system
function InitializeProfile() {
    console.log("Profile system initialized");
    
    // Add profile navigation handler
    $(document).on('click', '.menu-link:contains("PROFILE")', function(e) {
        e.preventDefault();
        ShowProfile();
    });
}

// Main function to show profile
function ShowProfile() {
    // Hide other sections
    $(".inventorydiv").hide();
    $(".leaderboard-section").hide();
    $(".shop-section").hide();
    $(".ui-tebex").hide();
    
    // Show profile section (create if doesn't exist)
    if (!$(".profile-section").length) {
        CreateProfileSection();
    }
    
    $(".profile-section").show();
    
    // Update navigation
    $(".menu-link").removeClass("current-page");
    $(".menu-link:contains('PROFILE')").addClass("current-page");
    
    // Load profile data
    LoadProfile();
}

// Function to hide profile
function HideProfile() {
    $(".profile-section").hide();
}

// Create profile section HTML structure
function CreateProfileSection() {
    const profileHTML = `
        <div class="profile-section" style="display: none;">
            <div class="profile-container">
                <div class="profile-loading">
                    <div class="loading-spinner"></div>
                    <span>Loading profile...</span>
                </div>
                <div class="profile-content"></div>
            </div>
        </div>
    `;
    
    $(".ui-body").append(profileHTML);
}

// Load profile data with caching
function LoadProfile() {
    const now = Date.now();
    
    // Check cache first
    if (profileCache.data && (now - profileCache.timestamp) < PROFILE_CACHE_DURATION) {
        DisplayProfile(profileCache.data);
        return;
    }
    
    // Show loading
    ShowProfileLoading(true);
    
    // Request fresh data from server
    $.post("https://gamemode/GetPlayerStats", JSON.stringify({}), function(response) {
        // This will trigger the "stats" message event
    }).fail(function() {
        console.error("Failed to load profile data");
        ShowProfileError();
    });
}

// Enhanced profile display function
function LoadProfilePlayer(data) {
    console.log("Loading player profile:", data);
    
    try {
        // Parse data if it's a string
        if (typeof data === 'string') {
            data = JSON.parse(data);
        }
        
        // Cache the data
        profileCache = {
            data: data,
            timestamp: Date.now()
        };
        
        playerProfileData = data;
        
        // Display the profile
        DisplayProfile(data);
        
    } catch (error) {
        console.error("Failed to parse profile data:", error);
        ShowProfileError();
    }
}

// Main profile display function
function DisplayProfile(data) {
    ShowProfileLoading(false);
    
    const profileContent = $(".profile-content");
    profileContent.empty();
    
    // Format data
    const tokenFormatted = formatNumberWithCommas(data.tokens || 0);
    const coinsFormatted = formatNumberWithCommas(data.coins || 0);
    const countryCode = data.country || "GB";
    const flagUrl = `https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${countryCode.toLowerCase()}.svg`;
    
    // Calculate additional stats
    const kdRatio = calculateKDRatio(data.kills || 0, data.death || 0);
    const survivalRate = calculateSurvivalRate(data.kills || 0, data.death || 0);
    const efficiency = calculateEfficiency(data.kills || 0, data.tokens || 0);
    
    // Generate profile HTML
    const profileHTML = `
        <div class="player-profile-enhanced">
            <!-- Header Section -->
            <div class="profile-header-section">
                <div class="profile-banner">
                    <div class="banner-overlay"></div>
                </div>
                
                <div class="profile-info-header">
                    <div class="player-name-section">
                        <h1 class="player-username">${data.username || 'Unknown Player'}</h1>
                        <div class="player-meta">
                            <span class="player-id">ID: #${data.uuid || 'N/A'}</span>
                            <div class="country-info">
                                <img src="${flagUrl}" alt="${data.country}" class="country-flag" onerror="this.src='./assets/default-flag.png'">
                                <span class="country-name">${getCountryName(data.country || 'GB')}</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="crew-info ${data.crewName && data.crewName !== 'None' ? 'has-crew' : 'no-crew'}">
                        <i class="fas fa-users crew-icon"></i>
                        <div class="crew-details">
                            <span class="crew-label">Crew</span>
                            <span class="crew-name">${data.crewName || 'No Crew'}</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Currency Section -->
            <div class="currency-section">
                <div class="currency-card tokens">
                    <div class="currency-icon">
                        <i class="fas fa-coins"></i>
                    </div>
                    <div class="currency-info">
                        <div class="currency-value">${tokenFormatted}</div>
                        <div class="currency-label">Guild Tokens</div>
                        <div class="currency-rank">#${data.placeToken || 'N/A'} Global</div>
                    </div>
                </div>
                
                <div class="currency-card coins">
                    <div class="currency-icon">
                        <img src="./assets/coins.jpg" alt="Guild Coins">
                    </div>
                    <div class="currency-info">
                        <div class="currency-value">${coinsFormatted}</div>
                        <div class="currency-label">Guild Coins</div>
                        <div class="currency-rank">Premium Currency</div>
                    </div>
                </div>
            </div>
            
            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card primary">
                    <div class="stat-icon">
                        <i class="fas fa-crosshairs"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">${data.kills || 0}</div>
                        <div class="stat-label">Total Kills</div>
                        <div class="stat-rank">#${data.placeKill || 'N/A'}</div>
                    </div>
                </div>
                
                <div class="stat-card secondary">
                    <div class="stat-icon">
                        <i class="fas fa-skull"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">${data.death || 0}</div>
                        <div class="stat-label">Deaths</div>
                        <div class="stat-rank">#${data.placeDeath || 'N/A'}</div>
                    </div>
                </div>
                
                <div class="stat-card accent">
                    <div class="stat-icon">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">${kdRatio}</div>
                        <div class="stat-label">K/D Ratio</div>
                        <div class="stat-rank">${getKDRank(kdRatio)}</div>
                    </div>
                </div>
                
                <div class="stat-card special">
                    <div class="stat-icon">
                        <i class="fas fa-star"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">${data.prestige || 0}</div>
                        <div class="stat-label">Prestige Level</div>
                        <div class="stat-rank">${getPrestigeRank(data.prestige || 0)}</div>
                    </div>
                </div>
            </div>
            
            <!-- Achievements Section -->
            <div class="achievements-section">
                <h3 class="section-title">
                    <i class="fas fa-trophy"></i>
                    Achievements
                </h3>
                <div class="achievements-grid">
                    ${generateAchievements(data)}
                </div>
            </div>
            

        </div>
    `;
    
    profileContent.html(profileHTML);
    
    // Add animations
    animateProfileElements();
}

// Helper functions
function calculateKDRatio(kills, deaths) {
    if (deaths === 0) return kills > 0 ? kills.toFixed(2) : "0.00";
    return (kills / deaths).toFixed(2);
}

function calculateSurvivalRate(kills, deaths) {
    const total = kills + deaths;
    if (total === 0) return 0;
    return Math.round((kills / total) * 100);
}

function calculateEfficiency(kills, tokens) {
    if (kills === 0) return 0;
    return tokens / kills;
}

function getKDRank(kd) {
    const ratio = parseFloat(kd);
    if (ratio >= 3.0) return "Elite";
    if (ratio >= 2.0) return "Expert";
    if (ratio >= 1.5) return "Skilled";
    if (ratio >= 1.0) return "Average";
    return "Rookie";
}

function getPrestigeRank(prestige) {
    if (prestige >= 10) return "Legendary";
    if (prestige >= 5) return "Master";
    if (prestige >= 3) return "Expert";
    if (prestige >= 1) return "Advanced";
    return "Beginner";
}

function getCountryName(code) {
    const countries = {
        'FR': 'France', 'US': 'United States', 'GB': 'United Kingdom',
        'DE': 'Germany', 'ES': 'Spain', 'IT': 'Italy', 'CA': 'Canada',
        'AU': 'Australia', 'BR': 'Brazil', 'RU': 'Russia', 'JP': 'Japan'
    };
    return countries[code.toUpperCase()] || code.toUpperCase();
}

function generateAchievements(data) {
    const achievements = [];
    
    // Kill achievements
    if (data.placeKill <= 10) {
        achievements.push({
            icon: 'fas fa-crown',
            title: 'Elite Killer',
            description: `Top 10 Global (#${data.placeKill})`,
            rarity: 'legendary'
        });
    } else if (data.placeKill <= 50) {
        achievements.push({
            icon: 'fas fa-medal',
            title: 'Expert Killer',
            description: `Top 50 Global (#${data.placeKill})`,
            rarity: 'epic'
        });
    }
    
    // K/D achievements
    const kd = parseFloat(calculateKDRatio(data.kills, data.death));
    if (kd >= 3.0) {
        achievements.push({
            icon: 'fas fa-fire',
            title: 'Unstoppable',
            description: `K/D Ratio: ${kd}`,
            rarity: 'legendary'
        });
    } else if (kd >= 2.0) {
        achievements.push({
            icon: 'fas fa-crosshairs',
            title: 'Sharpshooter',
            description: `K/D Ratio: ${kd}`,
            rarity: 'epic'
        });
    }
    
    // Token achievements
    if (data.tokens >= 500000) {
        achievements.push({
            icon: 'fas fa-gem',
            title: 'Token Millionaire',
            description: `${formatNumberWithCommas(data.tokens)} Tokens`,
            rarity: 'legendary'
        });
    } else if (data.tokens >= 100000) {
        achievements.push({
            icon: 'fas fa-coins',
            title: 'Token Master',
            description: `${formatNumberWithCommas(data.tokens)} Tokens`,
            rarity: 'epic'
        });
    }
    
    // Prestige achievements
    if (data.prestige >= 5) {
        achievements.push({
            icon: 'fas fa-star',
            title: 'Prestige Master',
            description: `Prestige Level ${data.prestige}`,
            rarity: 'legendary'
        });
    } else if (data.prestige >= 1) {
        achievements.push({
            icon: 'fas fa-level-up-alt',
            title: 'Prestige Player',
            description: `Prestige Level ${data.prestige}`,
            rarity: 'rare'
        });
    }
    
    // Default message if no achievements
    if (achievements.length === 0) {
        achievements.push({
            icon: 'fas fa-hourglass-half',
            title: 'Getting Started',
            description: 'Keep playing to unlock achievements!',
            rarity: 'common'
        });
    }
    
    return achievements.map(achievement => `
        <div class="achievement-card ${achievement.rarity}">
            <div class="achievement-icon">
                <i class="${achievement.icon}"></i>
            </div>
            <div class="achievement-content">
                <div class="achievement-title">${achievement.title}</div>
                <div class="achievement-description">${achievement.description}</div>
            </div>
        </div>
    `).join('');
}

function ShowProfileLoading(show) {
    const loading = $(".profile-loading");
    const content = $(".profile-content");
    
    if (show) {
        loading.show();
        content.hide();
    } else {
        loading.hide();
        content.show();
    }
}

function ShowProfileError() {
    ShowProfileLoading(false);
    const profileContent = $(".profile-content");
    profileContent.html(`
        <div class="profile-error">
            <i class="fas fa-exclamation-triangle"></i>
            <h3>Failed to load profile</h3>
            <p>Please try again later</p>
            <button onclick="LoadProfile()" class="retry-button">Retry</button>
        </div>
    `);
}

function animateProfileElements() {
    // Add staggered animations to elements
    $(".stat-card").each(function(index) {
        $(this).css('animation-delay', (index * 0.1) + 's');
    });
    
    $(".achievement-card").each(function(index) {
        $(this).css('animation-delay', (index * 0.05) + 's');
    });
}

// Initialize when document is ready
$(document).ready(function() {
    InitializeProfile();
});

// Export functions for global access
window.LoadProfilePlayer = LoadProfilePlayer;
window.ShowProfile = ShowProfile;
window.LoadProfile = LoadProfile;
window.HideProfile = HideProfile;
