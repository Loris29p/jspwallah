window.addEventListener('message', function(event) {
    const data = event.data;
  
    if (data.type === 'updateGameModeSelec') {
        UpdateGameModeSelect(data);
    } else if (data.type === 'openGameModeSelec') {
        OpenSelectMode(data.show)
    }
});

function OpenSelectMode(state) {
    const lobbyWindow = document.querySelector('.gamemode-selection');
    const gamemodeList = document.querySelector('.gamemode-list');
    if (lobbyWindow) {
        // Si state est true, affiche la fenêtre, sinon la cache
        lobbyWindow.style.display = state ? 'block' : 'none';
        if (gamemodeList) {
            gamemodeList.style.display = state ? 'block' : 'none';
        }
    }
}

function UpdateGameModeSelect(data) {
    if (data.gamemode) {
        if (data.gamemode === "pvp") {
            // Update the gamemode list player count
            const pvpSpan = document.getElementById('pvp-mode');
            if (pvpSpan && data.players) {
                pvpSpan.textContent = `${data.players}/300`;
            }
            
            // Update the server list player count
            const serverPlayersSpan = document.querySelector('.type-gamemode-list .players');
            if (serverPlayersSpan && data.players) {
                serverPlayersSpan.textContent = `${data.players}/300`;
            }
        }
    }
}

function OpenServerList(gamemode, desc, players, country) {
    // Cache la liste des gamemodes
    document.querySelector('.gamemode-list').style.display = 'none';
    
    // Affiche la liste des serveurs
    document.querySelector('.type-gamemode-list').style.display = 'block';
    
    // Ajoute le bouton retour dans windows-title
    const windowsTitle = document.querySelector('.windows-title');
    windowsTitle.innerHTML = `
        <div class="return-button">
            <svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="circle-arrow-left" class="svg-inline--fa fa-circle-arrow-left" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                <path fill="currentColor" d="M512 256A256 256 0 1 0 0 256a256 256 0 1 0 512 0zM231 127c9.4-9.4 24.6-9.4 33.9 0s9.4 24.6 0 33.9l-71 71L376 232c13.3 0 24 10.7 24 24s-10.7 24-24 24l-182.1 0 71 71c9.4 9.4 9.4 24.6 0 33.9s-24.6 9.4-33.9 0L119 273c-9.4-9.4-9.4-24.6 0-33.9L231 127z"></path>
            </svg>
        </div>
        <span class="title">Gamemode</span>
    `;
    
    // Ajoute le serveur à la liste
    const lobbyList = document.querySelector('.type-gamemode-list');
    lobbyList.innerHTML = `
        <div class="list-gamemode-item server" onclick="ConnectedServer('${gamemode}')">
            <img src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${country}.svg" style="display: inline-block; width: 2em; height: 2em; vertical-align: middle;">
            <span class="gamemode-name">${gamemode}</span>
            <div class="gamemopde-desc-server">${desc}</div>
            <div class="players-serverlist">
                <span class="players">0/${players}</span>
            </div>
        </div>
    `;
    
    // Ajoute l'événement de retour sur le bouton
    document.querySelector('.return-button').addEventListener('click', () => {
        document.querySelector('.gamemode-list').style.display = 'block';
        document.querySelector('.type-gamemode-list').style.display = 'none';
        windowsTitle.innerHTML = '<span class="title">Gamemode</span>';
    });
}

function ConnectedServer(gamemode) {
    $.post("https://gamemode/connectGame", JSON.stringify({ gamemode: gamemode }));
}
