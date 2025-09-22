// Settings System for Guild PVP
// Compatible with existing server-side settings system

let currentSettings = {};
let activeCategory = 'general';

// Settings configuration organized by categories - using correct IDs that match server
const settingsConfig = {
    general: [
        { id: "hud_life", label: "Guild Status HUD", type: "checkbox", default: true },
        { id: "optimization", label: "Optimization", type: "checkbox", default: true },
        { id: "loadout", label: "Loadout", type: "checkbox", default: false },
        { id: "voice_chat", label: "Bag Interface", type: "checkbox", default: false },
        { id: "death_voice_chat", label: "Death Voice Chat", type: "checkbox", default: false }
    ],
    gameplay: [
        { id: "kill_feed", label: "Kill Feed", type: "checkbox", default: true },
        { id: "hitmarker", label: "Hitmarker", type: "checkbox", default: true },
        { id: "hitmarker_size", label: "Hitmarker Size", type: "select", default: "normal", options: ["tenier", "normal", "big"] },
        { id: "killsound", label: "Kill Sound", type: "checkbox", default: true },
        { id: "loadout_kits", label: "Loadout Kits", type: "select", default: "buffalo4_specialcarbine", options: ["buffalo4_specialcarbine", "buffalo4_bullpuprifle_mk2", "buffalo4_carbinerifle_mk2", "buffalo4_specialcarbine_mk2"] }
    ],
    interface: [
        { id: "opacity", label: "Interface Opacity", type: "slider", default: 0.7, min: 0.1, max: 1, step: 0.01, suffix: "" },
        { id: "deathmessage", label: "Death Message", type: "text", default: "" }
    ],
    audio: [
        { id: "hitmarker_sound", label: "Hitmarker Sound", type: "checkbox", default: true },
        { id: "volume_hitmarker", label: "Hitmarker Volume", type: "slider", default: 0.5, min: 0.1, max: 1, step: 0.01, suffix: "" },
        { id: "music_kill", label: "Music Kill", type: "select", default: "none", options: ["none", "saif", "tk78_rage", "tk78_troll", "bombastic", "cover", "knocking", "marine", "degage", "begaye", "allofrro", "amadou", "8mort6blesse", "zemour"] },
        { id: "hitmarker_type", label: "Hitmarker Type", type: "select", default: "hitmarker", options: ["hitmarker", "hitmarker2", "hitmarker3", "hitmarker4", "hitmarker5", "hitmarker6"] },
    ]
};

// Category labels
const categoryLabels = {
    general: "General",
    gameplay: "Gameplay", 
    interface: "Interface",
    audio: "Audio"
};

// Mapping from setting IDs to UI labels (for server compatibility)
const settingLabels = {
    "hud_life": "Guild Status HUD",
    "kill_feed": "Kill Feed",
    "hitmarker": "Hitmarker",
    "hitmarker_sound": "Hitmarker Sound",
    "hitmarker_size": "Hitmarker Size",
    "volume_hitmarker": "Hitmarker Volume",
    "killsound": "Kill Sound",
    "voice_chat": "Bag Interface",
    "death_voice_chat": "Death Voice Chat",
    "deathmessage": "Death Message",
    "opacity": "Interface Opacity",
    "optimization": "Optimization",
    "loadout": "Loadout",
    "loadout_kits": "Loadout Kits",
    "music_kill": "Music Kill",
    "hitmarker_type": "Hitmarker Type"
};

// Initialize settings system
function InitializeSettings() {
    
    // Create settings section if it doesn't exist
    if (!$(".settings-section").length) {
        CreateSettingsSection();
    }
}

