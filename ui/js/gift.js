/**
 * Gift Box Feature
 * 
 * This script creates a gift box feature with:
 * - A gift button to the left of the inventory
 * - A modal dialog with spinning gift items
 * - Animation effects when selecting a gift
 * - Confetti celebration when receiving an item
 * - Real-time countdown that persists across disconnections
 * 
 * Based on the original gift.js code with same backend calls and principles.
 */

function debugLog(...args) {
    // console.log("[GIFT BOX]", ...args);
}

function PlaySoundGift() {
    const notificationSound = new Audio(`./assets/sounds/gift.wav`);
    notificationSound.volume = 0.5;
    notificationSound.play().catch(e => console.error('Error playing notification sound:', e));
}

// Gift box items configuration (same as original)
const giftBoxItems = [
    { id: 1, name: "Ped acces", rarity: "legendary", image: "./assets/items/ped_access1week.png", chance: 0, count: 1, item: "ped_access1week" },
    { id: 2, name: "Kill effect", rarity: "legendary", image: "./assets/items/kill_effect1week.png", chance: 0, count: 1, item: "kill_effect1week" },
    { id: 3, name: "AWP", rarity: "legendary", image: "./assets/items/weapon_heavysniper.png", chance: 2, count: 1, item: "weapon_heavysniper" },
    { id: 4, name: "Marksman Rifle Mk II", rarity: "epic", image: "./assets/items/weapon_marksmanrifle_mk2.png", chance: 5, count: 1, item: "weapon_marksmanrifle_mk2" },
    { id: 5, name: "Nightshark", rarity: "common", image: "./assets/items/nightshark.png", chance: 35, count: 1, item: "nightshark" },
    { id: 6, name: "RPG", rarity: "uncommon", image: "./assets/items/weapon_rpg.png", chance: 15, count: 1, item: "weapon_rpg" }, 
    { id: 7, name: "Deluxo", rarity: "rare", image: "./assets/items/deluxo.png", chance: 8, count: 1, item: "deluxo" },
    { id: 8, name: "Special Carbine", rarity: "common", image: "./assets/items/weapon_specialcarbine.png", chance: 30, count: 20, item: "weapon_specialcarbine" },
    { id: 9, name: "Bullpup Rifle MKII", rarity: "common", image: "./assets/items/weapon_bullpuprifle_mk2.png", chance: 30, count: 20, item: "weapon_bullpuprifle_mk2" },
    { id: 10, name: "M60 Mk II", rarity: "common", image: "./assets/items/weapon_combatmg_mk2.png", chance: 15, count: 15, item: "weapon_combatmg_mk2" },
    { id: 11, name: "Scarab", rarity: "common", image: "./assets/items/scarab.png", chance: 28, count: 1, item: "scarab" },
    { id: 12, name: "Marksman Rifle", rarity: "rare", image: "./assets/items/weapon_marksmanrifle.png", chance: 10, count: 1, item: "weapon_marksmanrifle" },
];

// Global variables
let giftBoxModal;
let giftBoxContainer; 
let giftBoxSpinner;
let giftBoxResult;
let spinButton;
let giftButton;

let canOpenGiftBox = true;
let nextGiftBoxTime = 0;
let countdownInterval = null;
let isSpinning = false;

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    debugLog('Initializing Gift Box system...');
    
    // Get the gift button
    giftButton = document.getElementById('giftButton');
    
    // Create the gift box modal
    createGiftBoxModal();
    
    // IMPORTANT : Charger le statut sauvegardé depuis le localStorage
    loadGiftBoxStatus();
    
    // Listen for messages from backend
    window.addEventListener('message', function(event) {
        const data = event.data;
        // debugLog('Received message from backend:', data);
        
        if (data.type === 'updateGiftBoxStatus') {
            debugLog('Updating gift box status:', data.canOpen, data.nextTime);
            updateGiftBoxStatus(data.canOpen, data.nextTime);
        } else if (data.type === 'openGiftBox' && !isSpinning) {
            openGiftBox({ 
                stopPropagation: () => {},
                data: data
            });
        }
    });
    
    debugLog('Gift Box system initialized');
});

