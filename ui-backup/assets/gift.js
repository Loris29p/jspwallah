/**
 * Gift Box Feature
 * 
 * This script creates a gift box feature with:
 * - A gift button in the left navbar's logo-wrapper area
 * - A modal dialog with spinning gift items
 * - Animation effects when selecting a gift
 * - Confetti celebration when receiving an item
 * 
 * The gift box button is styled to match the season-battlepass-button style.
 */
function debugLog(...args) {
    console.log("[GIFT BOX]", ...args);
}

function PlaySoundGift() {
    notificationSound = new Audio(`./assets/sounds/gift.wav`);
    notificationSound.volume = 0.5;
    notificationSound.play().catch(e => console.error('Error playing notification sound:', e));
}

const giftBoxItems = [
    { id: 1, name: "Marksman Rifle", rarity: "rare", image: "./assets/items/weapon_marksmanrifle.png", chance: 10, count: 1, item: "weapon_marksmanrifle" },
    { id: 2, name: "Marksman Rifle Mk II", rarity: "epic", image: "./assets/items/weapon_marksmanrifle_mk2.png", chance: 5, count: 1, item: "weapon_marksmanrifle_mk2" },
    { id: 3, name: "Nightshark", rarity: "common", image: "./assets/items/nightshark.png", chance: 35, count: 1, item: "nightshark" },
    { id: 4, name: "RPG", rarity: "uncommon", image: "./assets/items/weapon_rpg.png", chance: 25, count: 1, item: "weapon_rpg" }, 
    { id: 5, name: "AWP MK II", rarity: "legendary", image: "./assets/items/weapon_heavysniper_mk2.png", chance: 2, count: 1, item: "weapon_heavysniper_mk2" },
    { id: 6, name: "AWP", rarity: "legendary", image: "./assets/items/weapon_heavysniper.png", chance: 2, count: 1, item: "weapon_heavysniper" },
    { id: 7, name: "Deluxo", rarity: "rare", image: "./assets/items/deluxo.png", chance: 8, count: 1, item: "deluxo" },
    { id: 8, name: "Homing Launcher", rarity: "common", image: "./assets/items/weapon_hominglauncher.png", chance: 15, count: 1, item: "weapon_hominglauncher" },
    { id: 9, name: "M60", rarity: "common", image: "./assets/items/weapon_combatmg.png", chance: 30, count: 10, item: "weapon_combatmg" },
    { id: 10, name: "M60 Mk II", rarity: "common", image: "./assets/items/weapon_combatmg_mk2.png", chance: 30, count: 5, item: "weapon_combatmg_mk2" },
];

let giftBoxModal;
let giftBoxContainer; 
let giftBoxSpinner;
let giftBoxResult;
let spinButton;

let canOpenGiftBox = true;
let nextGiftBoxTime = 0;
let countdownInterval = null;

let isSpinning = false;

document.addEventListener('DOMContentLoaded', function() {
    const navbar = document.querySelector('.ui-navbar');
    if (navbar) {
        let logoWrapper = navbar.querySelector('.logo-wrapper');
        
        if (!logoWrapper) {
            logoWrapper = document.createElement('div');
            logoWrapper.className = 'logo-wrapper';
            navbar.insertBefore(logoWrapper, navbar.firstChild);
        }
        
        const giftButton = document.createElement('div');
        giftButton.className = 'season-battlepass-button gift-button';
        giftButton.innerHTML = `<img src="./assets/gift.png" alt="Gift" style="width: 3.2vh; height: 3.2vh; vertical-align: middle;"> GIFT`;
        giftButton.addEventListener('click', openGiftBox);
        
        logoWrapper.appendChild(giftButton);
    }

    createGiftBoxModal();
    
    createInfiniteScrollEffect();
    
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (data.type === 'updateGiftBoxStatus') {
            updateGiftBoxStatus(data.canOpen, data.nextTime);
        } else if (data.type === 'openGiftBox' && !isSpinning) {  // Prevent double opening
            openGiftBox({ 
                stopPropagation: () => {},
                data: data
            });
        }
    });
});


