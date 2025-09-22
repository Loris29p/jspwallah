// Kit management system
let kitsData = [];
let playerRole = "user"; // Default role, will be updated from server
let playerUuid = ""; // Will be set from server
let kitTimers = {}; // To store timers for each kit

// Initialize the kit interface
$(document).ready(function () {
    // Register NUI callback
    window.addEventListener('message', function (event) {
        const data = event.data;

        if (data.type === "openKitsMenu") {
            // Update player data
            playerRole = data.playerRole;
            playerUuid = data.playerUuid;
            kitsData = data.kitsData;
            kitTimers = data.kitTimers || {};

            // Display kits UI
            $('.kit-container').html(createKitsWindow());
            $('.kit-container').show();

            // Start countdown timers for kits on cooldown
            updateKitTimers();
        } else if (data.type === "closeKitsMenu") {
            $('.kit-container').hide();
        } else if (data.type === "updateKitTimer") {
            // Update a specific kit timer
            kitTimers[data.kitName] = data.newTime;
            updateKitTimers();
        }
    });

    // Close kit menu when pressing ESC
    $(document).keyup(function (e) {
        if (e.keyCode === 27) { // ESC key
            closeKitMenu();
        }
    });
});

// Create the kits window HTML
function createKitsWindow() {
    let html = `
    <div class="kits-window">
        <div class="window-header">Available Kits</div>
        <div class="window-content">
    `;

    // Add kits to the window
    if (kitsData.length > 0) {
        kitsData.forEach(kit => {
            if (kit.role.includes(playerRole)) {
                const isAvailable = !kitTimers[kit.kit] || kitTimers[kit.kit] < Date.now() / 1000;
                const kitClass = isAvailable ? "available" : "disabled";
                const timeLeft = !isAvailable ? formatTimeLeft(kitTimers[kit.kit]) : "";

                html += `
                <div class="game-option-item ${kitClass}" data-kit="${kit.kit}">
                    <div class="game-option-help-container">
                        <span class="game-option-title">${kit.kit}</span>
                        <span class="game-option-description">
                `;

                // Add kit contents
                kit.listItems.forEach(item => {
                    html += `${item.label} (${item.count}) `;
                });

                // Show time left if not available
                if (!isAvailable) {
                    html += `<br><span class="time-left" id="timer-${kit.kit}">Available in: ${timeLeft}</span>`;
                }

                html += `</span>
                    </div>
                    <div class="game-option-value-container">
                        <div class="ui-button input-save-button" onclick="claimKit('${kit.kit}')">
                            <span>${isAvailable ? "Claim" : "Locked"}</span>
                        </div>
                    </div>
                </div>
                `;
            }
        });
    } else {
        html += `<div class="game-option-item">
            <div class="game-option-help-container">
                <span class="game-option-title">No kits available</span>
            </div>
        </div>`;
    }

    html += `
        </div>
    </div>
    `;

    return html;
}

// Claim a kit
function claimKit(kitName) {
    const kitElement = $(`.game-option-item[data-kit="${kitName}"]`);
    if (kitElement.hasClass('available')) {
        // Send request to server to claim kit
        $.post('https://gamemode/claimKit', JSON.stringify({
            kitName: kitName
        }));

        // Update UI to show kit as claimed (will be properly updated by server response)
        const kitData = kitsData.find(k => k.kit === kitName);
        if (kitData) {
            const newTime = Math.floor(Date.now() / 1000) + kitData.time;
            kitTimers[kitName] = newTime;
            updateKitTimers();

            kitElement.removeClass('available').addClass('disabled');
            kitElement.find('.input-save-button span').text('Locked');

            // Add timer element if not exists
            if (kitElement.find(`#timer-${kitName}`).length === 0) {
                kitElement.find('.game-option-description').append(
                    `<br><span class="time-left" id="timer-${kitName}">Available in: ${formatTimeLeft(newTime)}</span>`
                );
            }
        }
    }
}

// Close the kit menu
function closeKitMenu() {
    $('.kit-container').hide();
    $.post('https://gamemode/closeKitMenu', JSON.stringify({}));
}

// Update all kit timers
function updateKitTimers() {
    const currentTime = Math.floor(Date.now() / 1000);

    Object.keys(kitTimers).forEach(kitName => {
        const endTime = kitTimers[kitName];
        if (endTime > currentTime) {
            // Kit is on cooldown
            const timeLeft = formatTimeLeft(endTime);
            $(`#timer-${kitName}`).text(`Available in: ${timeLeft}`);

            // Make sure the kit is marked as disabled
            $(`.game-option-item[data-kit="${kitName}"]`)
                .removeClass('available')
                .addClass('disabled')
                .find('.input-save-button span')
                .text('Locked');
        } else {
            // Kit is available
            $(`.game-option-item[data-kit="${kitName}"]`)
                .removeClass('disabled')
                .addClass('available')
                .find('.input-save-button span')
                .text('Claim');

            // Remove timer text
            $(`#timer-${kitName}`).remove();
        }
    });

    // Schedule next update
    setTimeout(updateKitTimers, 1000);
}

// Format time left in HH:MM:SS
function formatTimeLeft(endTime) {
    const currentTime = Math.floor(Date.now() / 1000);
    let secondsLeft = endTime - currentTime;

    if (secondsLeft <= 0) {
        return "00:00:00";
    }

    const hours = String(Math.floor(secondsLeft / 3600)).padStart(2, '0');
    secondsLeft %= 3600;
    const minutes = String(Math.floor(secondsLeft / 60)).padStart(2, '0');
    const seconds = String(secondsLeft % 60).padStart(2, '0');

    return `${hours}:${minutes}:${seconds}`;
}
