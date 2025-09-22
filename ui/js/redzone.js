// Guild PVP Redzone Kill Leader System
// Modern implementation with same event handling

let redzoneLeaderCard = null;

// Initialize the redzone leader display
function InitializeRedzoneLeader() {
    if (!redzoneLeaderCard) {
        redzoneLeaderCard = document.createElement('div');
        redzoneLeaderCard.className = 'redzone-leader-card';
        redzoneLeaderCard.style.display = 'none';
        document.body.appendChild(redzoneLeaderCard);
    }
}

// Get font size based on name length
function getNameFontSize(nameLength) {
    if (nameLength > 6) {
        return '1.2vh'; // Smaller font for long names
    }
    return '1.4vh'; // Normal font size
}

// Update the kill leader information
function UpdateKillLeader(playerName, killCount) {
    if (!redzoneLeaderCard) {
        InitializeRedzoneLeader();
    }
    
    // Show the card if hidden
    if (redzoneLeaderCard.style.display === 'none') {
        redzoneLeaderCard.style.display = 'block';
    }
    
    // Calculate font size based on name length
    const nameFontSize = getNameFontSize(playerName.length);
    
    // Update the card content
    redzoneLeaderCard.innerHTML = `
        <div class="leader-content">
            <div class="leader-icon">
                <i class="fas fa-crown"></i>
            </div>
            <div class="leader-info">
                <div class="leader-title">Kill Leader</div>
                <div class="leader-name" style="font-size: ${nameFontSize};">${playerName}</div>
            </div>
            <div class="kill-counter">
                <div class="kill-number">${killCount}</div>
                <div class="kill-label">Kills</div>
            </div>
        </div>
    `;
}

// Hide the redzone leader card
function HideRedzoneLeader() {
    if (redzoneLeaderCard) {
        redzoneLeaderCard.style.display = 'none';
    }
}

// Handle window messages
window.addEventListener("message", function(event) {
    if (event.data.type == "updateRedzone") {
        UpdateKillLeader(event.data.name, event.data.kills);
    } else if (event.data.type == "hideRedzoneInfo") {
        HideRedzoneLeader();
    }
});

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    InitializeRedzoneLeader();
});
