const timers = {};
const intervals = {};

const effectTimers = {
  antizin: { duration: 360 },
  spawncar: { duration: 5 },
  babygod: { duration: 2 },
  safezone: { duration: 3 },
  flesh: { duration: 180 },
  combatmode: { duration: 2 },
  trackerdeluxo: { duration: 60 },
};

window.addEventListener('message', function(e) {
    const data = e.data;
    if (data.type === 'updateStatus') {
        SetHealth(data.health);
        SetArmor(data.armor);
    } else if (data.type === 'showHud') {
        ShowHud(data.show);
    } else if (data.type === 'startEffect') {
        startEffect(data.effect);
    } else if (data.type === 'stopEffect') {
        hideEffect(data.effect);
    } else if (data.type === 'updatecombatmode') {
        if (data.combatmode) {
            startCombatMode();
        } else {
            stopCombatMode();
        }
    } else if (data.type === 'spawncar') {
        startSpawnCar();
    }
});

function ShowHud(bool) {
    if (bool) {
        $('.player-status-panel').css('display', 'block');
    } else {
        $('.player-status-panel').css('display', 'none');
    }
}

function SetHealth(health) {
    const fillElement = $('.vital-row.vitality .vital-meter .meter-background .meter-fill');
    
    if (health > 0) {
        fillElement.css('width', health + '%');
    } else {
        fillElement.css('width', health + '%');
    }


    if (health < 39) {
        fillElement.addClass('low-warning');
    } else {
        fillElement.removeClass('low-warning');
    }
}

function SetArmor(armor) {
    if (armor === 0) {
        $('.vital-row.defense').remove();
        return;
    }
    if ($('.vitals-container .vital-row.defense').length === 0) {
        const armorRow = `
            <div class="vital-row defense">
              <div class="vital-icon">
                <div class="icon-wrapper" style="margin-bottom: 0.25vh; display: flex; align-items: center; justify-content: center;">
                  <div style="display: flex; align-items: center; justify-content: center;">
                    <svg width="15" height="15" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path fill="currentColor" d="M12 1L3 5v6c0 5.5 3.8 10.7 9 12 5.2-1.3 9-6.5 9-12V5l-9-4zm0 2l7 3v5c0 4.5-3.2 8.6-7 9.9C8.2 19.6 5 15.5 5 11V6l7-3z"/>
                    </svg>
                  </div>
                </div>
              </div>
              <div class="vital-meter">
                <div class="meter-background">
                  <div class="meter-base">
                    <div class="segment-line seg-1"></div>
                    <div class="segment-line seg-2"></div>
                    <div class="segment-line seg-3"></div>
                    <div class="meter-fill" style="width: 100%;"></div>
                  </div>
                </div>
              </div>
            </div>
        `;
        $('.vitals-container').append(armorRow);
    }
    $('.vital-row.defense .vital-meter .meter-background .meter-fill').css('width', armor + '%');
}

// Modifier la fonction de test pour mieux voir l'animation
function TestHUD() {
    let health = 100;
    let armor = 100;
    let direction = -1;

    // Afficher le HUD
    ShowHud(true);
    
    // Mettre à jour les valeurs initiales
    SetHealth(health);
    SetArmor(armor);

    // Simuler des changements toutes les 2 secondes
    setInterval(() => {
        // Changer la vie plus lentement
        health += direction * 5; // Changé de 10 à 5 pour un changement plus progressif
        if (health <= 0 || health >= 100) {
            direction *= -1;
        }
        SetHealth(health);

        // Changer l'armure de façon différente
        armor = Math.max(0, Math.min(100, armor + (Math.random() > 0.5 ? 10 : -10)));
        SetArmor(armor);

    }, 1000); // Changé de 2000 à 1000 pour des mises à jour plus fréquentes
}

const activeTimers = {};