function updateGiftBoxStatus(canOpen, nextTime) {
    canOpenGiftBox = canOpen;
    
    if (spinButton) {
        if (canOpen) {
            spinButton.disabled = false;
            spinButton.classList.remove('disabled');
            spinButton.textContent = 'OPEN BOX';
            
            if (countdownInterval) {
                clearInterval(countdownInterval);
                countdownInterval = null;
            }
        } else {
            spinButton.disabled = true;
            spinButton.classList.add('disabled');
            
            if (nextTime) {
                startCountdown2(nextTime);
            } else {
                spinButton.textContent = 'NOT AVAILABLE';
            }
        }
    }
}

function startCountdown2(nextTime) {
    if (countdownInterval) {
        clearInterval(countdownInterval);
    }
    
    const updateCountdown = () => {
        let timeRemaining;
        
        if (typeof nextTime === 'string' && nextTime.includes(':')) {
            spinButton.textContent = `AVAILABLE IN ${nextTime}`;
            return;
        } else if (typeof nextTime === 'number') {
            const now = Math.floor(Date.now() / 1000);
            timeRemaining = nextTime - now;
            
            if (timeRemaining <= 0) {
                clearInterval(countdownInterval);
                canOpenGiftBox = true;
                spinButton.disabled = false;
                spinButton.classList.remove('disabled');
                spinButton.textContent = 'OPEN BOX';
                return;
            }
            
            const hours = Math.floor(timeRemaining / 3600);
            const minutes = Math.floor((timeRemaining % 3600) / 60);
            const seconds = Math.floor(timeRemaining % 60);
            
            const formattedTime = 
                `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
            
            spinButton.textContent = `AVAILABLE IN ${formattedTime}`;
        } else {
            spinButton.textContent = 'NOT AVAILABLE';
        }
    };
    
    updateCountdown();
    countdownInterval = setInterval(updateCountdown, 1000);
}

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
}

function createInfiniteScrollEffect() {
    const style = document.createElement('style');
    style.textContent = `
        @keyframes infiniteScroll {
            0% { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }
        
        @keyframes confettiFall {
            0% { transform: translateY(-100vh) rotate(0deg); }
            100% { transform: translateY(100vh) rotate(720deg); }
        }
        
        @keyframes giftPulse {
            0% { box-shadow: 0 0 0 0 rgba(255, 126, 126, 0.4); }
            70% { box-shadow: 0 0 0 6px rgba(255, 126, 126, 0); }
            100% { box-shadow: 0 0 0 0 rgba(255, 126, 126, 0); }
        }
        
        .gift-box-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.8);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999;
        }
        
        .gift-box-content {
            width: 80%;
            max-width: 800px;
            background-color: #222;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5);
            position: relative;
        }
        
        .gift-box-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .gift-box-title {
            font-size: 24px;
            font-weight: bold;
            color: gold;
        }
        
        .gift-box-close {
            font-size: 30px;
            color: white;
            cursor: pointer;
            transition: color 0.2s;
        }
        
        .gift-box-close:hover {
            color: red;
        }
        
        .gift-box-controls {
            display: flex;
            justify-content: center;
            margin: 20px 0;
        }
        
        .gift-box-result {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }
        
        .gift-box-result-item {
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            background: #2a2a2a;
            box-shadow: 0 0 10px rgba(255, 255, 255, 0.1);
        }
        
        .gift-box-result-item.common { border: 2px solid #9e9e9e; }
        .gift-box-result-item.uncommon { border: 2px solid #2196f3; }
        .gift-box-result-item.rare { border: 2px solid #9c27b0; }
        .gift-box-result-item.epic { border: 2px solid #ff9800; }
        .gift-box-result-item.legendary { border: 2px solid #f44336; }
        
        .result-header {
            font-size: 20px;
            font-weight: bold;
            color: gold;
            margin-bottom: 10px;
        }
        
        .result-item-image-gift {
            width: 100px;
            height: 100px;
            margin: 0 auto 10px;
        }
        
        .result-item-image-gift img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }
        
        .result-item-name-gift {
            font-size: 16px;
            font-weight: bold;
            color: white;
            margin-bottom: 5px;
        }
        
        .result-item-rarity-gift {
            font-size: 14px;
            color: #aaa;
        }
        
        .confetti {
            position: fixed;
            top: -20px;
            will-change: transform;
            animation: confettiFall linear forwards;
            z-index: 9990;
        }
        
        .gift-box-infinite-scroll {
            display: flex;
            width: auto;
            animation: infiniteScroll 30s linear infinite;
        }
        
        .gift-box-spinner-container {
            overflow: hidden;
            position: relative;
            background: rgba(0, 0, 0, 0.2);
            border-radius: 8px;
        }
        
        .gift-box-highlight {
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 130px;
            height: 100%;
            border-left: 4px solid gold;
            border-right: 4px solid gold;
            box-sizing: border-box;
            pointer-events: none;
            z-index: 10;
        }
        
        .gift-box-spinner {
            display: flex;
            width: auto;
            padding: 10px 0;
        }
        
        .gift-box-item-section {
            display: flex;
            flex-shrink: 0;
        }
        
        .gift-box-item {
            width: 120px;
            height: 120px;
            flex-shrink: 0;
            margin: 0 5px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 10px;
            box-sizing: border-box;
            background: #2a2a2a;
            transition: transform 0.2s;
        }
        
        .gift-box-item.common { border: 2px solid #9e9e9e; }
        .gift-box-item.uncommon { border: 2px solid #2196f3; }
        .gift-box-item.rare { border: 2px solid #9c27b0; }
        .gift-box-item.epic { border: 2px solid #ff9800; }
        .gift-box-item.legendary { border: 2px solid #f44336; }
        
        .item-image-gift {
            width: 60px;
            height: 60px;
            margin-bottom: 8px;
        }
        
        .item-image-gift img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }
        
        .item-name-gift {
            font-size: 12px;
            font-weight: bold;
            color: white;
        }
        
        /* Custom style for gift button */
        .gift-button {
            display: flex;
            align-items: center;
            gap: 0.6vh;
            background-color: #940000;
            color: #ff7e7e;
            padding: 0.4vh 0.9vh;
            border-radius: 4px;
            margin-left: 1vh;
            margin-bottom: 0.5vh;
            font-size: 1.5vh;
            text-transform: uppercase;
            font-family: "San Francisco";
            font-weight: bold;
            transition: all 0.2s ease-in-out;
            cursor: pointer;
            box-shadow: 0 0 5px rgba(255, 126, 126, 0.3);
            text-shadow: 0 0 2px rgba(255, 255, 255, 0.5);
            animation: giftPulse 2s infinite;
        }
        
        .gift-button:hover {
            opacity: 0.9;
            transform: scale(1.05);
            box-shadow: 0 0 8px rgba(255, 126, 126, 0.7);
            text-shadow: 0 0 4px rgba(255, 255, 255, 0.8);
        }
        
        /* Disabled button style */
        .ui-button.disabled {
            background-color: #6b0000 !important;
            color: #ff5252 !important;
            cursor: not-allowed !important;
            opacity: 0.7 !important;
        }
    `;
    document.head.appendChild(style);
}

// Open the gift box modal
function openGiftBox(event) {
    event.stopPropagation();
    
    if (isSpinning) {
        return;
    }
    
    giftBoxModal.style.display = 'flex';
    
    populateSpinner();
    
    giftBoxSpinner.style.transition = 'none';
    giftBoxSpinner.style.transform = 'translateX(0)';
    
    if (event.data && event.data.canOpen === true) {
        continueSpinGiftBox();
        return;
    }
    if (window.invokeNative) {
        fetch('https://gamemode/spinGiftBox', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).then(resp => resp.json()).then(resp => {

            if (resp && resp.success === true && !isSpinning) {
                continueSpinGiftBox();
            } else {
            }
        }).catch(error => {
            console.error('Error checking gift box availability:', error);
        });
    }
}

function closeGiftBox() {
    giftBoxModal.style.display = 'none';
    giftBoxResult.innerHTML = '';
    isSpinning = false;
}

// Populate the spinner with items
function populateSpinner() {
    giftBoxSpinner.innerHTML = '';
    giftBoxSpinner.className = 'gift-box-spinner';
    
    const section1 = document.createElement('div');
    section1.className = 'gift-box-item-section';
    
    const section2 = document.createElement('div');
    section2.className = 'gift-box-item-section';
    
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
    
    section2.innerHTML = section1.innerHTML;
    
    giftBoxSpinner.appendChild(section1);
    giftBoxSpinner.appendChild(section2);
}

function spinGiftBox() {
    if (!canOpenGiftBox || isSpinning) {
    
        return; 
    }
    
    spinButton.disabled = true;
    spinButton.classList.add('disabled');
    spinButton.textContent = 'PROCESSING...';
    
    giftBoxResult.innerHTML = '';
    
    if (window.invokeNative) {
        fetch('https://gamemode/spinGiftBox', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).then(resp => resp.json()).then(resp => {
            if (resp && resp.success === true && !isSpinning) {
                continueSpinGiftBox();
            } else {
            }
        }).catch(error => {
            console.error('Error opening gift box:', error);
            spinButton.textContent = 'ERROR';
            spinButton.disabled = false;
            spinButton.classList.remove('disabled');
            isSpinning = false;
        });
    } else {
        continueSpinGiftBox();
    }
}

function continueSpinGiftBox() {
    if (isSpinning) {
        return;
    }
    
    isSpinning = true;
    const selectedItem = getRandomItem();
    
    giftBoxSpinner.classList.add('gift-box-infinite-scroll');

    const initialScrollTime = 1000;      // 1 second of infinite scrolling
    const pauseTime = 500;               // 0.5 second pause
    const slowScrollTime = 9000;         // 9 seconds of slow scrolling to final position
    const totalAnimationTime = initialScrollTime + pauseTime + slowScrollTime;
    
    setTimeout(() => {
        giftBoxSpinner.classList.remove('gift-box-infinite-scroll');

        giftBoxSpinner.offsetHeight;

        giftBoxSpinner.style.transition = 'none';
        giftBoxSpinner.style.transform = 'translateX(0)';
        giftBoxSpinner.offsetHeight; 
        

        const firstSectionItems = giftBoxSpinner.querySelector('.gift-box-item-section').children;
        const totalFirstSectionItems = firstSectionItems.length;
        const matchingItems = [];
        

        const startIdx = Math.floor(totalFirstSectionItems * 0.5);
        
        for (let i = startIdx; i < totalFirstSectionItems; i++) {
            if (firstSectionItems[i].getAttribute('data-id') == selectedItem.id) {
                matchingItems.push({
                    element: firstSectionItems[i],
                    index: i
                });
            }
        }

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
            spinButton.disabled = false;
            spinButton.classList.remove('disabled');
            isSpinning = false;
            return;
        }
        

        const randomIndex = Math.floor(Math.random() * matchingItems.length);
        const chosenItem = matchingItems[randomIndex];
        
        const itemWidth = 130; 
        const containerWidth = giftBoxContainer.offsetWidth;
        const centerOffset = (containerWidth / 2) - (itemWidth / 2);
        
        const stopPosition = (chosenItem.index * itemWidth) - centerOffset;
        
        giftBoxSpinner.style.transition = 'transform 2s cubic-bezier(0.2, 0.8, 0.2, 1.0)';
        giftBoxSpinner.style.transform = 'translateX(-500px)';
        
        setTimeout(() => {
            giftBoxSpinner.style.transition = `transform ${slowScrollTime}ms cubic-bezier(0.1, 0.3, 0.1, 1.0)`;
            giftBoxSpinner.style.transform = `translateX(-${stopPosition}px)`;
            
            setTimeout(() => {
                displayResult(selectedItem);
                
                createConfetti();
                PlaySoundGift();
                isSpinning = false;
            }, slowScrollTime + 200);
            
        }, pauseTime);
        
    }, initialScrollTime);
}

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
    
    return giftBoxItems[0];
}

// Display the result
function displayResult(item) {
    if (giftBoxResult.innerHTML !== '') {
        return;
    }
    
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
    
    // Log the won item and post to server only once
    console.log('Item won:', item);
    $.post("https://gamemode/addItemSpinGiftBox", JSON.stringify({ itemName: item.name,
        count: item.count, item: item.item }));
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

// Expose functions to the global scope
window.openGiftBox = openGiftBox;
window.closeGiftBox = closeGiftBox;
window.spinGiftBox = spinGiftBox;
window.continueSpinGiftBox = continueSpinGiftBox;