// Update gift box status (availability and countdown)
function updateGiftBoxStatus(canOpen, nextTime) {
    debugLog('updateGiftBoxStatus called with:', canOpen, nextTime);
    canOpenGiftBox = canOpen;
    
    // Convertir le temps string en timestamp absolu si nécessaire
    if (typeof nextTime === 'string' && nextTime.includes(':')) {
        const timeParts = nextTime.split(':');
        if (timeParts.length === 3) {
            const hours = parseInt(timeParts[0]);
            const minutes = parseInt(timeParts[1]);
            const seconds = parseInt(timeParts[2]);
            const timeInSeconds = hours * 3600 + minutes * 60 + seconds;
            const absoluteTime = Math.floor(Date.now() / 1000) + timeInSeconds;
            debugLog('Converting string time to absolute time:', nextTime, '->', absoluteTime);
            nextGiftBoxTime = absoluteTime;
        } else {
            nextGiftBoxTime = nextTime;
        }
    } else {
        nextGiftBoxTime = nextTime;
    }
    
    // IMPORTANT : Sauvegarder le statut dans le localStorage pour persister entre les sessions
    saveGiftBoxStatus(canOpen, nextGiftBoxTime);
    
    // Le bouton navbar reste toujours cliquable pour ouvrir la modal
    if (giftButton) {
        giftButton.disabled = false;
        giftButton.classList.remove('disabled');
        
        if (canOpen && countdownInterval) {
            clearInterval(countdownInterval);
            countdownInterval = null;
        } else if (!canOpen && nextGiftBoxTime) {
            startCountdown(nextGiftBoxTime);
        }
    }
    
    // Mettre à jour le bouton dans la modal
    if (spinButton) {
        if (canOpen) {
            spinButton.disabled = false;
            spinButton.classList.remove('disabled');
            spinButton.textContent = 'OPEN BOX';
            debugLog('Spin button enabled');
        } else {
            spinButton.disabled = true;
            spinButton.classList.add('disabled');
            
            if (nextGiftBoxTime) {
                debugLog('Starting countdown modal with time:', nextGiftBoxTime);
                startCountdownModal(nextGiftBoxTime);
            } else {
                spinButton.textContent = 'NOT AVAILABLE';
                debugLog('Spin button disabled - not available');
            }
        }
    }
    
    // Si on ne peut pas ouvrir et qu'on a un temps, démarrer le countdown immédiatement
    if (!canOpen && nextGiftBoxTime && spinButton) {
        startCountdownModal(nextGiftBoxTime);
    }
}

// Start countdown timer (navbar button stays as "GIFT")
function startCountdown(nextTime) {
    if (countdownInterval) {
        clearInterval(countdownInterval);
    }
    
    const updateCountdown = () => {
        if (typeof nextTime === 'number') {
            const now = Math.floor(Date.now() / 1000);
            const timeRemaining = nextTime - now;
            
            if (timeRemaining <= 0) {
                clearInterval(countdownInterval);
                canOpenGiftBox = true;
                nextGiftBoxTime = 0;
                giftButton.disabled = false;
                giftButton.classList.remove('disabled');
                
                // IMPORTANT : Nettoyer le localStorage quand le cooldown est terminé
                clearGiftBoxStatus();
                return;
            }
        }
    };
    
    updateCountdown();
    countdownInterval = setInterval(updateCountdown, 1000);
}

