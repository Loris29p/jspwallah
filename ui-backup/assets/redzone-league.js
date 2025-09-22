// Teams data imported from League.ListEquipe in sh_league.lua 
// The original teamNames array is kept for reference
const teamNames = [
    "Apex Predators", "Shadow Wolves", "Phoenix Rising", "Crimson Tide", "Midnight Raiders",
    "Steel Panthers", "Thunder Lords", "Dragon Slayers", "Savage Kings", "Viper Squad",
    "Iron Giants", "Mystic Hunters", "Storm Breakers", "Silent Assassins", "Night Stalkers",
    "Ghost Protocol", "Blazing Eagles", "Diamond Dogs", "Royal Knights", "Elite Guardians",
    "Quantum Force", "Wolf Pack", "Rogue Warriors", "Hell Hounds", "Golden Lions",
    "Cobra Strike", "Chaos Legion", "Death Dealers", "Dark Angels", "Lethal Vengeance",
    "Toxic Avengers", "Phantom Raiders", "Raging Bulls", "Blood Hunters", "Electric Shadows",
    "Frost Giants", "Solar Flares", "Crimson Reapers", "Alpha Omega"
];

// Array to store team data
let teams = [];

// Current player info
let currentPlayer = {
    name: "Player",
    uuid: "12345678",
    team: null // Added team tracking
};

// Add a lock to prevent rapid successive actions
let actionLock = false;
const LOCK_DURATION = 1000; // 1 second lock

// Initialize the league interface with data from the server
function initLeague(serverTeams) {
    // Add CSS file if it doesn't exist
    if (!document.querySelector('link[href="./assets/league.css"]')) {
        const link = document.createElement('link');
        link.href = './assets/league.css';
        link.rel = 'stylesheet';
        link.type = 'text/css';
        document.head.appendChild(link);
    }
    
    // Add transition styles if they don't exist
    if (!document.getElementById('league-transitions')) {
        const style = document.createElement('style');
        style.id = 'league-transitions';
        style.textContent = `
            .team-box {
                transition: all 0.3s ease-in-out;
                opacity: 1;
            }
            .team-box.fade-out {
                opacity: 0;
                transform: scale(0.9);
            }
            .player-entry, .empty-slot {
                transition: background-color 0.3s ease;
            }
            .team-count {
                transition: all 0.2s ease;
            }
        `;
        document.head.appendChild(style);
    }
    
    // Use server teams data if provided, otherwise generate random teams
    if (serverTeams) {
        importTeamsFromServer(serverTeams);
    } else {
        generateTeams(30);
    }
    
    // Render the league UI
    renderLeagueUI();
    
    // Show the league container
    document.querySelector('.league-container').style.display = 'flex';
    
}

// Import teams data from server (from League.ListEquipe in sh_league.lua)
function importTeamsFromServer(serverTeams) {
    teams = [];
    
    // Log received data for debugging
    
    // Convert the server teams data to our format
    // Use a counter to ensure client IDs start at 1
    let clientIdCounter = 1;
    
    Object.entries(serverTeams).forEach(([teamId, teamData]) => {
        // Get server ID (original ID from server)
        const serverId = parseInt(teamId);
        
        // Use our counter for client-side ID
        const clientId = clientIdCounter++;
        
        // Convert color2 object to CSS color class
        const colorCode = teamData.color?.replace("^#", "") || "03FFAF";
        
        // Convert players array to our format - check if it exists and has the right properties
        let formattedPlayers = [];
        if (teamData.players && Array.isArray(teamData.players)) {
            formattedPlayers = teamData.players.map(player => ({
                name: player.username || player.name || "Player",
                uuid: player.uuid,
                src: player.src
            }));
        }
        
        // Log the team's players with both IDs for debugging
        
        teams.push({
            id: clientId, // Use our client-side counter ID starting at 1
            serverId: clientId, // Keep original server ID for communication
            name: teamData.name,
            type: serverTeams.type || "solo", // Get type from global settings or default to solo
            maxPlayers: teamData.sizeEquipe || 1,
            players: formattedPlayers,
            colorHex: "#" + colorCode,
            colorClass: `team-color-${clientId}`, // Use client ID for CSS
            color2: teamData.color2
        });
    });
    
    // Log the teams array after processing
}