// Create settings section HTML
function CreateSettingsSection() {
    const settingsHTML = `
        <div class="settings-section" style="display: none;">
            <div class="settings-container">
                <div class="settings-header">
                    <h2 class="settings-title">
                        <i class="fas fa-cog"></i>
                        Settings
                    </h2>
                    <div class="settings-subtitle">Customize your game experience</div>
                </div>
                
                <div class="settings-body">
                    <div class="settings-sidebar">
                        <div class="settings-categories">
                            ${Object.keys(categoryLabels).map(key => `
                                <button class="category-btn ${key === 'general' ? 'active' : ''}" data-category="${key}">
                                    <i class="fas fa-${getCategoryIcon(key)}"></i>
                                    ${categoryLabels[key]}
                                </button>
                            `).join('')}
                        </div>
                    </div>
                    
                    <div class="settings-content">
                        <div class="settings-grid">
                            <!-- Settings will be populated here -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    $(".ui-body").append(settingsHTML);
    setupCategoryNavigation();
    PopulateSettings();
}

// Get category icon
function getCategoryIcon(category) {
    const icons = {
        general: 'home',
        gameplay: 'gamepad',
        interface: 'desktop',
        audio: 'volume-up'
    };
    return icons[category] || 'cog';
}

// Setup category navigation
function setupCategoryNavigation() {
    $('.category-btn').click(function() {
        const category = $(this).data('category');
        switchCategory(category);
    });
}

// Switch category
function switchCategory(category) {
    
    activeCategory = category;
    
    // Update active button
    $('.category-btn').removeClass('active');
    $(`.category-btn[data-category="${category}"]`).addClass('active');
    
    // Populate settings for this category
    PopulateSettings();
}

// Show settings page
function ShowSettings() {
    
    // Hide other sections
    $(".inventorydiv").hide();
    $(".leaderboard-section").hide();
    $(".shop-section").hide();
    $(".ui-tebex").hide();
    
    // Hide profile
    if (window.HideProfile && typeof window.HideProfile === 'function') {
        window.HideProfile();
    }
    
    // Show settings section
    $(".settings-section").show();
    
    // Update navigation
    $(".menu-link").removeClass("current-page");
    $(".settings-button").addClass("current-page");
    
    // Load current settings and populate UI
    LoadSettings();
    
    // Ensure the current category is populated
    setTimeout(() => {
        PopulateSettings();
    }, 200);
}

// Populate settings with controls for active category
function PopulateSettings() {
    const settingsGrid = $(".settings-grid");
    settingsGrid.empty();
    
    const categorySettings = settingsConfig[activeCategory] || [];

    
    // Add category title
    settingsGrid.append(`
        <div class="category-title">
            <i class="fas fa-${getCategoryIcon(activeCategory)}"></i>
            ${categoryLabels[activeCategory]}
        </div>
    `);
    
    categorySettings.forEach(setting => {
        const settingHTML = createSettingControl(setting);
        settingsGrid.append(settingHTML);
    });
    
    // Add event listeners AFTER creating elements
    setupSettingEventListeners();
    
    // Update UI with current settings AFTER creating elements
    setTimeout(() => {
        updateSettingsUI();
    }, 100); // Small delay to ensure DOM is ready
}

// Create individual setting control
function createSettingControl(setting) {
    let controlHTML = '';
    
    switch (setting.type) {
        case 'checkbox':
            controlHTML = `
                <div class="setting-item" data-setting="${setting.id}">
                    <div class="setting-info">
                        <div class="setting-label">${setting.label}</div>
                    </div>
                    <div class="setting-control">
                        <label class="setting-toggle">
                            <input type="checkbox" id="${setting.id}" data-setting="${setting.id}">
                            <span class="toggle-slider"></span>
                        </label>
                    </div>
                </div>
            `;
            break;
            
        case 'select':
            const options = setting.options.map(opt => 
                `<option value="${opt}">${opt}</option>`
            ).join('');
            
            controlHTML = `
                <div class="setting-item" data-setting="${setting.id}">
                    <div class="setting-info">
                        <div class="setting-label">${setting.label}</div>
                    </div>
                    <div class="setting-control">
                        <select class="setting-select" id="${setting.id}" data-setting="${setting.id}">
                            ${options}
                        </select>
                    </div>
                </div>
            `;
            break;
            
        case 'slider':
            controlHTML = `
                <div class="setting-item" data-setting="${setting.id}">
                    <div class="setting-info">
                        <div class="setting-label">${setting.label}</div>
                        <div class="setting-value" id="${setting.id}-value">50%</div>
                    </div>
                    <div class="setting-control">
                        <input type="range" class="setting-slider" id="${setting.id}" data-setting="${setting.id}"
                               min="${setting.min}" max="${setting.max}" value="${setting.default}" step="${setting.step || 0.01}">
                    </div>
                </div>
            `;
            break;
            
        case 'text':
            controlHTML = `
                <div class="setting-item" data-setting="${setting.id}">
                    <div class="setting-info">
                        <div class="setting-label">${setting.label}</div>
                    </div>
                    <div class="setting-control">
                        <input type="text" class="setting-text" id="${setting.id}" data-setting="${setting.id}"
                               value="${setting.default}" placeholder="Enter ${setting.label.toLowerCase()}...">
                    </div>
                </div>
            `;
            break;
    }
    
    return controlHTML;
}

// Format slider value for display
function formatSliderValue(value, setting) {
    if (setting.id === 'opacity' || setting.id === 'volume_hitmarker') {
        return Math.round(value * 100) + '%';
    }
    return value + (setting.suffix || '');
}

// Get setting config by ID
function getSettingConfig(settingId) {
    for (const category in settingsConfig) {
        const setting = settingsConfig[category].find(s => s.id === settingId);
        if (setting) return setting;
    }
    return null;
}

// Setup event listeners for settings
function setupSettingEventListeners() {
    // Checkbox toggles
    $('.setting-toggle input[type="checkbox"]').off('change').on('change', function() {
        const settingId = $(this).data('setting');
        const value = $(this).is(':checked');
        setSetting(settingId, value);
    });
    
    // Select dropdowns
    $('.setting-select').off('change').on('change', function() {
        const settingId = $(this).data('setting');
        const value = $(this).val();
        setSetting(settingId, value);
    });
    
    // Sliders
    $('.setting-slider').off('input').on('input', function() {
        const settingId = $(this).data('setting');
        const value = parseFloat($(this).val());
        const setting = getSettingConfig(settingId);
        
        // Update display value
        const displayValue = formatSliderValue(value, setting);
        $(`#${settingId}-value`).text(displayValue);
        
        // Apply opacity in real-time
        if (settingId === 'opacity') {
            applyOpacity(value);
        }
    });
    
    $('.setting-slider').off('change').on('change', function() {
        const settingId = $(this).data('setting');
        const value = parseFloat($(this).val());
        setSetting(settingId, value);
    });
    
    // Text inputs
    $('.setting-text').off('blur').on('blur', function() {
        const settingId = $(this).data('setting');
        const value = $(this).val();
        setSetting(settingId, value);
    });
    
    $('.setting-text').off('keypress').on('keypress', function(e) {
        if (e.which === 13) { // Enter key
            $(this).blur();
        }
    });
}

