let selectedBadge = null;

function initializeBadges() {
    const container = document.querySelector('.badge-container');
    
    const disclaimer = document.createElement('div');
    disclaimer.className = 'badge-disclaimer';
    disclaimer.textContent = 'You can equip a badge to your character. You can remove it at any time.';
    container.appendChild(disclaimer);
    
    const badgeGrid = document.createElement('div');
    badgeGrid.className = 'badge-grid';
    
    for (let i = 1; i <= 51; i++) {
        const badgeCard = document.createElement('div');
        badgeCard.className = 'badge-card';
        badgeCard.innerHTML = `
            <img src="./assets/badges/badge_${i}.png" alt="Badge ${i}" class="badge-image">
        `;
        
        badgeCard.addEventListener('click', () => {
            const previouslySelected = document.querySelector('.badge-card.selected');
            if (previouslySelected) {
                previouslySelected.classList.remove('selected');
            }
            
            badgeCard.classList.add('selected');
            selectedBadge = i;
        });
        
        badgeGrid.appendChild(badgeCard);
    }
    
    container.appendChild(badgeGrid);
    
    const equipButton = document.createElement('button');
    equipButton.className = 'badge-equip-btn';
    equipButton.textContent = 'Equip Badge';
    equipButton.addEventListener('click', () => {
        if (selectedBadge !== null) {

            const previouslySelected = document.querySelector('.badge-card.selected');
            if (previouslySelected) {
                previouslySelected.classList.remove('selected');
            }

            $.post("https://gamemode/equipBadge", JSON.stringify({
                badge: selectedBadge
            }));

            selectedBadge = null;
        }
    });
    container.appendChild(equipButton);

    // Remove the equip button
    const removeButton = document.createElement('button');
    removeButton.className = 'badge-remove-btn';
    removeButton.textContent = 'Remove Badge';
    removeButton.addEventListener('click', () => {
        if (selectedBadge !== null) {

            const previouslySelected = document.querySelector('.badge-card.selected');
            if (previouslySelected) {
                previouslySelected.classList.remove('selected');
            }
            $.post("https://gamemode/removeBadge", JSON.stringify({}));
            selectedBadge = null;
        }
    });
    container.appendChild(removeButton);
}

document.addEventListener('DOMContentLoaded', initializeBadges);

function toggleBadgeContainer(show = true) {
    const container = document.querySelector('.badge-container');
    container.style.display = show ? 'flex' : 'none';
    console.log(container.style.display, "CONTAINER DISPLAY")
}


window.addEventListener('message', (event) => {
    if (event.data.action === 'toggleBadgeContainer') {
        console.log(event.data.show, "EVENT DATA SHOW")
        toggleBadgeContainer(event.data.show);
    }
});

document.addEventListener('keyup', function(event) {
    // ESC key (27) or DELETE key (46)
    if (event.keyCode === 27 || event.keyCode === 46) {
        if ($('.badge-container').is(':visible')) {
            toggleBadgeContainer(false);
            fetch(`https://gamemode/closeMenuBadge`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        }
    }
});