// Original generate random teams function (kept for fallback)
function generateTeams(count) {
    teams = [];
    for (let i = 0; i < count; i++) {
        // Randomly select a team type
        const teamTypes = ['solo', 'duo', 'trio'];
        const randomType = teamTypes[Math.floor(Math.random() * teamTypes.length)];
        
        // Get max players based on team type
        const maxPlayers = randomType === 'solo' ? 1 : (randomType === 'duo' ? 2 : 3);
        
        // Generate random color
        const colorIndex = Math.floor(Math.random() * 10) + 1;
        
        const teamId = i + 1;
        teams.push({
            id: teamId,
            serverId: teamId, // Pour générer des équipes locales, l'ID client = ID serveur
            name: teamNames[Math.floor(Math.random() * teamNames.length)],
            type: randomType,
            maxPlayers: maxPlayers,
            players: [],
            colorClass: `color-random-${colorIndex}`
        });
    }
}

// Render the league UI
function renderLeagueUI() {
    const leagueContainer = document.querySelector('.league-container');
    leagueContainer.innerHTML = '';
    
    // Create header
    const header = document.createElement('div');
    header.className = 'league-header';
    header.innerHTML = `
        <div>
            <div class="league-title">Team Selection</div>
            <div class="league-subtitle">Choose a team to join</div>
        </div>
    `;
    leagueContainer.appendChild(header);
    
    // Create teams grid
    const teamsGrid = document.createElement('div');
    teamsGrid.className = 'teams-grid';
    
    // Add team boxes to the grid
    teams.forEach(team => {
        const teamBox = createTeamBox(team);
        teamsGrid.appendChild(teamBox);
    });
    
    leagueContainer.appendChild(teamsGrid);
    
    // Add custom team colors
    addTeamColorStyles();
}

// Add dynamic style for team colors
function addTeamColorStyles() {
    // Remove existing style if present
    const existingStyle = document.getElementById('team-colors-style');
    if (existingStyle) {
        existingStyle.remove();
    }
    
    // Create style element
    const style = document.createElement('style');
    style.id = 'team-colors-style';
    
    // Generate CSS for each team color
    let css = '';
    teams.forEach(team => {
        if (team.colorHex) {
            css += `.${team.colorClass} { background-color: ${team.colorHex}30; border-color: ${team.colorHex}; }\n`;
            css += `.${team.colorClass} .team-header { background-color: ${team.colorHex}; }\n`;
        } else if (team.color2) {
            const rgbaColor = `rgba(${team.color2.r}, ${team.color2.g}, ${team.color2.b}, 0.3)`;
            const borderColor = `rgb(${team.color2.r}, ${team.color2.g}, ${team.color2.b})`;
            css += `.${team.colorClass} { background-color: ${rgbaColor}; border-color: ${borderColor}; }\n`;
            css += `.${team.colorClass} .team-header { background-color: ${borderColor}; }\n`;
        }
    });
    
    style.textContent = css;
    document.head.appendChild(style);
}

// Create a team box element
function createTeamBox(team) {
    const teamBox = document.createElement('div');
    teamBox.className = `team-box team-${team.type} ${team.colorClass}`;
    teamBox.id = `team-${team.id}`;
    teamBox.setAttribute('data-team-id', team.id);
    
    // Check if player is already in this team
    const isPlayerInTeam = team.players.some(player => player.uuid === currentPlayer.uuid);
    if (isPlayerInTeam) {
        teamBox.classList.add('player-team');
    }
    
    // Create team header
    const teamHeader = document.createElement('div');
    teamHeader.className = 'team-header';
    teamHeader.innerHTML = `
        <div class="team-name">${team.name}</div>
        <div class="team-count">${team.players.length}/${team.maxPlayers}</div>
    `;
    
    // Create team type label
    const teamType = document.createElement('div');
    teamType.className = 'team-type';
    teamType.textContent = team.type.charAt(0).toUpperCase() + team.type.slice(1);
    
    // Create players section
    const teamPlayers = document.createElement('div');
    teamPlayers.className = 'team-players';
    
    // Add existing players
    team.players.forEach(player => {
        const playerEntry = document.createElement('div');
        playerEntry.className = 'player-entry';
        // Highlight current player
        if (player.uuid === currentPlayer.uuid) {
            playerEntry.classList.add('current-player');
        }
        playerEntry.innerHTML = `
            <div class="player-name">${player.name || player.username}</div>
            <div class="player-uuid">${player.uuid}</div>
        `;
        teamPlayers.appendChild(playerEntry);
    });
    
    // Add empty slots
    for (let i = team.players.length; i < team.maxPlayers; i++) {
        const emptySlot = document.createElement('div');
        emptySlot.className = 'empty-slot';
        emptySlot.textContent = 'Empty Slot';
        teamPlayers.appendChild(emptySlot);
    }
    
    // Create button text and state based on player's status
    let buttonText = isPlayerInTeam ? 'Leave Team' : 'Join Team';
    let buttonDisabled = !isPlayerInTeam && team.players.length >= team.maxPlayers;
    
    // Create join/leave button
    const actionButton = document.createElement('button');
    actionButton.className = 'join-team-btn';
    actionButton.textContent = buttonText;
    actionButton.disabled = buttonDisabled;
    
    if (actionButton.disabled) {
        actionButton.style.opacity = '0.5';
        actionButton.style.cursor = 'not-allowed';
    }
    
    // Add event listener to button
    actionButton.addEventListener('click', (e) => {
        e.stopPropagation();
        // Get current state as it may have changed
        const currentIsPlayerInTeam = team.players.some(player => player.uuid === currentPlayer.uuid);
        if (currentIsPlayerInTeam) {
            leaveTeam(team.id);
        } else if (team.players.length < team.maxPlayers) {
            joinTeam(team.id);
        }
    });
    
    // Add elements to team box
    teamBox.appendChild(teamHeader);
    teamBox.appendChild(teamType);
    teamBox.appendChild(teamPlayers);
    teamBox.appendChild(actionButton);
    
    // Add click event to the entire box
    teamBox.addEventListener('click', () => {
        // Get current state as it may have changed
        const currentIsPlayerInTeam = team.players.some(player => player.uuid === currentPlayer.uuid);
        if (currentIsPlayerInTeam) {
            leaveTeam(team.id);
        } else if (team.players.length < team.maxPlayers) {
            joinTeam(team.id);
        }
    });
    
    return teamBox;
}