// Set a setting value - COMPATIBLE WITH SERVER SYSTEM
function setSetting(settingId, value) {
    currentSettings[settingId] = value;
    
    // Get the UI label for this setting
    const settingLabel = settingLabels[settingId];
    if (!settingLabel) {
        return;
    }
    
    
    // Send to server using the CORRECT callback that matches cl_settings.lua
    $.post("https://gamemode/SetSetting", JSON.stringify({
        setting: settingLabel,  // Use the UI label as expected by server
        value: value
    }))
    
    // Apply special effects
    if (settingId === 'opacity') {
        applyOpacity(value);
    }
}

// Apply opacity to UI
function applyOpacity(value) {
    const uiBody = document.querySelector('.ui-body');
    if (uiBody) {
        // Apply background opacity using rgba with !important to override CSS
        uiBody.style.setProperty('background', `rgba(0, 0, 0, ${value})`, 'important');
    }
}

// Load settings from server - COMPATIBLE WITH SERVER SYSTEM
function LoadSettings() {
    
    $.post("https://gamemode/GetSettings", JSON.stringify({}), function(response) {
        if (response && typeof response === 'object') {
            
            // Convert string booleans to actual booleans
            for (const key in response) {
                if (response[key] === "true") {
                    response[key] = true;
                } else if (response[key] === "false") {
                    response[key] = false;
                }
            }
            
            currentSettings = response;
            updateAllSettingsUI();
        } else {
            useDefaultSettings();
        }
    }).fail(function(xhr, status, error) {
        useDefaultSettings();
    });
}

