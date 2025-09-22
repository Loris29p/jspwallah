// Debug flag for console logging
const DEBUG_KILLCAM = true;

window.addEventListener("message", function (event) {
    const eventData = event.data;

    if (eventData && eventData.type == "deathframe") {
        deathFrame(eventData);
    }
});

function deathFrame(data) {
    if (data.bool) {
        // Debug: Vérifier que l'élément existe
        const killcamElement = $(".killcam");
        if (killcamElement.length === 0) {
            console.error("ERREUR: Élément .killcam introuvable dans le DOM!");
            return;
        }


        // Traitement simple de l'UUID (nombre ou string)
        let uuid = data.uuid;
        if (typeof uuid === "number") {
            uuid = uuid.toString();
        } else if (!uuid || (typeof uuid === "string" && uuid.trim().length === 0)) {
            uuid = "N/A";
        }

        // Préservation complète du username avec les balises HTML de couleur
        let username = data.username || "Unknown Player";

        // Générer le badge seulement si prestige > 0
        const badgeHtml =
            data && data.prestige > 0
                ? `
            <div class="game-badge">
                <img alt="" src="/ui/assets/badges/badge_${data.prestige}.png">
            </div>
        `
                : "";

        const content = `
        <div class="death-killer">
                ${badgeHtml}
                <span class="killer-username">
                  ${username} [${uuid}]
                </span>
                <div class="killerlife">
                  <span class="armor-status">
                    <svg width="20" height="20" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="shield" class="svg-inline--fa fa-shield " role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                      <path fill="currentColor" d="M256 0c4.6 0 9.2 1 13.4 2.9L457.7 82.8c22 9.3 38.4 31 38.3 57.2c-.5 99.2-41.3 280.7-213.6 363.2c-16.7 8-36.1 8-52.8 0C57.3 420.7 16.5 239.2 16 140c-.1-26.2 16.3-47.9 38.3-57.2L242.7 2.9C246.8 1 251.4 0 256 0z"></path>
                    </svg>${data.armor || 0}</span>
                  <span class="health-status">
                    <svg width="20" height="20" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="heart" class="svg-inline--fa fa-heart " role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                      <path fill="currentColor" d="M47.6 300.4L228.3 469.1c7.5 7 17.4 10.9 27.7 10.9s20.2-3.9 27.7-10.9L464.4 300.4c30.4-28.3 47.6-68 47.6-109.5v-5.8c0-69.9-50.5-129.5-119.4-141C347 36.5 300.6 51.4 268 84L256 96 244 84c-32.6-32.6-79-47.5-124.6-39.9C50.5 55.6 0 115.2 0 185.1v5.8c0 41.5 17.2 81.2 47.6 109.5z"></path>
                    </svg>${data.health || 0}</span>
                </div>
              </div>
              ${
                  data.deathmessage
                      ? `
                <div class="death-message">
                    <span class="message glitch">${data.deathmessage}</span>
                </div>
                `
                      : ""
              }
            <p class="death-message-press-f">PRESS <strong>F</strong> TO PASS</p>
        `;

        // Nettoyer d'abord le contenu existant
        killcamElement.empty();

        // Ajouter le nouveau contenu avec .html() pour interpréter les balises HTML
        killcamElement.html(content);

        // Afficher l'élément
        killcamElement.css("display", "flex");


        // Auto-hide après 8 secondes
        setTimeout(() => {
            closeDeathInterface();
        }, 8000);
    } else {
        closeDeathInterface();
    }
}

function closeDeathInterface() {
    $(".killcam").css("display", "none");
    $(".killcam").empty();
}

// Emergency close avec ESC
document.addEventListener("keydown", function (keyPress) {
    if (keyPress.key === "Escape") {
        closeDeathInterface();
    }
});

