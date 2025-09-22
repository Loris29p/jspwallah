// Define list of available settings
const ListSettings = [
    {id: "hud_life", label: "Guild Status HUD", type: "checkbox", default: true},
    {id: "kill_feed", label: "Kill Feed", type: "checkbox", default: true},
    {id: "hitmarker", label: "Hitmarker", type: "checkbox", default: true},
    {id: "hitmarker_sound", label: "Hitmarker Sound", type: "checkbox", default: true},
    {id: "hitmarker_size", label: "Hitmarker Size", type: "select", default: "normal", options: ["tenier", "normal", "big"]},
    {id: "volume_hitmarker", label: "Hitmarker Volume", type: "number", default: 50}, 
    {id: "killsound", label: "Kill Sound", type: "checkbox", default: true}, 
    {id: "voice_chat", label: "Bag Interface", alternateLabels: ["Bag Interface", "BagInterface", "Interface Bag"], type: "checkbox", default: false},
    {id: "death_voice_chat", label: "Death Voice Chat", alternateLabels: ["Death Voice", "Voice on Death"], type: "checkbox", default: false},
    {id: "deathmessage", label: "Death Message", type: "text", default: ""},
    {id: "opacity", label: "Interface Opacity", type: "number", default: 0},
    {id: "optimization", label: "Optimization", type: "checkbox", default: true},
    {id: "loadout", label: "Loadout", type: "checkbox", default: false},
    {id: "loadout_kits", label: "Loadout Kits", type: "select", default: "revolter_specialcarbine", options: ["revolter_specialcarbine", "stx_specialcarbine", "stx_carbinerifle_mk2", "bullpuprifle_mk2_specialcarbine"]},
    {id: "music_kill", label: "Music Kill", type: "select", default: "none", options: ["none", "saif", "tk78_rage", "tk78_troll", "bombastic", "cover", "knocking", "marine", "degage", "begaye", "allofrro", "amadou", "8mort6blesse", "zemour"]},
];
  
// Helper function to compare labels in ListSettings with actual DOM elements
function findBestMatchForLabel(label, alternateLabels) {
  // For the new UI, we're using data-setting attribute
  const inputs = Array.from(document.querySelectorAll('[data-setting]'));
  
  // Create an array of all labels to check (main label + alternates)
  const labelsToCheck = [label];
  if (alternateLabels && Array.isArray(alternateLabels)) {
    labelsToCheck.push(...alternateLabels);
  }
  
  // Create an array of objects with element and similarity score
  const matches = inputs.map(el => {
    const settingAttr = el.getAttribute('data-setting');
    let bestScore = 0;
    
    // Check against all possible labels and keep the best score
    labelsToCheck.forEach(labelToCheck => {
      let score = 0;
      
      // Exact match gets highest score
      if (settingAttr === labelToCheck) {
        score = 100;
      } 
      // Case insensitive match gets high score
      else if (settingAttr.toLowerCase() === labelToCheck.toLowerCase()) {
        score = 90;
      }
      // Contains match gets medium score
      else if (settingAttr.toLowerCase().includes(labelToCheck.toLowerCase()) || 
               labelToCheck.toLowerCase().includes(settingAttr.toLowerCase())) {
        // Calculate percentage of characters that match
        const longer = Math.max(settingAttr.length, labelToCheck.length);
        const shorter = Math.min(settingAttr.length, labelToCheck.length);
        score = Math.floor((shorter / longer) * 80);
      }
      
      // Keep the best score
      if (score > bestScore) {
        bestScore = score;
      }
    });
    
    return {
      element: el,
      attr: settingAttr,
      score: bestScore
    };
  });
  
  // Sort by score descending
  matches.sort((a, b) => b.score - a.score);
  
  // Return the best match if it has a score higher than 0
  return matches.length > 0 && matches[0].score > 0 ? matches[0].element : null;
}

// Function to load settings from server and populate the UI
function loadSettings() {
  $.get("https://gamemode/GetSettings", function(response) {
    if (response && typeof response === 'object') {
      // For each setting in our settings list
      ListSettings.forEach(setting => {
        // Find the setting value from the response, or use default
        const value = response[setting.id] !== undefined ? response[setting.id] : setting.default;
        
        // Use the best match function with alternate labels
        const element = findBestMatchForLabel(setting.label, setting.alternateLabels);
          
        if (element) {
          // Handle different setting types
          if (setting.type === 'checkbox') {
            if (element.type === 'checkbox') {
              // Ensure the value is treated as a boolean
              let shouldCheck = false;
              
              if (typeof value === 'boolean') {
                shouldCheck = value;
              } else if (typeof value === 'number') {
                shouldCheck = value !== 0;
              } else if (typeof value === 'string') {
                shouldCheck = value.toLowerCase() === 'true' || value === '1';
              }
              
              element.checked = shouldCheck;
              
              // Force redraw for checkbox and force a UI update
              setTimeout(() => {
                element.checked = shouldCheck;  // Set it again to be sure
                const event = new Event('change');
                element.dispatchEvent(event);
              }, 100);
            }
          } else if (setting.type === 'select') {
            if (element.classList.contains('setting-dropdown')) {
              // Find the option that matches our value
              const option = Array.from(element.options).find(opt => opt.value === value);
              if (option) {
                element.value = value;
              } else {
                // Default to first option if value not found
                element.selectedIndex = 0;
              }
            }
          } else if (setting.type === 'number') {
            // Handle special case for sliders
            if (setting.id === 'opacity') {
              const slider = document.getElementById('opacity-slider');
              const valueDisplay = document.getElementById('opacity-value');
              
              if (slider && valueDisplay) {
                const opacityValue = parseFloat(value);
                slider.value = opacityValue;
                valueDisplay.textContent = opacityValue.toFixed(2);
                
                // Apply opacity to the UI content
                const uiContent = document.querySelector('.ui-content');
                if (uiContent) {
                  const finalOpacity = Math.max(0.1, opacityValue);
                  uiContent.style.backgroundColor = `rgba(19, 21, 23, ${finalOpacity})`;
                }
              }
            } else if (setting.id === 'volume_hitmarker') {
              const slider = document.getElementById('hitmarker-volume-slider');
              const valueDisplay = document.getElementById('hitmarker-volume-value');
              
              if (slider && valueDisplay) {
                const volumeValue = parseFloat(value);
                slider.value = volumeValue;
                valueDisplay.textContent = `${volumeValue}%`;
              }
            }
          } else if (setting.type === 'text') {
            if (element.classList.contains('setting-text')) {
              element.value = value || '';
            }
          }
        }
      });
    }
  }).fail(function(error) {
    console.error("Failed to load settings:", error);
  });
}

