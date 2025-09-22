let isHost = false;
let selectedMap = '';
let selectedTime = null;
let players = [
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
    {
        username: 'John Doe',
        uuid: '1234567890'
    },
];
let invites = [];
let isGameCreated = false;


// Configuration
const maps = [
    'Arena 1',
    'Arena 2',
    'Arena 3',
    'Desert',
    'Forest'
];

window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'showHostMenu':
            $('.host-menu').show();
            break;

        case 'hideHostMenu':
            $('.host-menu').hide();
            break;
        
        case 'sendPlayerList': 
            players = data.players || [];
            renderPlayerList();
            break;

        case 'updateUI':
            if (data.isHost !== undefined) {
                isHost = data.isHost;
                renderPlayerList();
            }
            if (data.invites) {
                invites = data.invites;
                renderInvites();
            }
            break;

        case 'receiveInvite':
            invites.push(data.invite);
            renderInvites();
            break;

        case 'removeInvite':
            removeInvite(data.inviteId);
            break;

        case 'setMaps':
            if (data.maps && Array.isArray(data.maps)) {
                maps.length = 0;
                maps.push(...data.maps);
                if ($('.map-modal').is(':visible')) {
                    renderMapList();
                }
            }
            break;

        case 'gameCreated':
            isGameCreated = true;
            $('.btn-create').hide();
            $('.btn-start, .btn-stop').show();
            $('.map-btn, .time-btn').prop('disabled', true);
            break;
            
        case 'gameEnded':
            isGameCreated = false;
            $('.btn-create').show();
            $('.btn-start, .btn-stop').hide();
            $('.map-btn, .time-btn').prop('disabled', false);
            selectedMap = '';
            selectedTime = null;
            $('.selected-map').text('No map selected');
            $('.time-btn').removeClass('active');
            break;
    }
});

// Host Menu Toggle
function toggleHostMenu() {
    $('.host-menu').toggle();
}

// Initialize
$(document).ready(function() {
    // Hide start/stop buttons initially
    $('.btn-start, .btn-stop').hide();
    
    // Add create game button
    $('.create-options').append(`
        <div class="host-controls">
            <button class="host-btn btn-create">
                <i class="fa-solid fa-plus"></i>
                Create Game
            </button>
        </div>
    `);

    // Category Switching
    $('.category-btn').on('click', function() {
        $('.category-btn').removeClass('active');
        $(this).addClass('active');
        
        const category = $(this).data('category');
        $('.content-section').removeClass('active');
        $(`.${category}-section`).addClass('active');
    });

    // Map Selection
    $('.map-btn').on('click', function() {
        $('.map-modal').show();
        renderMapList();
    });

    // Map Modal Controls
    $('.btn-confirm').on('click', function() {
        if (selectedMap) {
            $('.selected-map').text(selectedMap);
        }
        $('.map-modal').hide();
    });

    $('.btn-cancel').on('click', function() {
        $('.map-modal').hide();
    });

    // Time Selection
    $('.time-btn').on('click', function() {
        $('.time-btn').removeClass('active');
        $(this).addClass('active');
        selectedTime = $(this).data('time');
    });

    // Create Game Button
    $(document).on('click', '.btn-create', function() {
        if (!selectedMap || !selectedTime) {
            // TODO: Show error message
            alert('Please select a map and time before creating the game');
            return;
        }
        
        fetch(`https://${GetParentResourceName()}/createGame`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                map: selectedMap,
                time: selectedTime
            })
        });

        isGameCreated = true;
        $(this).hide();
        $('.btn-start, .btn-stop').show();
        // Disable map and time selection after creation
        $('.map-btn, .time-btn').prop('disabled', true);
    });

    // Host Controls
    $('.btn-start').on('click', function() {
        if (!isGameCreated) {
            return;
        }
        
        fetch(`https://${GetParentResourceName()}/startGame`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                map: selectedMap,
                time: selectedTime
            })
        });
    });

    $('.btn-stop').on('click', function() {
        fetch(`https://${GetParentResourceName()}/stopGame`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
    });

    $('.btn-invite').on('click', function() {
        fetch(`https://${GetParentResourceName()}/showPlayerList`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
    });

    // Initial renders
    renderPlayerList();
    renderInvites();
});

// Player List Management
function renderPlayerList() {
    const playerList = $('.player-list');
    playerList.empty();
    
    players.forEach(player => {
        const playerItem = $('<div>').addClass('player-item');
        playerItem.append($('<span>').text(player.username));
        
        if (isHost) {
            const kickBtn = $('<button>')
                .addClass('btn-kick')
                .text('Kick')
                .click(() => kickPlayer(player.uuid));
            playerItem.append(kickBtn);
        }
        
        playerList.append(playerItem);
    });
}

function kickPlayer(playerId) {
    fetch(`https://${GetParentResourceName()}/kickPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            playerId: playerId
        })
    });
}

// Invite Management
function renderInvites() {
    const inviteList = $('.invite-list');
    inviteList.empty();
    
    invites.forEach(invite => {
        const inviteItem = $('<div>').addClass('invite-item');
        inviteItem.append($('<span>').addClass('invite-player').text(invite.username));
        
        const actions = $('<div>').addClass('invite-actions');
        actions.append(
            $('<button>')
                .addClass('btn-accept')
                .text('Accept')
                .click(() => acceptInvite(invite.id))
        );
        actions.append(
            $('<button>')
                .addClass('btn-decline')
                .text('Decline')
                .click(() => declineInvite(invite.id))
        );
        
        inviteItem.append(actions);
        inviteList.append(inviteItem);
    });
}

function acceptInvite(inviteId) {
    fetch(`https://${GetParentResourceName()}/acceptInvite`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            inviteId: inviteId
        })
    });
    removeInvite(inviteId);
}

function declineInvite(inviteId) {
    fetch(`https://${GetParentResourceName()}/declineInvite`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            inviteId: inviteId
        })
    });
    removeInvite(inviteId);
}

function removeInvite(inviteId) {
    invites = invites.filter(invite => invite.id !== inviteId);
    renderInvites();
}

// Add keyboard event handling
document.addEventListener('keyup', function(event) {
    // ESC key (27) or DELETE key (46)
    if (event.keyCode === 27 || event.keyCode === 46) {
        if ($('.host-menu').is(':visible')) {
            $('.host-menu').hide();
            fetch(`https://${GetParentResourceName()}/closeMenu`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        }
    }
});

function renderMapList() {
    const mapList = $('.map-list');
    mapList.empty();
    
    maps.forEach(map => {
        const mapItem = $('<div>')
            .addClass('map-item')
            .text(map)
            .on('click', function() {
                $('.map-item').removeClass('selected');
                $(this).addClass('selected');
                selectedMap = map;
            });
            
        if (map === selectedMap) {
            mapItem.addClass('selected');
        }
        
        mapList.append(mapItem);
    });
}