// Fonctions de test simplifiées
function testColoredUsername() {
    const testData = {
        type: "deathframe",
        bool: true,
        username: "<FONT color='#F44336'>RF</FONT> thoughtthewall99",
        uuid: 12345,
        armor: 100,
        health: 50,
        prestige: 2,
        deathmessage: "Headshot!",
    };

    deathFrame(testData);
}

function testPlainUsername() {
    const testData = {
        type: "deathframe",
        bool: true,
        username: "PlainUsername",
        uuid: 67890,
        armor: 75,
        health: 25,
        prestige: 1,
        deathmessage: "Eliminated!",
    };

    deathFrame(testData);
}

function testNumericUuid() {
    const testData = {
        type: "deathframe",
        bool: true,
        username: "TestPlayer",
        uuid: 12345, // UUID numérique
        armor: 85,
        health: 65,
        prestige: 2,
        deathmessage: "Numeric UUID test!",
    };
    deathFrame(testData);
}

function testColorPreservation() {
    const testData = {
        type: "deathframe",
        bool: true,
        username: "<FONT color='#FF0000'>RedPlayer</FONT>",
        uuid: 11111,
        armor: 100,
        health: 100,
        prestige: 1,
        deathmessage: "Color preservation test!",
    };

    deathFrame(testData);
}

// Nouveau test pour les cas spécifiques mentionnés
function testMultipleColors() {
    const testData = {
        type: "deathframe",
        bool: true,
        username: "<FONT color='#9C27B0'>K6</FONT> <FONT color='#9C27B0'>BelekAuSorciere</FONT>",
        uuid: 22222,
        armor: 90,
        health: 80,
        prestige: 3,
        deathmessage: "Multiple colors test!",
    };

    deathFrame(testData);
}

function testPrestigeZero() {
    const testData = {
        type: "deathframe",
        bool: true,
        username: "<FONT color='#F44336'>RF</FONT> GodGamer899",
        uuid: 33333,
        armor: 50,
        health: 30,
        prestige: 0, // Prestige 0 - ne devrait pas afficher de badge
        deathmessage: "No badge test!",
    };

    deathFrame(testData);
}

function testMixedColorAndPlain() {
    const testData = {
        type: "deathframe",
        bool: true,
        username: "<FONT color='#F44336'>RF</FONT> GodGamer899",
        uuid: 44444,
        armor: 75,
        health: 60,
        prestige: 1,
        deathmessage: "Mixed color test!",
    };


    deathFrame(testData);
}

function forceHideDeathUI() {
    closeDeathInterface();
}

// Fonction de debug pour vérifier le DOM
function debugKillcamDOM() {
    const killcamElement = $(".killcam");

    if (killcamElement.length > 0) {
        
    } else {
        console.error("Aucun élément .killcam trouvé!");
    }

    // Vérifier aussi pvp-death-overlay
    const pvpOverlay = $(".pvp-death-overlay");
}

// Test simple pour forcer l'affichage
function testForceDisplay() {
    const killcamElement = $(".killcam");
    if (killcamElement.length > 0) {
        killcamElement.html(
            '<div style="color: red; font-size: 50px; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);">TEST KILLCAM</div>'
        );
        killcamElement.css("display", "flex");

        setTimeout(() => {
            killcamElement.css("display", "none");
            killcamElement.empty();
        }, 3000);
    } else {
        console.error("Impossible de tester - élément .killcam introuvable");
    }
}

// Ajouter les fonctions au scope global pour les tests
window.testColoredUsername = testColoredUsername;
window.testPlainUsername = testPlainUsername;
window.testNumericUuid = testNumericUuid;
window.testColorPreservation = testColorPreservation;
window.testMultipleColors = testMultipleColors;
window.testPrestigeZero = testPrestigeZero;
window.testMixedColorAndPlain = testMixedColorAndPlain;
window.forceHideDeathUI = forceHideDeathUI;
window.debugKillcamDOM = debugKillcamDOM;
window.testForceDisplay = testForceDisplay;