// Add a new function to update the team boxes without full redraw
function updateLeagueUI() {
    // Check if team boxes already exist
    const teamBoxes = document.querySelectorAll('.team-box');
    
    // If no team boxes exist, do a full render
    if (teamBoxes.length === 0) {
        renderLeagueUI();
        return;
    }
    
    
    // First, update team colors
    addTeamColorStyles();
    
    // Create a map of existing team boxes by ID
    const existingBoxes = {};
    teamBoxes.forEach(box => {
        const teamId = parseInt(box.getAttribute('data-team-id'));
        existingBoxes[teamId] = box;
    });
    
    // Get reference to the teams grid
    const teamsGrid = document.querySelector('.teams-grid');
    if (!teamsGrid) {
        // If teams grid doesn't exist, do a full render
        renderLeagueUI();
        return;
    }
    
    // Process each team
    teams.forEach(team => {
        const existingBox = existingBoxes[team.id];
        
        if (existingBox) {
            // Update existing team box
            updateTeamBox(existingBox, team);
            delete existingBoxes[team.id]; // Remove from map to track remaining
        } else {
            // Create and add new team box
            const newBox = createTeamBox(team);
            teamsGrid.appendChild(newBox);
        }
    });
    
    // Remove boxes for teams that no longer exist
    Object.values(existingBoxes).forEach(box => {
        box.classList.add('fade-out');
        setTimeout(() => {
            if (box.parentNode) {
                box.parentNode.removeChild(box);
            }
        }, 300); // Fade out for 300ms before removing
    });
}

