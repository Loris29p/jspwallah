let feedContainer = null;
const DISPLAY_DURATION = 2000; // 2 seconds like the old version
const MAX_CARDS = 5;

function initializeFeed() {
    feedContainer = document.querySelector('.combat-feed');
    if (!feedContainer) {
        feedContainer = document.createElement('div');
        feedContainer.className = 'combat-feed';
        document.body.appendChild(feedContainer);
    }
    feedContainer.style.display = 'flex';
}

function toggleFeedVisibility(isVisible) {
    if (!feedContainer) return;
    feedContainer.style.display = isVisible ? 'flex' : 'none';
}

function createEliminationCard(attacker, attackerColor, weaponUrl, target, targetColor, isRedZone, targetRank, attackerRank, isFFAMode) {
    if (!feedContainer) {
        initializeFeed();
    } else {
        feedContainer.style.display = 'flex';
    }

    // Remove order-5 card if it exists (like old system)
    const order5 = feedContainer.querySelector('.elimination-card.order-5');
    if (order5) {
        feedContainer.removeChild(order5);
    }

    // Shift all existing cards up by one order (like old system)
    for (let i = MAX_CARDS - 1; i >= 1; i--) {
        const currentCard = feedContainer.querySelector(`.elimination-card.order-${i}`);
        if (currentCard) {
            currentCard.classList.remove(`order-${i}`);
            currentCard.classList.add(`order-${i + 1}`);
        }
    }

    // Determine background color (like old system)
    let backgroundColor = 'rgba(0, 0, 0, 0.5)';
    if (isRedZone) {
        backgroundColor = 'rgba(158, 15, 15, 0.5)';
    } else if (isFFAMode) {
        backgroundColor = 'rgba(74, 183, 255, 0.5)';
    }

    // Create new card
    const eliminationCard = document.createElement('div');
    eliminationCard.className = 'elimination-card order-1';

    // Create badges (simplified like old version)
    const attackerBadge = attackerRank > 0 
        ? `<div class="rank-badge left"><img src="./assets/badges/prestige_${attackerRank}.png"></div>` 
        : '';
    
    const targetBadge = targetRank > 0 
        ? `<div class="rank-badge right"><img src="./assets/badges/prestige_${targetRank}.png"></div>` 
        : '';

    // Simple innerHTML structure like old version
    eliminationCard.innerHTML = `
        <div class="card" style="background-color: ${backgroundColor};">
            ${attackerBadge}
            <span class="attacker">
                <span style="color: ${attackerColor}">${attacker}</span>
            </span>
            <div class="weapon-img">
                <div style="background-image: url('${weaponUrl}');"></div>
            </div>
            <span class="target">
                <span style="color: ${targetColor}">${target}</span>
            </span>
            ${targetBadge}
        </div>
    `;

    // Add to feed at the beginning (like old version)
    feedContainer.insertBefore(eliminationCard, feedContainer.firstChild);

    // Simple fade out after duration (like old version)
    setTimeout(() => {
        if (eliminationCard.parentNode === feedContainer) {
            feedContainer.removeChild(eliminationCard);
        }
    }, DISPLAY_DURATION);
}

// Event listener for messages
window.addEventListener('message', function(event) {
    const data = event.data;

    switch (data.type) {
        case 'killfeed':
            console.log("Combat Feed:", data.killer, data.weapon, data.victim);
            createEliminationCard(
                data.killer,
                "#ffffff",
                './assets/killfeed/weapons/' + data.weapon + '.png',
                data.victim,
                "#cc0000", // color-8 equivalent
                data.isRedzone,
                data.prestige,
                data.killerPrestige,
                data.isFFA
            );
            break;
            
        case 'killfeed_status':
            console.log("Feed Status:", data.status);
            toggleFeedVisibility(data.status);
            break;
    }
});