// Start countdown timer for modal button
function startCountdownModal(nextTime) {
    if (!spinButton) return;
    
    debugLog('startCountdownModal called with:', nextTime);
    
    // Nettoyer l'interval précédent s'il existe
    if (window.modalCountdownInterval) {
        clearInterval(window.modalCountdownInterval);
    }
    
    // Convertir le temps string en timestamp absolu si nécessaire
    let absoluteTime = nextTime;
    if (typeof nextTime === 'string' && nextTime.includes(':')) {
        const timeParts = nextTime.split(':');
        if (timeParts.length === 3) {
            const hours = parseInt(timeParts[0]);
            const minutes = parseInt(timeParts[1]);
            const seconds = parseInt(timeParts[2]);
            const timeInSeconds = hours * 3600 + minutes * 60 + seconds;
            absoluteTime = Math.floor(Date.now() / 1000) + timeInSeconds;
            debugLog('Converted string time to absolute time:', nextTime, '->', absoluteTime);
            
            // Mettre à jour nextGiftBoxTime pour la persistance
            nextGiftBoxTime = absoluteTime;
            saveGiftBoxStatus(false, absoluteTime);
        }
    }
    
    const updateCountdown = () => {
        if (typeof absoluteTime === 'number') {
            const now = Math.floor(Date.now() / 1000);
            const timeRemaining = absoluteTime - now;
            
            if (timeRemaining <= 0) {
                // Temps écoulé, réactiver le bouton
                spinButton.disabled = false;
                spinButton.classList.remove('disabled');
                spinButton.textContent = 'OPEN BOX';
                canOpenGiftBox = true;
                nextGiftBoxTime = 0;
                debugLog('Countdown finished, button enabled');
                
                // IMPORTANT : Nettoyer le localStorage quand le cooldown est terminé
                clearGiftBoxStatus();
                
                // Nettoyer l'interval
                if (window.modalCountdownInterval) {
                    clearInterval(window.modalCountdownInterval);
                    window.modalCountdownInterval = null;
                }
                return;
            }
            
            // Calculer le temps restant
            const hours = Math.floor(timeRemaining / 3600);
            const minutes = Math.floor((timeRemaining % 3600) / 60);
            const seconds = Math.floor(timeRemaining % 60);
            
            const formattedTime = 
                `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
            
            spinButton.textContent = `AVAILABLE IN ${formattedTime}`;
            debugLog('Countdown update:', formattedTime, 'remaining:', timeRemaining);
        } else {
            spinButton.textContent = 'NOT AVAILABLE';
            debugLog('Countdown: not available');
        }
    };
    
    // Démarrer immédiatement et toutes les secondes
    updateCountdown();
    window.modalCountdownInterval = setInterval(updateCountdown, 1000);
}

// Create the gift box modal
function createGiftBoxModal() {
    giftBoxModal = document.createElement('div');
    giftBoxModal.className = 'gift-box-modal';
    giftBoxModal.style.display = 'none';
    
    giftBoxModal.innerHTML = `
        <div class="gift-box-content">
            <div class="gift-box-header">
                <span class="gift-box-title">GIFT BOX</span>
                <span class="gift-box-close" onclick="closeGiftBox()">&times;</span>
            </div>
            <div class="gift-box-spinner-container">
                <div class="gift-box-spinner"></div>
                <div class="gift-box-highlight"></div>
            </div>
            <div class="gift-box-controls">
                <button class="ui-button primary" onclick="spinGiftBox()">OPEN BOX</button>
            </div>
            <div class="gift-box-result"></div>
        </div>
    `;
    
    document.body.appendChild(giftBoxModal);
    
    giftBoxContainer = giftBoxModal.querySelector('.gift-box-spinner-container');
    giftBoxSpinner = giftBoxModal.querySelector('.gift-box-spinner');
    giftBoxResult = giftBoxModal.querySelector('.gift-box-result');
    spinButton = giftBoxModal.querySelector('.gift-box-controls button');
    
    // Vérifier que tous les éléments sont trouvés
    if (!giftBoxContainer || !giftBoxSpinner || !giftBoxResult || !spinButton) {
        console.error('Failed to initialize gift box elements:', {
            container: giftBoxContainer,
            spinner: giftBoxSpinner,
            result: giftBoxResult,
            button: spinButton
        });
    } else {
        debugLog('All gift box elements initialized successfully');
    }
}

// Open the gift box modal
function openGiftBox(event) {
    event.stopPropagation();
    
    if (isSpinning) {
        debugLog('Already spinning, ignoring open request');
        return;
    }
    
    debugLog('Opening gift box...');
    giftBoxModal.style.display = 'flex';
    
    populateSpinner();
    
    // Reset spinner position
    giftBoxSpinner.style.transition = 'none';
    giftBoxSpinner.style.transform = 'translateX(0)';
    
    // Clear any previous results
    giftBoxResult.innerHTML = '';
    
    // If event has data indicating we can open immediately
    if (event.data && event.data.canOpen === true) {
        continueSpinGiftBox();
        return;
    }
    
    // IMPORTANT : Mettre à jour le statut du bouton immédiatement à l'ouverture
    // pour afficher le bon état (OPEN BOX ou temps restant)
    if (spinButton) {
        if (canOpenGiftBox) {
            spinButton.disabled = false;
            spinButton.classList.remove('disabled');
            spinButton.textContent = 'OPEN BOX';
            debugLog('Modal opened - button enabled');
        } else {
            spinButton.disabled = true;
            spinButton.classList.add('disabled');
            
            if (nextGiftBoxTime) {
                debugLog('Modal opened - starting countdown with time:', nextGiftBoxTime);
                startCountdownModal(nextGiftBoxTime);
            } else {
                spinButton.textContent = 'NOT AVAILABLE';
                debugLog('Modal opened - button disabled, no time available');
            }
        }
    }
    
    // La modal s'ouvre toujours, même si on ne peut pas spin
    // Le bouton "OPEN BOX" dans la modal montrera le statut correct
    debugLog('Modal opened, button status updated based on current availability');
}

// Close the gift box modal
function closeGiftBox() {
    debugLog('Closing gift box');
    giftBoxModal.style.display = 'none';
    giftBoxResult.innerHTML = '';
    isSpinning = false;
    
    // NE PAS réinitialiser le bouton à "OPEN BOX" si on est en cooldown
    // Le bouton gardera son état actuel pour la prochaine ouverture
    debugLog('Modal closed, button state preserved for next opening');
    
    // Nettoyer le timeout de sécurité
    if (window.giftBoxSafetyTimeout) {
        clearTimeout(window.giftBoxSafetyTimeout);
        window.giftBoxSafetyTimeout = null;
    }
    
    // Nettoyer l'interval du countdown
    if (window.modalCountdownInterval) {
        clearInterval(window.modalCountdownInterval);
        window.modalCountdownInterval = null;
    }
}

// Populate the spinner with items
function populateSpinner() {
    giftBoxSpinner.innerHTML = '';
    giftBoxSpinner.className = 'gift-box-spinner';
    
    const section1 = document.createElement('div');
    section1.className = 'gift-box-item-section';
    
    const section2 = document.createElement('div');
    section2.className = 'gift-box-item-section';
    
    // Create multiple sets of items for smooth scrolling
    for (let i = 0; i < 30; i++) {
        giftBoxItems.forEach(item => {
            const itemElement = document.createElement('div');
            itemElement.className = `gift-box-item ${item.rarity}`;
            itemElement.setAttribute('data-id', item.id);
            itemElement.innerHTML = `
                <div class="item-image-gift">
                    <img src="${item.image}" alt="${item.name}">
                </div>
                <div class="item-name-gift">${item.name} x${item.count}</div>
            `;
            section1.appendChild(itemElement);
        });
    }
    
    // Duplicate for seamless scrolling
    section2.innerHTML = section1.innerHTML;
    
    giftBoxSpinner.appendChild(section1);
    giftBoxSpinner.appendChild(section2);
}

// Spin the gift box (called when button is clicked)
function spinGiftBox() {
    debugLog('spinGiftBox called - canOpen:', canOpenGiftBox, 'isSpinning:', isSpinning);
    
    if (!canOpenGiftBox || isSpinning) {
        debugLog('Cannot spin: canOpen =', canOpenGiftBox, 'isSpinning =', isSpinning);
        return; 
    }
    
    debugLog('Starting spin...');
    spinButton.disabled = true;
    spinButton.classList.add('disabled');
    spinButton.textContent = 'PROCESSING...';
    
    giftBoxResult.innerHTML = '';
    
    // Timeout de sécurité pour éviter le blocage
    window.giftBoxSafetyTimeout = setTimeout(() => {
        if (isSpinning) {
            debugLog('Safety timeout triggered, resetting button');
            resetSpinButton();
        }
    }, 30000); // 30 secondes de timeout
    
    // Call backend to spin gift box
    debugLog('Checking window.invokeNative:', !!window.invokeNative);
    
    if (window.invokeNative) {
        debugLog('Using backend callback...');
        
        // Utiliser le callback NUI spinGiftBox pour vérifier si on peut ouvrir
        $.post('https://gamemode/spinGiftBox', JSON.stringify({}), function(response) {
            debugLog('Spin response:', response);
            
            if (response && response.success === true) {
                // On peut ouvrir la gift box, lancer l'animation
                continueSpinGiftBox();
            } else {
                // On ne peut pas ouvrir la gift box
                debugLog('Cannot open gift box:', response);
                if (spinButton) {
                    spinButton.textContent = 'NOT AVAILABLE';
                    spinButton.disabled = false;
                    spinButton.classList.remove('disabled');
                }
                isSpinning = false;
                
                if (window.giftBoxSafetyTimeout) {
                    clearTimeout(window.giftBoxSafetyTimeout);
                    window.giftBoxSafetyTimeout = null;
                }
                
                // Afficher le temps restant si disponible
                if (response && response.nextTime) {
                    if (typeof response.nextTime === 'string' && response.nextTime.includes(':')) {
                        spinButton.textContent = `AVAILABLE IN ${response.nextTime}`;
                    } else if (typeof response.nextTime === 'number') {
                        const now = Math.floor(Date.now() / 1000);
                        const timeRemaining = response.nextTime - now;
                        if (timeRemaining > 0) {
                            const hours = Math.floor(timeRemaining / 3600);
                            const minutes = Math.floor((timeRemaining % 3600) / 60);
                            const seconds = Math.floor(timeRemaining % 60);
                            const formattedTime = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
                            spinButton.textContent = `AVAILABLE IN ${formattedTime}`;
                        }
                    }
                }
            }
        }).fail(function(error) {
            console.error('Error calling spinGiftBox callback:', error);
            if (spinButton) {
                spinButton.textContent = 'ERROR';
                spinButton.disabled = false;
                spinButton.classList.remove('disabled');
            }
            isSpinning = false;
            
            if (window.giftBoxSafetyTimeout) {
                clearTimeout(window.giftBoxSafetyTimeout);
                window.giftBoxSafetyTimeout = null;
            }
        });
        
        // Timeout de sécurité pour éviter le blocage infini
        setTimeout(() => {
            if (spinButton && spinButton.textContent === 'PROCESSING...') {
                debugLog('Callback timeout, forcing continue...');
                continueSpinGiftBox();
            }
        }, 5000); // 5 secondes de timeout
        
    } else {
        // For testing without backend
        debugLog('No backend, using test mode...');
        continueSpinGiftBox();
    }
}

// Continue with the spinning animation
function continueSpinGiftBox() {
    // Ne pas bloquer si déjà en train de tourner, on peut continuer
    if (isSpinning) {
        debugLog('Already spinning, but continuing anyway...');
    }
    
    isSpinning = true;
    debugLog('Continuing spin animation...');
    debugLog('DOM elements - spinner:', giftBoxSpinner, 'container:', giftBoxContainer);
    
    const selectedItem = getRandomItem();
    debugLog('Selected item:', selectedItem);
    
    // Vérifier que les éléments DOM existent
    if (!giftBoxSpinner || !giftBoxContainer) {
        console.error('DOM elements not found, resetting button');
        resetSpinButton();
        return;
    }
    
    // Start infinite scroll animation
    giftBoxSpinner.classList.add('gift-box-infinite-scroll');

    const initialScrollTime = 1000;      // 1 second of infinite scrolling
    const pauseTime = 500;               // 0.5 second pause
    const slowScrollTime = 9000;         // 9 seconds of slow scrolling to final position
    
    setTimeout(() => {
        // Stop infinite scroll
        giftBoxSpinner.classList.remove('gift-box-infinite-scroll');
        giftBoxSpinner.offsetHeight; // Force reflow

        // Reset position
        giftBoxSpinner.style.transition = 'none';
        giftBoxSpinner.style.transform = 'translateX(0)';
        giftBoxSpinner.offsetHeight; // Force reflow
        
        // Find matching items in the spinner
        const firstSection = giftBoxSpinner.querySelector('.gift-box-item-section');
        if (!firstSection) {
            console.error('Spinner section not found, resetting button');
            resetSpinButton();
            return;
        }
        
        const firstSectionItems = firstSection.children;
        const totalFirstSectionItems = firstSectionItems.length;
        const matchingItems = [];
        
        // Look for items starting from the middle
        const startIdx = Math.floor(totalFirstSectionItems * 0.5);
        
        for (let i = startIdx; i < totalFirstSectionItems; i++) {
            if (firstSectionItems[i].getAttribute('data-id') == selectedItem.id) {
                matchingItems.push({
                    element: firstSectionItems[i],
                    index: i
                });
            }
        }

        // If no items found in second half, search from beginning
        if (matchingItems.length === 0) {
            for (let i = 0; i < totalFirstSectionItems; i++) {
                if (firstSectionItems[i].getAttribute('data-id') == selectedItem.id) {
                    matchingItems.push({
                        element: firstSectionItems[i],
                        index: i
                    });
                }
            }
        }

        if (matchingItems.length === 0) {
            console.error('Could not find the selected item in the spinner');
            if (spinButton) {
                spinButton.disabled = false;
                spinButton.classList.remove('disabled');
                spinButton.textContent = 'OPEN BOX';
            }
            isSpinning = false;
            return;
        }
        
        // Choose a random matching item
        const randomIndex = Math.floor(Math.random() * matchingItems.length);
        const chosenItem = matchingItems[randomIndex];
        
        // Calculate stop position
        const itemWidth = 130; 
        const containerWidth = giftBoxContainer.offsetWidth;
        const centerOffset = (containerWidth / 2) - (itemWidth / 2);
        const stopPosition = (chosenItem.index * itemWidth) - centerOffset;
        
        // Initial fast scroll
        giftBoxSpinner.style.transition = 'transform 2s cubic-bezier(0.2, 0.8, 0.2, 1.0)';
        giftBoxSpinner.style.transform = 'translateX(-500px)';
        
        setTimeout(() => {
            // Final slow scroll to target
            giftBoxSpinner.style.transition = `transform ${slowScrollTime}ms cubic-bezier(0.1, 0.3, 0.1, 1.0)`;
            giftBoxSpinner.style.transform = `translateX(-${stopPosition}px)`;
            
            setTimeout(() => {
                displayResult(selectedItem);
                createConfetti();
                PlaySoundGift();
                isSpinning = false;
                
                // NE PAS réinitialiser le bouton à "OPEN BOX" ici
                // Le serveur enverra une mise à jour du statut via l'événement 'giftbox:updateStatus'
                // qui mettra automatiquement le bouton dans le bon état (temps restant ou OPEN BOX)
                debugLog('Animation finished, waiting for server status update...');
                
                // Nettoyer le timeout de sécurité
                if (window.giftBoxSafetyTimeout) {
                    clearTimeout(window.giftBoxSafetyTimeout);
                    window.giftBoxSafetyTimeout = null;
                }
            }, slowScrollTime + 200);
            
        }, pauseTime);
        
    }, initialScrollTime);
}

// Get random item based on chances
function getRandomItem() {
    const totalChance = giftBoxItems.reduce((sum, item) => sum + item.chance, 0);
    const randomNum = Math.random() * totalChance;
    
    let currentSum = 0;
    for (const item of giftBoxItems) {
        currentSum += item.chance;
        if (randomNum <= currentSum) {
            return item;
        }
    }
    
    return giftBoxItems[0]; // Fallback
}

// Display the result
function displayResult(item) {
    if (giftBoxResult.innerHTML !== '') {
        return;
    }
    
    debugLog('Displaying result:', item);
    
    giftBoxResult.innerHTML = `
        <div class="gift-box-result-item ${item.rarity}">
            <div class="result-header">You won!</div>
            <div class="result-item-image-gift">
                <img src="${item.image}" alt="${item.name}">
            </div>
            <div class="result-item-name-gift">${item.name} x${item.count}</div>
            <div class="result-item-rarity-gift">${item.rarity.toUpperCase()}</div>
        </div>
    `;
    
    // Add highlight effect to the won item
    const allItems = giftBoxSpinner.querySelectorAll('.gift-box-item');
    allItems.forEach(itemEl => {
        if (itemEl.getAttribute('data-id') == item.id) {
            itemEl.style.transform = 'scale(1.05)';
            itemEl.style.boxShadow = `0 0 15px ${getRarityColor(item.rarity)}`;
        }
    });
    
    // Send result to backend using NUI callback
    debugLog('Sending item to backend via NUI callback:', item);
    
    // Utiliser le callback NUI au lieu de fetch
    if (window.invokeNative) {
        // Envoyer via NUI callback
        $.post('https://gamemode/addItemSpinGiftBox', JSON.stringify({
            itemName: item.name,
            count: item.count, 
            item: item.item 
        }));
        debugLog('Item sent via NUI callback');
    } else {
        // Mode test - simuler l'envoi
        debugLog('Test mode - item would be sent:', item);
    }
}

// Helper function to get color based on rarity
function getRarityColor(rarity) {
    switch(rarity) {
        case 'common': return '#9e9e9e';
        case 'uncommon': return '#2196f3';
        case 'rare': return '#9c27b0';
        case 'epic': return '#ff9800';
        case 'legendary': return '#f44336';
        default: return 'white';
    }
}

// Create confetti effect
function createConfetti() {
    const confettiCount = 150;
    const confettiColors = ['#f44336', '#e91e63', '#9c27b0', '#673ab7', '#3f51b5', '#2196f3', '#03a9f4', '#00bcd4', '#009688', '#4CAF50', '#8BC34A', '#CDDC39', '#FFEB3B', '#FFC107', '#FF9800', '#FF5722'];
    
    for (let i = 0; i < confettiCount; i++) {
        const confetti = document.createElement('div');
        confetti.className = 'confetti';
        
        const color = confettiColors[Math.floor(Math.random() * confettiColors.length)];
        const size = Math.random() * 10 + 5;
        const left = Math.random() * 100;
        const animationDelay = Math.random() * 2;
        const animationDuration = Math.random() * 3 + 3;
        
        confetti.style.backgroundColor = color;
        confetti.style.width = `${size}px`;
        confetti.style.height = `${size}px`;
        confetti.style.left = `${left}%`;
        confetti.style.animationDelay = `${animationDelay}s`;
        confetti.style.animationDuration = `${animationDuration}s`;
        
        giftBoxModal.appendChild(confetti);
        
        // Remove confetti after animation completes
        setTimeout(() => {
            if (giftBoxModal.contains(confetti)) {
                giftBoxModal.removeChild(confetti);
            }
        }, (animationDelay + animationDuration) * 1000);
    }
}

// Fonction de sécurité pour réinitialiser le bouton
function resetSpinButton() {
    debugLog('resetSpinButton called');
    
    if (spinButton) {
        // Vérifier si on peut ouvrir la gift box avant de réinitialiser
        if (canOpenGiftBox) {
            spinButton.disabled = false;
            spinButton.classList.remove('disabled');
            spinButton.textContent = 'OPEN BOX';
            debugLog('Button reset to OPEN BOX (can open)');
        } else {
            // Si on ne peut pas ouvrir, afficher le temps restant
            spinButton.disabled = true;
            spinButton.classList.add('disabled');
            
            if (nextGiftBoxTime) {
                debugLog('Button reset - starting countdown with time:', nextGiftBoxTime);
                startCountdownModal(nextGiftBoxTime);
            } else {
                spinButton.textContent = 'NOT AVAILABLE';
                debugLog('Button reset - not available');
            }
        }
    } else {
        debugLog('spinButton not found!');
    }
    
    isSpinning = false;
    debugLog('isSpinning set to false');
    
    // Nettoyer le timeout de sécurité
    if (window.giftBoxSafetyTimeout) {
        clearTimeout(window.giftBoxSafetyTimeout);
        window.giftBoxSafetyTimeout = null;
        debugLog('Safety timeout cleared');
    }
}

// Fonction de debug pour tester le système
function debugGiftBox() {
    // console.log('=== GIFT BOX DEBUG ===');
    // console.log('canOpenGiftBox:', canOpenGiftBox);
    // console.log('isSpinning:', isSpinning);
    // console.log('giftButton:', giftButton);
    // console.log('spinButton:', spinButton);
    // console.log('giftBoxModal:', giftBoxModal);
    // console.log('giftBoxSpinner:', giftBoxSpinner);
    // console.log('giftBoxContainer:', giftBoxContainer);
    // console.log('Safety timeout:', window.giftBoxSafetyTimeout);
    // console.log('=====================');
}

// Fonction pour forcer le test de la gift box
function forceTestGiftBox() {
    debugLog('Force testing gift box...');
    if (spinButton) {
        spinButton.textContent = 'TESTING...';
        setTimeout(() => {
            continueSpinGiftBox();
        }, 1000);
    }
}

// Fonction pour sauvegarder le statut de la gift box dans le localStorage
function saveGiftBoxStatus(canOpen, nextTime) {
    try {
        const status = {
            canOpen: canOpen,
            nextTime: nextTime,
            timestamp: Date.now()
        };
        localStorage.setItem('giftBoxStatus', JSON.stringify(status));
        debugLog('Gift box status saved to localStorage:', status);
    } catch (error) {
        console.error('Error saving gift box status to localStorage:', error);
    }
}

// Fonction pour charger le statut de la gift box depuis le localStorage
function loadGiftBoxStatus() {
    try {
        const savedStatus = localStorage.getItem('giftBoxStatus');
        if (savedStatus) {
            const status = JSON.parse(savedStatus);
            debugLog('Loading gift box status from localStorage:', status);
            
            // Vérifier si le statut sauvegardé est encore valide
            if (status.nextTime && typeof status.nextTime === 'number') {
                const now = Math.floor(Date.now() / 1000);
                const timeRemaining = status.nextTime - now;
                
                if (timeRemaining > 0) {
                    // Le cooldown n'est pas encore terminé
                    canOpenGiftBox = false;
                    nextGiftBoxTime = status.nextTime;
                    debugLog('Cooldown still active, time remaining:', timeRemaining);
                    
                    // Mettre à jour l'interface si la modal est ouverte
                    if (spinButton) {
                        startCountdownModal(status.nextTime);
                    }
                } else {
                    // Le cooldown est terminé
                    canOpenGiftBox = true;
                    nextGiftBoxTime = 0;
                    debugLog('Cooldown finished, can open gift box');
                    
                    // Nettoyer le localStorage
                    localStorage.removeItem('giftBoxStatus');
                }
            } else if (status.canOpen === false && status.nextTime) {
                // Format string (HH:MM:SS) - on ne peut pas vérifier la validité
                canOpenGiftBox = false;
                nextGiftBoxTime = status.nextTime;
                debugLog('String time format loaded:', status.nextTime);
                
                // Si la modal est ouverte, démarrer le countdown
                if (spinButton) {
                    startCountdownModal(status.nextTime);
                }
            } else {
                // Statut valide
                canOpenGiftBox = status.canOpen;
                nextGiftBoxTime = status.nextTime || 0;
                debugLog('Valid status loaded:', status);
            }
        } else {
            debugLog('No saved gift box status found in localStorage');
        }
    } catch (error) {
        console.error('Error loading gift box status from localStorage:', error);
        // En cas d'erreur, nettoyer le localStorage et utiliser les valeurs par défaut
        localStorage.removeItem('giftBoxStatus');
        canOpenGiftBox = true;
        nextGiftBoxTime = 0;
    }
}

// Fonction pour nettoyer le statut sauvegardé (quand le cooldown est terminé)
function clearGiftBoxStatus() {
    try {
        localStorage.removeItem('giftBoxStatus');
        debugLog('Gift box status cleared from localStorage');
    } catch (error) {
        console.error('Error clearing gift box status from localStorage:', error);
    }
}

// Expose functions to the global scope (same as original)
window.openGiftBox = openGiftBox;
window.closeGiftBox = closeGiftBox;
window.spinGiftBox = spinGiftBox;
window.continueSpinGiftBox = continueSpinGiftBox;
window.resetSpinButton = resetSpinButton;
window.debugGiftBox = debugGiftBox;
window.forceTestGiftBox = forceTestGiftBox;
window.saveGiftBoxStatus = saveGiftBoxStatus;
window.loadGiftBoxStatus = loadGiftBoxStatus;
window.clearGiftBoxStatus = clearGiftBoxStatus;