// Function to update an existing team box
function updateTeamBox(teamBox, team) {
    // Check if player is in this team for styling
    const isPlayerInTeam = team.players.some(player => player.uuid === currentPlayer.uuid);
    
    // Update class names (type and player status)
    teamBox.className = `team-box team-${team.type} ${team.colorClass}`;
    if (isPlayerInTeam) {
        teamBox.classList.add('player-team');
    } else {
        teamBox.classList.remove('player-team');
    }
    
    // Update header content
    const headerEl = teamBox.querySelector('.team-header');
    if (headerEl) {
        headerEl.innerHTML = `
            <div class="team-name">${team.name}</div>
            <div class="team-count">${team.players.length}/${team.maxPlayers}</div>
        `;
    }
    
    // Update team type
    const typeEl = teamBox.querySelector('.team-type');
    if (typeEl) {
        typeEl.textContent = team.type.charAt(0).toUpperCase() + team.type.slice(1);
    }
    
    // Update players section
    const playersEl = teamBox.querySelector('.team-players');
    if (playersEl) {
        playersEl.innerHTML = ''; // Clear current players
        
        // Add existing players
        team.players.forEach(player => {
            const playerEntry = document.createElement('div');
            playerEntry.className = 'player-entry';
            // Highlight current player
            if (player.uuid === currentPlayer.uuid) {
                playerEntry.classList.add('current-player');
            }
            playerEntry.innerHTML = `
                <div class="player-name">${player.name || player.username}</div>
                <div class="player-uuid">${player.uuid}</div>
            `;
            playersEl.appendChild(playerEntry);
        });
        
        // Add empty slots
        for (let i = team.players.length; i < team.maxPlayers; i++) {
            const emptySlot = document.createElement('div');
            emptySlot.className = 'empty-slot';
            emptySlot.textContent = 'Empty Slot';
            playersEl.appendChild(emptySlot);
        }
    }
    
    // Update button text
    const buttonEl = teamBox.querySelector('.join-team-btn');
    if (buttonEl) {
        buttonEl.textContent = isPlayerInTeam ? 'Leave Team' : 'Join Team';
        const buttonDisabled = !isPlayerInTeam && team.players.length >= team.maxPlayers;
        buttonEl.disabled = buttonDisabled;
        
        if (buttonDisabled) {
            buttonEl.style.opacity = '0.5';
            buttonEl.style.cursor = 'not-allowed';
        } else {
            buttonEl.style.opacity = '1';
            buttonEl.style.cursor = 'pointer';
        }
        
        // Update button click handler
        buttonEl.onclick = (e) => {
            e.stopPropagation();
            const currentIsPlayerInTeam = team.players.some(player => player.uuid === currentPlayer.uuid);
            if (currentIsPlayerInTeam) {
                leaveTeam(team.id);
            } else if (team.players.length < team.maxPlayers) {
                joinTeam(team.id);
            }
        };
    }
    
    // Update box click handler
    teamBox.onclick = () => {
        const currentIsPlayerInTeam = team.players.some(player => player.uuid === currentPlayer.uuid);
        if (currentIsPlayerInTeam) {
            leaveTeam(team.id);
        } else if (team.players.length < team.maxPlayers) {
            joinTeam(team.id);
        }
    };
}

// Join a team
function joinTeam(teamId) {
    // Prevent rapid actions
    if (actionLock) {
        return;
    }
    
    // Find the team
    const team = teams.find(t => t.id === teamId);
    
    if (!team) {
        return;
    }
    
    // Vérifier d'abord si l'équipe est pleine
    if (team.players.length >= team.maxPlayers) {
        return;
    }
    
    // Check if player is already in this team - if so, don't do anything
    const isAlreadyInTeam = team.players.some(player => player.uuid === currentPlayer.uuid);
    if (isAlreadyInTeam) {
        return;
    }
    
    // Set action lock
    actionLock = true;
    setTimeout(() => { actionLock = false; }, LOCK_DURATION);
    
    // Check if player is already in another team
    const currentTeam = findPlayerTeam();
    if (currentTeam) {
        leaveTeam(currentTeam.id, false); // Pass false to not trigger server event when just switching teams
    }
    
    // Add player to team locally for immediate feedback
    team.players.push({...currentPlayer});
    currentPlayer.team = team.id;
    
    // Log the join
    
    // Trigger server-side event - Use the stored serverId
    $.post("https://gamemode/league:joinTeam", JSON.stringify({
        teamId: team.serverId,
    }));
    
    // Update UI smoothly
    updateLeagueUI();
}

// Leave a team
function leaveTeam(teamId, shouldNotifyServer = true) {
    // Only check lock if this is a user-initiated leave (not a team switch)
    if (shouldNotifyServer && actionLock) {
        return;
    }
    
    // Find the team
    const team = teams.find(t => t.id === teamId);
    
    if (!team) {
        console.error(`Team with ID ${teamId} not found`);
        return;
    }
    
    // Find the player in the team
    const playerIndex = team.players.findIndex(p => p.uuid === currentPlayer.uuid);
    
    if (playerIndex === -1) {
        return;
    }
    
    // Set action lock if this is a user-initiated leave
    if (shouldNotifyServer) {
        actionLock = true;
        setTimeout(() => { actionLock = false; }, LOCK_DURATION);
    }
    
    // Remove player from team locally for immediate feedback
    team.players.splice(playerIndex, 1);
    currentPlayer.team = null;
    
    // Log the leave
    
    // Trigger server-side event only if needed
    if (shouldNotifyServer) {
        $.post("https://gamemode/league:leaveTeam", JSON.stringify({
            teamId: team.serverId,
        }));
    }
    
    // Update UI smoothly
    updateLeagueUI();
}

// Find which team the player is currently in
function findPlayerTeam() {
    return teams.find(team => 
        team.players.some(player => player.uuid === currentPlayer.uuid)
    );
}

// Function to set player info
function setCurrentPlayer(name, uuid) {
    currentPlayer.name = name;
    currentPlayer.uuid = uuid;
}