function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes}:${secs < 10 ? '0' : ''}${secs}`;
}

function initializeEffect(effectName, duration) {
    const effect = document.querySelector(`.${effectName}`);
    if (!effect) {
        console.error(`Effet introuvable: ${effectName}`);
        return;
    }

    let timeDisplay, progressPath;
    
    if (effectName === 'safezone') {
        // Pour safezone, utiliser les nouvelles classes
        progressPath = effect.querySelector('.safezone-path');
    } else if (effectName === 'combatmode') {
        // Pour combatmode, utiliser les nouvelles classes
        progressPath = effect.querySelector('.combatmode-path');
    } else if (effectName === 'spawncar') {
        // Pour spawncar, utiliser les nouvelles classes
        progressPath = effect.querySelector('.spawncar-path');
    } else if (effectName === 'trackerdeluxo') {
        // Pour trackerdeluxo, utiliser les nouvelles classes
        progressPath = effect.querySelector('.trackerdeluxo-path');
    } else {
        // Pour les autres effets, utiliser les classes existantes
        timeDisplay = effect.querySelector('.time');
        progressPath = effect.querySelector('.CircularProgressbar-path');
    }

    resetEffect(effect, effectName);
    if (timeDisplay) timeDisplay.textContent = formatTime(duration);
    if (progressPath) {
        if (effectName === 'safezone' || effectName === 'combatmode' || effectName === 'spawncar' || effectName === 'trackerdeluxo') {
            progressPath.style.strokeDashoffset = '0'; // Cercle plein pour se vider
        } else {
            progressPath.style.strokeDashoffset = '289.027';
        }
    }
    effect.style.display = '';
    $(effect).hide().fadeIn(100, () => startCountdown(effectName, duration, timeDisplay, progressPath));
}

function startCountdown(effectName, duration, timeDisplay, progressPath) {
    let remainingTime = duration;
    const timerId = setInterval(() => {
        remainingTime--;
        if (timeDisplay) timeDisplay.textContent = formatTime(remainingTime);
        
        if (effectName === 'safezone' || effectName === 'combatmode' || effectName === 'spawncar' || effectName === 'trackerdeluxo') {
            // Pour safezone, combatmode, spawncar et trackerdeluxo, la barre se vide progressivement (de 0 à 283)
            // Quand remainingTime diminue, la barre se vide (strokeDashoffset augmente)
            const progress = ((duration - remainingTime) / duration) * 283;
            progressPath.style.strokeDashoffset = progress;
        } else {
            // Pour les autres effets, utiliser l'ancienne formule
            const progress = (remainingTime / duration) * 289.027;
            progressPath.style.strokeDashoffset = progress;
        }

        if (remainingTime <= 0) {
            clearInterval(timerId);
            completeEffect(effectName);
        }
    }, 1000);

    activeTimers[effectName] = timerId;
    $('.extra-container').css('display', 'flex');
}

function completeEffect(effectName) {
    $.post(`https://gamemode/hudEffects`, JSON.stringify({ effect: effectName, state: false }));
    hideEffect(effectName);
}

function hideEffect(effectName) {
    const effect = document.querySelector(`.${effectName}`);
    if (effect) {
        effect.style.display = 'none';
    }
}

function resetEffect(effect, effectName) {
    if (effectName === 'safezone') {
        const progressPath = effect.querySelector('.safezone-path');
        if (progressPath) {
            progressPath.style.strokeDashoffset = '0'; // Cercle plein pour se vider
        }
    } else if (effectName === 'combatmode') {
        const progressPath = effect.querySelector('.combatmode-path');
        if (progressPath) {
            progressPath.style.strokeDashoffset = '0'; // Cercle plein pour se vider
        }
    } else if (effectName === 'spawncar') {
        const progressPath = effect.querySelector('.spawncar-path');
        if (progressPath) {
            progressPath.style.strokeDashoffset = '0'; // Cercle plein pour se vider
        }
    } else if (effectName === 'trackerdeluxo') {
        const progressPath = effect.querySelector('.trackerdeluxo-path');
        if (progressPath) {
            progressPath.style.strokeDashoffset = '0'; // Cercle plein pour se vider
        }
    } else {
        const timeDisplay = effect.querySelector('.time');
        const progressPath = effect.querySelector('.CircularProgressbar-path');
        
        if (timeDisplay) timeDisplay.textContent = '';
        if (progressPath) progressPath.style.strokeDashoffset = '289.027';
    }
}