// Use default settings when server fails
function useDefaultSettings() {
    currentSettings = {};
    
    // Use default values
    for (const category in settingsConfig) {
        settingsConfig[category].forEach(setting => {
            currentSettings[setting.id] = setting.default;
        });
    }
    
    updateAllSettingsUI();
}

// Update UI with current settings
function updateSettingsUI() {
    
    // Only update settings for the current active category to avoid "Element not found" errors
    const categorySettings = settingsConfig[activeCategory] || [];
    
    categorySettings.forEach(setting => {
        const value = currentSettings[setting.id] !== undefined ? currentSettings[setting.id] : setting.default;
        const element = document.getElementById(setting.id);
        
        if (!element) {
           
            return;
        }
        
        
        switch (setting.type) {
            case 'checkbox':
                // Handle boolean conversion properly
                let boolValue = false;
                if (typeof value === 'boolean') {
                    boolValue = value;
                } else if (typeof value === 'string') {
                    boolValue = value.toLowerCase() === 'true' || value === '1';
                } else if (typeof value === 'number') {
                    boolValue = value !== 0;
                }
                element.checked = boolValue;
                break;
                
            case 'select':
                element.value = value;
                break;
                
            case 'slider':
                element.value = value;
                const displayValue = formatSliderValue(value, setting);
                $(`#${setting.id}-value`).text(displayValue);
                
                if (setting.id === 'opacity') {
                    applyOpacity(value);
                }
                break;
                
            case 'text':
                element.value = value || '';
                break;
        }
    });
}

// Function to update all settings across all categories (used when receiving data from server)
function updateAllSettingsUI() {
    
    for (const category in settingsConfig) {
        settingsConfig[category].forEach(setting => {
            const value = currentSettings[setting.id] !== undefined ? currentSettings[setting.id] : setting.default;
            const element = document.getElementById(setting.id);
            
            // Skip if element doesn't exist (not in current view)
            if (!element) {
                return;
            }
            
            
            switch (setting.type) {
                case 'checkbox':
                    // Handle boolean conversion properly
                    let boolValue = false;
                    if (typeof value === 'boolean') {
                        boolValue = value;
                    } else if (typeof value === 'string') {
                        boolValue = value.toLowerCase() === 'true' || value === '1';
                    } else if (typeof value === 'number') {
                        boolValue = value !== 0;
                    }
                    element.checked = boolValue;
                    break;
                    
                case 'select':
                    element.value = value;
                    break;
                    
                case 'slider':
                    element.value = value;
                    const displayValue = formatSliderValue(value, setting);
                    $(`#${setting.id}-value`).text(displayValue);
                    
                    if (setting.id === 'opacity') {
                        applyOpacity(value);
                    }
                    break;
                    
                case 'text':
                    element.value = value || '';
                    break;
            }
        });
    }
}

// Listen for messages from game - COMPATIBLE WITH SERVER SYSTEM
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'init' && data.settings) {
        
        // Convert string booleans to actual booleans
        for (const key in data.settings) {
            if (data.settings[key] === "true") {
                data.settings[key] = true;
            } else if (data.settings[key] === "false") {
                data.settings[key] = false;
            }
        }
        
        currentSettings = data.settings;
        
        // Only update UI if settings section is visible
        if ($(".settings-section").is(":visible")) {
            updateAllSettingsUI();
        }
    }
});

// Initialize when document is ready
$(document).ready(function() {
    InitializeSettings();
    
    // Add click handler for settings button
    $('.settings-button').click(function(e) {
        e.preventDefault();
        ShowSettings();
    });
    
    
    // Force initial load after a short delay
    setTimeout(() => {
        if (Object.keys(currentSettings).length === 0) {
            LoadSettings();
        }
    }, 1000);
});

// Hide settings function
function HideSettings() {
    $(".settings-section").hide();
}

// Export functions
window.ShowSettings = ShowSettings;
window.LoadSettings = LoadSettings;
window.HideSettings = HideSettings;