// Function to toggle the league interface
function toggleLeagueUI() {
    const leagueContainer = document.querySelector('.league-container');
    if (leagueContainer.style.display === 'none') {
        leagueContainer.style.display = 'flex';
    } else {
        leagueContainer.style.display = 'none';
    }
}

// Update teams with server data
function updateTeams(teamData) {
    if (Array.isArray(teamData)) {
        // Update with array of player data
        teamData.forEach(player => {
            if (!player.team) return;
            
            // Find target team
            const team = teams.find(t => t.name === player.team);
            if (!team) return;
            
            // Add player to team if not already there
            const existingPlayer = team.players.find(p => p.uuid === player.uuid);
            if (!existingPlayer) {
                team.players.push({
                    name: player.username,
                    uuid: player.uuid
                });
            }
        });
    } else if (typeof teamData === 'object') {
        // Single player update
        if (!teamData.team) return;
        
        // Find target team
        const team = teams.find(t => t.name === teamData.team);
        if (!team) return;
        
        // Add player to team
        const existingPlayer = team.players.find(p => p.uuid === teamData.uuid);
        if (!existingPlayer) {
            team.players.push({
                name: teamData.username,
                uuid: teamData.uuid
            });
        }
    }
    
    // Update UI smoothly
    updateLeagueUI();
}

// Test function to simulate clicking on a random team
function testJoinRandomTeam() {
    // Find teams that aren't full
    const availableTeams = teams.filter(team => team.players.length < team.maxPlayers);
    
    if (availableTeams.length > 0) {
        // Select a random available team
        const randomTeam = availableTeams[Math.floor(Math.random() * availableTeams.length)];
        joinTeam(randomTeam.id);
    } else {
    }
}

// Function to refresh the league UI with updated server data
function refreshLeagueUI(serverTeams, playerData) {
    
    // Store current player team information before refresh
    const wasInTeam = currentPlayer.team;
    
    // Update player info if provided
    if (playerData) {
        setCurrentPlayer(playerData.name, playerData.uuid);
    }
    
    // Re-import teams data
    if (serverTeams) {
        // Store current UI state for reference
        const containerVisible = document.querySelector('.league-container').style.display !== 'none';
        
        // Import new data
        importTeamsFromServer(serverTeams);
        
        // Re-establish the player's team status based on server data
        if (currentPlayer && currentPlayer.uuid) {
            // Find if the player is in any team in the new data
            let foundInTeam = false;
            for (const team of teams) {
                if (team.players.some(p => p.uuid === currentPlayer.uuid)) {
                    currentPlayer.team = team.id;
                    foundInTeam = true;
                    break;
                }
            }
            
            // If player was in a team but now isn't, clear team status
            if (!foundInTeam && wasInTeam) {
                currentPlayer.team = null;
            }
        }
        
        // Update UI smoothly if it's visible
        if (containerVisible) {
            updateLeagueUI();
        }
    }
}

// Initialize when document is ready
document.addEventListener('DOMContentLoaded', () => {
    // Check if league container exists, if not create it
    let leagueContainer = document.querySelector('.league-container');
    
    if (!leagueContainer) {
        leagueContainer = document.createElement('div');
        leagueContainer.className = 'league-container';
        leagueContainer.style.display = 'none';
        document.body.appendChild(leagueContainer);
    }
    
    // Register global functions for FiveM integration
    window.showLeagueUI = initLeague;
    window.hideLeagueUI = () => {
        document.querySelector('.league-container').style.display = 'none';
    };
    window.testTeamJoin = testJoinRandomTeam;
    window.updateTeams = updateTeams;
    window.setCurrentPlayer = setCurrentPlayer;
    
    // Listen for NUI messages from FiveM client
    window.addEventListener('message', (event) => {
        const data = event.data;
        
        if (data.type === 'openPanelLeague') {
            // Set current player if provided
            if (data.player) {
                setCurrentPlayer(data.player.name, data.player.uuid);
            }
            
            // Initialize with server teams data if provided
            initLeague(data.teams);
        } else if (data.type === 'closePanelLeague') {
            window.hideLeagueUI();
        } else if (data.type === 'updateTeams') {
            updateTeams(data.teamData);
        } else if (data.type === 'refreshLeague') {
            // Refresh the league UI with updated data
            refreshLeagueUI(data.teams, data.player);
        }
    });
});

$(document).on("keyup", function (e) {
    if (e.key === "Escape") {
        $.post("https://gamemode/closePanelLeague", JSON.stringify({}));
    }
});