function startEffect(effectName) {
    let duration = 5;

    switch (effectName) {
        case "antizin": duration = 360; break;
        case "spawncar": duration = 5; break;
        case "babygod": duration = 2; break;
        case "safezone": duration = 3; break;
        case "flesh": duration = 180; break;
        case "combatmode": duration = 2; break;
        case "trackerdeluxo": duration = 60; break;
    }

    if (activeTimers[effectName]) {
        clearInterval(activeTimers[effectName]);
        hideEffect(effectName);
    }

    initializeEffect(effectName, duration);
}

// Combat Mode Functions
let combatModeTimer = null;

// Spawn Car Functions
let spawnCarTimer = null;

function startCombatMode() {
    const effect = document.querySelector('.combatmode');
    if (!effect) return;
    
    // Arrêter le timer précédent s'il existe
    if (combatModeTimer) {
        clearTimeout(combatModeTimer);
    }
    
    // Utiliser le même système que safezone
    const progressPath = effect.querySelector('.combatmode-path');
    if (progressPath) {
        progressPath.style.strokeDashoffset = '0'; // Cercle plein au début
    }
    
    effect.style.display = 'block';
    $(effect).hide().fadeIn(100, () => startCountdown('combatmode', 2, null, progressPath));
}

function stopCombatMode() {
    const effect = document.querySelector('.combatmode');
    if (!effect) return;
    
    // Arrêter le timer s'il existe
    if (combatModeTimer) {
        clearTimeout(combatModeTimer);
    }
    
    // Cacher l'effet immédiatement
    effect.style.display = 'none';
    
    // Reset la progression pour la prochaine fois
    const progressPath = effect.querySelector('.combatmode-path');
    if (progressPath) {
        progressPath.style.strokeDashoffset = '0'; // Cercle plein pour la prochaine activation
    }
}

function startSpawnCar() {
    const effect = document.querySelector('.spawncar');
    if (!effect) return;
    
    // Arrêter le timer précédent s'il existe
    if (spawnCarTimer) {
        clearTimeout(spawnCarTimer);
    }
    
    // Utiliser le même système que safezone
    const progressPath = effect.querySelector('.spawncar-path');
    if (progressPath) {
        progressPath.style.strokeDashoffset = '0'; // Cercle plein au début
    }
    
    effect.style.display = 'block';
    $(effect).hide().fadeIn(100, () => startCountdown('spawncar', 5, null, progressPath));
}

function stopSpawnCar() {
    const effect = document.querySelector('.spawncar');
    if (!effect) return;
    
    // Arrêter le timer s'il existe
    if (spawnCarTimer) {
        clearTimeout(spawnCarTimer);
    }
    
    // Cacher l'effet immédiatement
    effect.style.display = 'none';
    
    // Reset la progression pour la prochaine fois
    const progressPath = effect.querySelector('.spawncar-path');
    if (progressPath) {
        progressPath.style.strokeDashoffset = '0'; // Cercle plein pour la prochaine activation
    }
}

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'startEffect') {
        startEffect(data.effect);
    } else if (data.type === 'stopEffect') {
        hideEffect(data.effect);
    } else if (data.type === 'updatecombatmode') {
        if (data.combatmode) {
            startCombatMode();
        } else {
            stopCombatMode();
        }
    } else if (data.type === 'spawncar') {
        startSpawnCar();
    } else if (data.type === 'trackerdeluxo') {
        startEffect('trackerdeluxo');
    }
});

document.addEventListener('DOMContentLoaded', () => {
    console.log("Document chargé");
    const effectNames = ['antizin', 'spawncar', 'babygod', 'safezone', 'flesh', 'combatmode', 'trackerdeluxo'];
    effectNames.forEach(name => hideEffect(name));
});
