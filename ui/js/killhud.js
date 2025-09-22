// Kill HUD Management
let killCount = 0;
let killHudVisible = false;

// Éléments DOM (seront initialisés après le chargement du DOM)
let killHud = null;
let killCountElement = null;

// Fonction d'initialisation
function initializeKillHud() {
    killHud = document.querySelector('.kill-hud');
    killCountElement = document.querySelector('.kill-count');
    
    if (!killHud || !killCountElement) {
        console.error('Kill HUD elements not found in DOM');
        return false;
    }
    
    return true;
}

// Fonctions utilitaires
function showKillHud() {
    if (!killHud && !initializeKillHud()) {
        console.warn('Kill HUD elements not available');
        return;
    }
    
    if (!killHudVisible) {
        killHud.style.display = 'flex';
        killHudVisible = true;
    }
}

function hideKillHud() {
    if (!killHud && !initializeKillHud()) {
        console.warn('Kill HUD elements not available');
        return;
    }
    
    if (killHudVisible) {
        killHud.style.display = 'none';
        killHudVisible = false;
    }
}

function updateKillCount(newCount) {
    if (!killHud && !initializeKillHud()) {
        console.warn('Kill HUD elements not available');
        return;
    }
    
    killCount = newCount;
    killCountElement.textContent = killCount;
    
    // Afficher le HUD
    showKillHud();
}

function incrementKillCount() {
    updateKillCount(killCount + 1);
}

function resetKillCount() {
    if (!killHud && !initializeKillHud()) {
        console.warn('Kill HUD elements not available');
        return;
    }
    
    killCount = 0;
    killCountElement.textContent = '0';
    hideKillHud();
}

// Initialisation après le chargement du DOM
document.addEventListener('DOMContentLoaded', function() {
    initializeKillHud();
});

// Si le DOM est déjà chargé
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeKillHud);
} else {
    initializeKillHud();
}

// Écouter les événements du serveur/client
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'showKillHud':
            showKillHud();
            if (data.count !== undefined) {
                updateKillCount(data.count);
            }
            break;
            
        case 'hideKillHud':
            hideKillHud();
            break;
            
        case 'updateKillCount':
            if (data.count !== undefined) {
                updateKillCount(data.count);
            }
            break;
            
        case 'incrementKill':
            incrementKillCount();
            break;
            
        case 'resetKills':
            resetKillCount();
            break;
    }
});

// Fonctions globales pour interaction avec le game mode
window.KillHUD = {
    show: showKillHud,
    hide: hideKillHud,
    updateCount: updateKillCount,
    increment: incrementKillCount,
    reset: resetKillCount,
    getCount: () => killCount
};