// Function to set a setting value and send it to the server
function setSetting(settingId, value) {
  // Find the setting in our list
  const setting = ListSettings.find(s => s.id === settingId);
  
  if (!setting) {
    console.error(`Unknown setting: ${settingId}`);
    return;
  }

  // Apply special handling for opacity
  if (settingId === "opacity") {
    // Apply opacity to the main UI content
    const uiContent = document.querySelector('.ui-content');
    if (uiContent) {
      // Convert opacity value to be between 0.1 and 1
      const opacityValue = Math.max(0.1, parseFloat(value));
      
      // Simply set the background color with the new opacity value
      uiContent.style.backgroundColor = `rgba(19, 21, 23, ${opacityValue})`;
    }
  }
  
  // Send to server
  $.post("https://gamemode/SetSetting", JSON.stringify({ 
    setting: setting.label, 
    value: value 
  }));
}

// Function to find a setting ID by its label
function getSettingIdByLabel(label) {
  const setting = ListSettings.find(s => s.label === label);
  return setting ? setting.id : null;
}

// Save button handler for input fields
function SetSettingsValue(settingId) {
  // For buttons that trigger a save action for an input field
  if (settingId === 'opacity') {
    const slider = document.getElementById('opacity-slider');
    if (slider) {
      const value = parseFloat(slider.value);
      setSetting(settingId, value);
    }
  } else if (settingId === 'volume_hitmarker') {
    const slider = document.getElementById('hitmarker-volume-slider');
    if (slider) {
      const value = parseFloat(slider.value);
      setSetting(settingId, value);
    }
  }
}

// Initialize when document is ready
$(document).ready(function() {
  // Load settings initially
  loadSettings();
  
  // Set up checkbox handlers for the new UI
  $('.setting-toggle input[type="checkbox"]').change(function() {
    const isChecked = $(this).is(':checked');
    const settingAttr = $(this).data('setting');
    const settingId = getSettingIdByLabel(settingAttr);
    
    if (settingId) {
      setSetting(settingId, isChecked);
    }
  });
  
  // Handle sliders for real-time feedback
  $('#opacity-slider').on('input', function() {
    const value = parseFloat(this.value);
    $('#opacity-value').text(value.toFixed(2));
    
    const uiContent = document.querySelector('.ui-content');
    if (uiContent) {
      const finalOpacity = Math.max(0.1, value);
      uiContent.style.backgroundColor = `rgba(19, 21, 23, ${finalOpacity})`;
    }
  });
  
  $('#hitmarker-volume-slider').on('input', function() {
    const value = parseFloat(this.value);
    $('#hitmarker-volume-value').text(`${value}%`);
  });
  
  // Handle save buttons for dropdowns and text inputs
  $('.setting-save-btn').click(function() {
    if (this.closest('.dropdown-control') || this.closest('.text-control')) {
      const container = $(this).closest('.setting-item');
      const dropdown = container.find('.setting-dropdown');
      const textInput = container.find('.setting-text');
      
      if (dropdown.length) {
        const settingAttr = dropdown.data('setting');
        const settingId = getSettingIdByLabel(settingAttr);
        
        if (settingId) {
          setSetting(settingId, dropdown.val());
        }
      } else if (textInput.length) {
        const settingAttr = textInput.data('setting');
        const settingId = getSettingIdByLabel(settingAttr);
        
        if (settingId) {
          setSetting(settingId, textInput.val());
        }
      }
    }
  });
  
  // Tab navigation
  $('.settings-nav-item').click(function() {
    // Remove active class from all tabs and content
    $('.settings-nav-item').removeClass('active');
    $('.settings-tab').removeClass('active');
    
    // Add active class to clicked tab
    $(this).addClass('active');
    
    // Show corresponding content
    const tabId = $(this).data('tab');
    $(`#${tabId}-tab`).addClass('active');
  });
});

// Listen for messages from the game
window.addEventListener('message', function(event) {
  const data = event.data;

  if (data.type === 'init') {
    loadSettings();
  }
});