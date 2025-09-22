OtherInventoryType = null
ShiftPressed = false
ControlPressed = false
// PlayerMaxWeight = 40
// OtherMaxWeight = 25
PlayerMaxWeight = 1000000000000
OtherMaxWeight = 1000000000000
PlayerWeight = 0
OtherWeight = 0
var combatmode = false;
var DisableInventoryMove = false;


var normalinventoryitem = {};


function formatNumberWithCommas(number) {
  if (!number) return 0;
  return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

var firstLoadLeaderboard = false;


window.addEventListener('message', function(e) {
    const data = e.data;
    if (data.type == "display") {
        Display(data)
        if (!firstLoadLeaderboard) {
            firstLoadLeaderboard = true;
            SelectLeaderboard("player");
        }
    } else if (data.type == "stats") {
        // console.log(data.playerData.username);
        LoadProfilePlayer(data.playerData);
    } else if (data.type == "crew-stats") {
        SetLeaderboardCrew(data.crewData, "crew-killed", data.podium);
    } else if (data.type == "leaderboard") {
        SetPodiumLeaderbard(data.podium, "player-killed");
        SetLeaderboard(data.leaderboard, "player-killed");
    }  else if (data.type == "importItemTbl") {
        $.each(data.tbl, function (k, v) {
            normalinventoryitem[k] = v;
        });
        // console.log("All items successfully loaded! [Total Items:" + Object.keys(normalinventoryitem).length + ']');
    } else if (data.type == "hotbar") {
        LoadHotbar(data.hotbar);
    } else if (data.type == "side") {
        DisplaySide(data);
    } else if (data.type == "show-peds") {
        $(".ui-body").show();
        ChangePages("shop");
        ChangeDonatorPages('myskins')
    } else if (data.type == "updateinventory") {
        LoadInventory(data.inventory);
        LoadSafeInventory(data.safeinventory, "protected");
    } else if (data.type == "updatecombatmode") {
        console.log("COMBATMODE", data.combatmode);
        if (data.combatmode == true) {
            combatmode = true;
        } else { 
            combatmode = false;
        }
    } else if (data.type == "cc") {
        DisableInventoryMove = data.movestatus;
    } else if (data.type == "updateWeight") {
      if (data.weights) {
        document.querySelector('#weightProtected .current').textContent = `${data.weights.otherInventoryWeight}kg`;
        document.querySelector('#weightProtected .max').textContent = `${data.weights.maxSafeWeight}kg`;
      
        PlayerMaxWeight = data.weights.maxInvWeight;
        OtherMaxWeight = data.weights.maxSafeWeight;
        PlayerWeight = data.weights.inventoryWeight;
        OtherWeight = data.weights.otherInventoryWeight;

        /* my bag weight */
        document.querySelector('.inventory-container.transparent .weight .current').textContent = `${data.weights.inventoryWeight}kg`;
        document.querySelector('.inventory-container.transparent .weight .max').textContent = `${data.weights.maxInvWeight}kg`;
      }
    }
});

function updateUserInfo(pseudo, uuid, tokens, weightData) {
    document.querySelector('.profil .name > span:first-child').textContent = pseudo;
    document.querySelector('.profil .name .color-7').textContent = `(${uuid})`;
    const tokensElement = formatNumberWithCommas(tokens);
    document.querySelector('.profil .info').textContent = `${tokensElement} Tokens`;

    if (!weightData) return;
    if (!weightData.otherInventoryWeight) return;
    if (!weightData.maxSafeWeight) return;
    if (!weightData.inventoryWeight) return;
    if (!weightData.maxInvWeight) return;
    /* protected weight */
    document.querySelector('#weightProtected .current').textContent = `${weightData.otherInventoryWeight}kg`;
    document.querySelector('#weightProtected .max').textContent = `${weightData.maxSafeWeight}kg`;

    PlayerMaxWeight = weightData.maxInvWeight;
    OtherMaxWeight = weightData.maxSafeWeight;
    PlayerWeight = weightData.inventoryWeight;
    OtherWeight = weightData.otherInventoryWeight;

    /* my bag weight */
    document.querySelector('.inventory-container.transparent .weight .current').textContent = `${weightData.inventoryWeight}kg`;
    document.querySelector('.inventory-container.transparent .weight .max').textContent = `${weightData.maxInvWeight}kg`;

}

LoadHotbar = hotbar => {
  $(".inventory-wrapper.inventory.shortcut > .items-container > .item-slot").remove();
  for (let i = 0; i < 7; i++) {
    const v = hotbar[i];
    const content = `
      <div class="item-slot">
        <span class="item-info">${i + 1}</span>
        <div class="icon-container">
          <img class="icon" ${v && v.name && v.hasItem ? `src="assets/items/${v.name}.png"` : ''}>
        </div>
        <div class="details-container">
          
        </div>
      </div>
    `;
    $(".inventory-wrapper.inventory.shortcut > .items-container").append(content);
  }
}

var DraggingData = null; 
function handleDragDrop() {


  $(".inventory-wrapper.inventory.shortcut > .items-container > .item-slot").droppable({
    hoverClass: 'item-slot-hoverClass',
    drop: function(event, ui) {
      $.post("https://gamemode/SetHotbar", JSON.stringify({ id: $(this).data("id"), itemName: DraggingData["itemName"] }));
    }
  })
}

function FastSlot(name, hang) {
  LastData = {
    'itemName': name,
    'hangi': hang
  };
}

Display = data => {
    if (data.bool) {
        updateUserInfo(data.pseudo, data.uuid, data.tokens, data.inventoryInfo);
        SetCoinsShop(data.coins);
        LoadInventory(data.inventory);
        LoadSafeInventory(data.safeinventory, "protected");
        $(".ui-body").show();
        ChangePages("inventory");
        const element = document.querySelector('.ui-body');
        if (element) {
            element.style.display = 'flex';
        }
    } else {
        $(".ui-body").hide();
    }
}

DisplaySide = data => {
  if (data.bool) {
    // Assurons-nous que l'ID est correctement formaté
    if (data.id && !data.id.startsWith('container-') && !data.id.startsWith('bags-') && !data.id.startsWith('airdrop-')) {
      if (data.id.indexOf('-') === -1 && data.container) {
        data.id = 'container-' + data.id;
      }
    }

    LoadMyInventorySide(data.inventory, "inventory", data.id);
    if (data.container) {
      LoadContainerBag(data.container, "container", data.id);
    } else {
      LoadContainerBag(data.baginventory, "bag", data.id);
    }
    ChangePages('container');
    $(".ui-body").show();
    const element = document.querySelector('.ui-body');
    if (element) {
        element.style.display = 'flex';
    }
  } else {
    $(".ui-body").hide();
  }
}

function ChangePages(str) {
    // Remove 'selected' class from all navbar buttons
    const navbarButtons = document.querySelectorAll('.ui-navbar-button');
    navbarButtons.forEach(button => {
        button.classList.remove('selected');
    });
    
    // Add 'selected' class to the corresponding button based on the page
    if (str === 'inventory' || str === 'container') {
        const inventoryButton = document.querySelector('.ui-navbar-button:nth-child(1)');
        if (inventoryButton) inventoryButton.classList.add('selected');
    } else if (str === 'leaderboard') {
        const leaderboardButton = document.querySelector('.ui-navbar-button:nth-child(2)');
        if (leaderboardButton) leaderboardButton.classList.add('selected');
    } else if (str === 'shop-items') {
        const shopButton = document.querySelector('.ui-navbar-button:nth-child(3)');
        if (shopButton) shopButton.classList.add('selected');
    } else if (str === 'shop') {
        const myLockerButton = document.querySelector('.ui-navbar-button:nth-child(4)');
        if (myLockerButton) myLockerButton.classList.add('selected');
    }

    if (str == "inventory") {
        $(".inventory-container.transparent").css("display", "flex");
        $(".feedback-view").css("display", "none");
        $(".help-container").css("display", "none");
        $(".ui-profiles").css("display", "none");
        $(".ui-leaderboard").css("display", "none");
        $(".gamesettings").css("display", "none");
        $(".inventory-container.side").css("display", "none");
        $(".ui-boutique-rank").css("display", "none");
        $(".ui-shop").css("display", "none");
    } else if (str == "container") {
        $(".inventory-container.side").css("display", "flex");
        $(".inventory-container.transparent").css("display", "none");
        $(".feedback-view").css("display", "none");
        $(".help-container").css("display", "none");
        $(".ui-profiles").css("display", "none");
        $(".ui-leaderboard").css("display", "none");
        $(".gamesettings").css("display", "none");
        $(".ui-boutique-rank").css("display", "none");
        $(".ui-shop").css("display", "none");

    } else if (str == "shop-items") {
        $(".inventory-container.side").css("display", "none");
        $(".inventory-container.transparent").css("display", "none");
        $(".feedback-view").css("display", "none");
        $(".help-container").css("display", "none");
        $(".ui-profiles").css("display", "none");
        $(".ui-leaderboard").css("display", "none");
        $(".gamesettings").css("display", "none");
        $(".ui-boutique-rank").css("display", "none");
        $(".ui-shop").css("display", "none");
        $.post("https://gamemode/openShop", JSON.stringify({}));

    } else if (str == "feedback") {
        $(".inventory-container.transparent").css("display", "none");
        $(".inventory-container.side").css("display", "none");
        $(".feedback-view").fadeIn(1);
        $(".help-container").css("display", "none");
        $(".ui-profiles").css("display", "none");
        $(".ui-leaderboard").css("display", "none");
        $(".ui-boutique-rank").css("display", "none");
        $(".ui-shop").css("display", "none");

    } else if (str == "help-main") {
        $(".inventory-container.transparent").css("display", "none");
        $(".inventory-container.side").css("display", "none");
        $(".feedback-view").css("display", "none");
        $(".help-container").css("display", "block");
        $(".ui-profiles").css("display", "none");
        $(".gamesettings").css("display", "none");
        $(".help-container").fadeIn(1); 
        $(".ui-leaderboard").css("display", "none");
        $(".ui-boutique-rank").css("display", "none");
        $(".ui-shop").css("display", "none");

        HelpLoad("tutorial");
    } else if (str == "profile") {
        $(".inventory-container.transparent").css("display", "none");
        $(".inventory-container.side").css("display", "none");
        $(".feedback-view").css("display", "none");
        $(".help-container").css("display", "none");
        $(".gamesettings").css("display", "none");
        $(".ui-leaderboard").css("display", "none");
        $(".ui-profiles").css("display", "none");
        $(".ui-boutique-rank").css("display", "none");
        $(".ui-shop").css("display", "none");
        $(".ui-profiles").fadeIn(1);

        LoadProfile2();
    } else if (str == "leaderboard") {
        $(".inventory-container.transparent").css("display", "none");
        $(".inventory-container.side").css("display", "none");
        $(".feedback-view").css("display", "none");
        $(".help-container").css("display", "none");
        $(".ui-profiles").css("display", "none");
        $(".gamesettings").css("display", "none");
        $(".ui-leaderboard").css("display", "flex");
        $(".ui-boutique-rank").css("display", "none");
        $(".ui-leaderboard").fadeIn(1);
        $(".ui-shop").css("display", "none");

    } else if (str == "settings") {
      $(".inventory-container.transparent").css("display", "none");
      $(".inventory-container.side").css("display", "none");
      $(".feedback-view").css("display", "none");
      $(".help-container").css("display", "none");
      $(".ui-profiles").css("display", "none");
      $(".ui-leaderboard").css("display", "none");
      $(".ui-boutique-rank").css("display", "none");
      $(".gamesettings").css("display", "flex");
      $(".ui-shop").css("display", "none");

      $(".gamesettings").fadeIn(1);
    } else if (str == "shop") {
      $(".inventory-container.transparent").css("display", "none");
      $(".inventory-container.side").css("display", "none");
      $(".feedback-view").css("display", "none");
      $(".help-container").css("display", "none");
      $(".ui-profiles").css("display", "none");
      $(".ui-leaderboard").css("display", "none");
      $(".gamesettings").css("display", "none");
      $(".ui-boutique-rank").css("display", "flex");
      $(".ui-shop").css("display", "none");

      ChangeDonatorPages('rank');
      $(".ui-boutique-rank").fadeIn(1);
    }  else if (str == "shop-weapon") {
      $(".inventory-container.transparent").css("display", "none");
      $(".inventory-container.side").css("display", "none");
      $(".feedback-view").css("display", "none");
      $(".help-container").css("display", "none");
      $(".ui-profiles").css("display", "none");
      $(".ui-leaderboard").css("display", "none");
      $(".gamesettings").css("display", "none");
      $(".ui-boutique-rank").css("display", "none");
      $(".ui-shop").css("display", "flex");

      $(".ui-shop").fadeIn(1);
    } else if (str === "market") {
      $(".ui-body").fadeOut(100);
      $.post("https://gamemode/openMarket", JSON.stringify({}));
    }
}


function togglePrimaryClass(activeId, inactiveId) {
    var activeElement = document.getElementById(activeId);
    var inactiveElement = document.getElementById(inactiveId);
    
    if (activeElement) {
        activeElement.classList.add('primary');
    }
    
    if (inactiveElement) {
        inactiveElement.classList.remove('primary');
    }
}

function SetPodiumLeaderbard(data, type) {
    if (type == "player-killed") { 
        $(".leaderboard-podium").empty();
        $.each(data, function(k, v) {
            if (v.avatar == "") {
                v.avatar = "./assets/default-avatar.jpg";
            }
            const content = `
            <div class="leaderboard-player">
                <div class="picture-profil">
                <img class="image" src="${v.avatar}">
                </div>
                <span class="rank">Top ${k+1}</span>
                <div class="player-info">
                <span class="player-name">
                    <span class="color" style="color: #8b8378"> ${v.username}</span>
                </span>
                
                </div>
                <div class="player-points">
                <span class="points">${v.kills}</span>
                <span class="points-label">Players killed</span>
                </div>
            </div>

            `
            $(".leaderboard-podium").append(content);
        });
    } else if (type == "player-death") {
        $(".leaderboard-podium").empty();
        $.each(data, function(k, v) {
            if (v.avatar == "") {
                v.avatar = "./assets/default-avatar.jpg";
            }
            const content = `
            <div class="leaderboard-player">
                <div class="picture-profil">
                <img class="image" src="${v.avatar}">
                </div>
                <span class="rank">Top ${k+1}</span>
                <div class="player-info">
                <span class="player-name">
                    <span class="color" style="color: #8b8378"> ${v.username}</span>
                </span>
                
                </div>
                <div class="player-points">
                <span class="points">${v.death}</span>
                <span class="points-label">Death</span>
                </div>
            </div>
            `
            $(".leaderboard-podium").append(content);
        });
    } else if (type == "player-token") {
        $(".leaderboard-podium").empty();
        $.each(data, function(k, v) {
            if (v.avatar == "") {
                v.avatar = "./assets/default-avatar.jpg";
            }
            const tokenVARIABLE = formatNumberWithCommas(v.token);
            const content = `
            <div class="leaderboard-player">
                <div class="picture-profil">
                <img class="image" src="${v.avatar}">
                </div>
                <span class="rank">Top ${k+1}</span>
                <div class="player-info">
                <span class="player-name">
                    <span class="color" style="color: #8b8378"> ${v.username}</span>
                </span>
                
                </div>
                <div class="player-points">
                <span class="points">${tokenVARIABLE}</span>
                <span class="points-label">Guild Token</span>
                </div>
            </div>
            `
            $(".leaderboard-podium").append(content);
        });
    }
}

function SelectLeaderboard(type) { 
    const buttons = document.querySelectorAll('.leaderboard-stats-buttons .ui-button');
    buttons.forEach(button => {
        button.classList.remove('selected');
    });
    const tableHeader = document.querySelector('.ui-table thead tr');
    
    if (type == "player") {
        const playerButton = document.querySelector('.leaderboard-stats-buttons .ui-button:nth-child(1)');
        if (playerButton) {
            playerButton.classList.add('selected');
            
            tableHeader.innerHTML = `
                <th class="rank-column">Rang</th>
                <th class="name-column">Nickname</th>
                <th class="total-column">Total</th>
                <th class="right-cell" style="text-align: right; padding-right: 3vh;">Country</th>
            `;
            
            $.post("https://gamemode/SelectLeaderboard", JSON.stringify({type: "player"}));
        }
    } else if (type == "crew") {
        const crewButton = document.querySelector('.leaderboard-stats-buttons .ui-button:nth-child(2)');
        if (crewButton) {
            crewButton.classList.add('selected');
            
            tableHeader.innerHTML = `
                <th class="rank-column">Rang</th>
                <th class="name-column">Nickname</th>
                <th class="total-column">Total</th>
                <th class="airdrop-column">Airdrop Taken</th>
                <th class="redzone-column">Redzone Kills</th>
                <th class="right-cell" style="text-align: right; padding-right: 3vh;">Country</th>
            `;
            
            $.post("https://gamemode/SelectLeaderboard", JSON.stringify({type: "crew"}));
        }
    }
}


function SetLeaderboardCrew(data, type, podium) {
    var tbody = document.querySelector('.ui-table tbody');
    $(".leaderboard-podium").empty();
    $.each(podium, function(k, v) {
        const avatarSrc = v.avatar || "./assets/default-avatar.jpg";
        const countryCode = v.country || "GB";
        const flagUrl = `https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${countryCode.toLowerCase()}.svg`;
        console.log(flagUrl, "FLAG URL")
        
        const content = `
        <div class="leaderboard-player">
            <div class="picture-profil">
                <img class="image" src="${flagUrl}" onerror="this.src='./assets/default-avatar.jpg';">
            </div>
            <span class="rank">Top ${k+1}</span>
            <div class="player-info">
                <span class="player-name">
                    <span class="color" style="color: #8b8378"> ${v.crewName}</span>
                </span>
            </div>
            <div class="player-points">
                <span class="points">${v.kills}</span>
                <span class="points-label">Players killed</span>
            </div>
        </div>
        `;
        $(".leaderboard-podium").append(content);
    });
    
    if (tbody) {
        tbody.innerHTML = '';
    }
    
    if (type == "crew-killed") {
        $.each(data, function(k, v) {
            const airdrops = v.airdrops || 0;
            const redzoneKills = v.redzoneKills || 0;
            const countryCode = v.country || "GB";
            const flagUrl = `https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${countryCode.toLowerCase()}.svg`;
            console.log(flagUrl, "FLAG URL")
            
            const content = `
            <tr>
                <td class="rank-column">#${k + 1}</td>
                <td class="name-column">
                    <div style="display: flex; flex-direction: row; align-items: center;">
                        <span class="leaderboard-name">
                            <span class="color" style="color: #8b8378"> ${v.crewName}</span>
                        </span>
                    </div>
                </td>
                <td class="total-column">${v.kills}</td>
                <td class="airdrop-column">${airdrops}</td>
                <td class="redzone-column">${redzoneKills}</td>
                <td class="right-cell" style="text-align: right; padding-right: 3vh;">
                    <img class="country-flag-cell" src="${flagUrl}" onerror="this.style.display='none'; this.parentNode.textContent='${countryCode}';" style="width: 24px; height: 18px;">
                </td>
                </tr>
            `;
            $(".ui-table tbody").append(content);
        });
    }
}

function SetLeaderboard(data, type) {
    var tbody = document.querySelector('.ui-table tbody');
            
    if (tbody) {
        tbody.innerHTML = '';
    }
    // outpout : [{"avatar":"","kills":0,"username":"E-SIM SPAM LA NL"}] (@gamemode/ui/assets/inventory.js:177) 
    if (type == "player-killed") {
        $.each(data, function(k, v) {
            const countryCode = v.country || "GB";
            const flagUrl = `https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${countryCode.toLowerCase()}.svg`;
            const content = `
            <tr>
                <td class="rank-column">#${k + 1}</td>
                <td class="name-column">
                    <div style="display: flex; flex-direction: row; align-items: center; padding-left: 8px;">
                    <div class="game-badge leaderboard-badge">
                        <img alt="" ${v && v.prestige > 0 ? `src="/ui/assets/badges/prestige_${v.prestige}.png" style="margin-left: 10px; margin-right: 8px;"` : ''}>
                    </div>
                    <span class="leaderboard-name">
                        <span class="color" style="color: #8b8378"> ${v.username}</span>
                    </span>
                    </div>
                </td>
                <td class="total-column">${v.kills}</td>
                <td class="right-cell" style="text-align: right; padding-right: 3vh;">
                    <img class="country-flag-cell" src="${flagUrl}" onerror="this.style.display='none'; this.parentNode.textContent='${countryCode}';" style="width: 24px; height: 18px;">
                </td>
                </tr>
            `
            $(".ui-table tbody").append(content);
        });
    } else if (type == "player-death") {
        $.each(data, function(k, v) {
            const content = `
            <tr>
                                <td class="rank-column">#${k + 1}</td>
                                <td class="name-column">
                                  <div style="display: flex; flex-direction: row; align-items: center; padding-left: 8px;">
                                    <div class="game-badge leaderboard-badge">
                                      <img alt="" ${v && v.prestige > 0 ? `src="/ui/assets/badges/prestige_${v.prestige}.png" style="margin-left: 10px; margin-right: 8px;"` : ''}>
                                    </div>
                                    <span class="leaderboard-name">
                                      <span class="color" style="color: #8b8378"> ${v.username}</span>
                                    </span>
                                  </div>
                                </td>
                                <td class="total-column">${v.death}</td>
                                <td class="right-cell" style="text-align: right; padding-right: 3vh;">${v.country}</td>
                              </tr>
            `
            $(".ui-table tbody").append(content);
        });

    } else if (type == "player-token") {
        $.each(data, function(k, v) {
          const tokenVARIABLE = formatNumberWithCommas(v.token);
            const content = `
            <tr>
                                <td class="rank-column">#${k + 1}</td>
                                <td class="name-column">
                                  <div style="display: flex; flex-direction: row; align-items: center; padding-left: 8px;">
                                    <div class="game-badge leaderboard-badge">
                                      <img alt="" ${v && v.prestige > 0 ? `src="/ui/assets/badges/prestige_${v.prestige}.png" style="margin-left: 10px; margin-right: 8px;"` : ''}>
                                    </div>
                                    <span class="leaderboard-name">
                                      <span class="color" style="color: #8b8378"> ${v.username}</span>
                                    </span>
                                  </div>
                                </td>
                                <td class="total-column">${tokenVARIABLE}</td>
                                <td class="right-cell" style="text-align: right; padding-right: 3vh;">${v.country}</td>
                              </tr>
            `
            $(".ui-table tbody").append(content);
        });
    }
}

function LoadProfile2() {
  $.post("https://gamemode/GetPlayerStats", JSON.stringify({}));
}


function LoadProfilePlayer(data) {
    $(".ui-profiles").empty();  
    console.log("Received data:", data);
    
    try {
        if (typeof data === 'string') {
            data = JSON.parse(data);
        }
    } catch (error) {
        console.error("Failed to parse JSON:", error);
        return;
    }
    
    const tokenVARIABLE = formatNumberWithCommas(data.tokens);
    const countryCode = data.country || "GB";
    const flagUrl = `https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${countryCode.toLowerCase()}.svg`;
    console.log(flagUrl, "FLAG URL PROFIL");
    
    // Génération de la nouvelle interface moderne
    const content = `
    <div class="player-profile-modern">
        <div class="profile-header">
            <div class="avatar">
                <img src="./assets/default-avatar.jpg" alt="Player Avatar">
            </div>
            <div class="profile-info">
                <h2 class="username">${data.username}</h2>
                <div class="player-id">ID: #${data.uuid || 'N/A'}</div>
                <div class="meta-info">
                    <div class="meta-item crew">
                        <i class="fas fa-users icon"></i> ${data.crewName || 'No Crew'}
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-medal icon"></i> Prestige ${data.prestige}
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-globe icon"></i> 
                        <div class="country-flag">
                            <img src="${flagUrl}" alt="${data.country}" onerror="this.src='./assets/default-avatar.jpg'; this.onerror=null;">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Déplacement des devises avant les statistiques -->
        <div class="currency-container">
            <div class="currency-item">
                <i class="fas fa-coins currency-icon"></i>
                <div class="currency-value">${tokenVARIABLE}</div>
                <div class="currency-label">Tokens</div>
            </div>
            <div class="currency-item">
                <img src="./assets/coins.jpg" alt="Guild Coins" class="currency-icon" style="width: 2.2vh; height: 2.2vh; border-radius: 50%; object-fit: cover;">
                <div class="currency-value">${data.coins}</div>
                <div class="currency-label">Guild Coins</div>
            </div>
        </div>
        
        <div class="stats-container">
            <div class="stats-box" style="--i: 1">
                <div class="stats-value">${data.kd}</div>
                <div class="stats-label">K/D Ratio</div>
                <div class="stats-rank">#${data.placeKD || 'N/A'}</div>
            </div>
            <div class="stats-box" style="--i: 2">
                <div class="stats-value">${data.kills}</div>
                <div class="stats-label">Kills</div>
                <div class="stats-rank">#${data.placeKill}</div>
            </div>
            <div class="stats-box" style="--i: 3">
                <div class="stats-value">${data.death}</div>
                <div class="stats-label">Deaths</div>
                <div class="stats-rank">#${data.placeDeath}</div>
            </div>
            <div class="stats-box" style="--i: 4">
                <div class="stats-value highlight">${tokenVARIABLE}</div>
                <div class="stats-label">Tokens</div>
                <div class="stats-rank">#${data.placeToken}</div>
            </div>
        </div>
        
        <div class="detail-section">
            <h3 class="section-title">Achievements</h3>
            <div class="achievements">
                ${data.placeKill <= 10 ? `
                <div class="achievement">
                    <i class="fas fa-trophy achievement-icon"></i>
                    <div class="achievement-title">Elite Killer</div>
                    <div class="achievement-desc">Top 10 in kills leaderboard (#${data.placeKill})</div>
                </div>
                ` : data.placeKill <= 50 ? `
                <div class="achievement">
                    <i class="fas fa-medal achievement-icon"></i>
                    <div class="achievement-title">Expert Killer</div>
                    <div class="achievement-desc">Top 50 in kills leaderboard (#${data.placeKill})</div>
                </div>
                ` : ''}
                
                ${data.kd >= 2.0 ? `
                <div class="achievement">
                    <i class="fas fa-skull achievement-icon"></i>
                    <div class="achievement-title">Survivor</div>
                    <div class="achievement-desc">Maintain K/D ratio above 2.0 (${data.kd})</div>
                </div>
                ` : ''}
                
                ${data.tokens >= 300000 ? `
                <div class="achievement">
                    <i class="fas fa-coins achievement-icon"></i>
                    <div class="achievement-title">Token Elite</div>
                    <div class="achievement-desc">Earned over 300,000 tokens</div>
                </div>
                ` : data.tokens >= 100000 ? `
                <div class="achievement">
                    <i class="fas fa-coins achievement-icon"></i>
                    <div class="achievement-title">Token Master</div>
                    <div class="achievement-desc">Earned over 100,000 tokens</div>
                </div>
                ` : ''}
                
                ${data.prestige >= 1 ? `
                <div class="achievement">
                    <i class="fas fa-star achievement-icon"></i>
                    <div class="achievement-title">Prestige Pioneer</div>
                    <div class="achievement-desc">Reached prestige level 1+</div>
                </div>
                ` : ''}
                
                ${data.prestige >= 5 ? `
                <div class="achievement">
                    <i class="fas fa-crown achievement-icon"></i>
                    <div class="achievement-title">Prestige Elite</div>
                    <div class="achievement-desc">Reached prestige level 5+</div>
                </div>
                ` : ''}
                
                ${(!data.placeKill || data.placeKill > 50) && (!data.kd || data.kd < 2.0) && (!data.tokens || data.tokens < 100000) && (!data.prestige || data.prestige < 1) ? `
                <div class="achievement" style="opacity: 0.6;">
                    <i class="fas fa-hourglass-half achievement-icon"></i>
                    <div class="achievement-title">No Achievements Yet</div>
                    <div class="achievement-desc">Keep playing to unlock achievements!</div>
                </div>
                ` : ''}
            </div>
        </div>
        
        <div class="detail-section">
            <h3 class="section-title">Activity</h3>
            <div class="activity-chart">
                <!-- À l'avenir, cette section pourrait contenir un graphique d'activité -->
                <div style="height: 100%; display: flex; align-items: center; justify-content: center; color: #909090;">
                    <i class="fas fa-chart-line" style="margin-right: 10px; font-size: 2vh;"></i>
                    Player activity data will be displayed here
                </div>
            </div>
        </div>
    </div>`;
    
    $(".ui-profiles").append(content);
    
    // Ajout de Font Awesome si non présent
    if ($('link[href*="font-awesome"]').length === 0) {
        $('head').append('<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">');
    }
}


function HelpLoad(str) {
    if (str == "tutorial") {
        togglePrimaryClass('tutorial-button', 'commands-button');
        $(".help-page-container").empty();
    
        const content = `
        <div class="help-page no-background">
                        <div class="article">
                          <p class="title big">Beginner guide</p>
                          <p class="credits">Server made by players for players.</p>
                          <p class="title">What is Guild PvP</p>
                          <p>Guild PvP is a unique FiveM server crafted specifically for PvP enthusiasts. Built on feedback from experienced players, this server offers an extraordinary experience where every aspect is tailored for those who love tricks and intense combat.</p>
                          <p>The gaming environment, optimized to perfection, captures the electric atmosphere of FiveM Prime 2020/2021,</p>
                          <span class="" style="display: inline-block;"></span>
                          <p>with smooth graphics and flawless gameplay. Guild PvP stands out with its dedicated community and constant focus on providing a balanced and competitive battlefield, making every fight unforgettable.</p>
                          <p>Whether you're a PvP veteran or a newcomer looking to improve, this server promises hours of thrilling challenges.</p>
                        </div>
                        <div class="media">
                          <p class="title big">Helpful videos</p>
                          <div class="video-list">
                            <div class="video-row">
                              <div class="video-item">
                                <div class="iframe-top">
                                  <iframe src="https://www.youtube.com/embed/VfFcIR5phAI?si=p5-g0x0URCJUU3mx"></iframe>
                                </div>
                                <span class="description">Best of RyWaZ</span>
                              </div>
                              <div class="video-item">
                                <div class="iframe-top">
                                  <iframe src="https://www.youtube.com/embed/dCyCk6KP4Ds?si=jEbDb81qoUSKbKJc"></iframe>
                                </div>
                                <span class="description">Best of kaykL</span>
                              </div>
                              <div class="video-item">
                                <div class="iframe-top">
                                  <iframe src="https://www.youtube.com/embed/Bo-u6g4Biy4?si=XXmDFxmF9uu-OZnA"></iframe>
                                </div>
                                <span class="description">Best of kaykL 2</span>
                              </div>
                            </div>
                            <div class="video-row">
                              <div class="video-item">
                                <div class="iframe-top">
                                  <iframe src="https://www.youtube.com/embed/Ltztmb1TEho?si=y5yDSSZB-H1eXPT4"></iframe>
                                </div>
                                <span class="description">Best of MaSon</span>
                              </div>
                              <div class="video-item"></div>
                              <div class="video-item"></div>
                            </div>
                            <div class="video-row">
                              <div class="video-item invisible"></div>
                            </div>
                            <span class="disclaimer">Want you video here? Contact the support with your tutorial!</span>
                          </div>
                        </div>
                      </div>
        `
        $(".help-page-container").append(content);

    } else if (str == "commands") {
        togglePrimaryClass('commands-button', 'tutorial-button');
        $(".help-page-container").empty();
        
        const content = `
        <div class="help-page column scroll">
      <div class="command-list">
        <span class="title">Global commands</span>
        <div class="commands">
          <span>/prestige - Display information about the prestige system (Commands)</span>
          <span>/tags - Display information about the tags system (Commands)</span>
          <span>/createcrew - Create a crew</span>
          <span>/crew - Open the crew menu</span>
          <span>/leavecrew - Leave your current crew</span>
          <span>/getrank - Rank Server</span>
          <span>/nickname - Change your nickname</span>
          <span>/trade [uuid] - Trade with others player</span>
          <span>/kit - List available kits</span> 
        </div>
        </div>
        <div class="command-list">
            <span class="title">Gold commands</span>
            <div class="commands">
            <span>/kit gold - Gold kit</span>
            <span>/deathmessage - Put a message when you kill someone</span>
            </div>
        </div>
        <div class="command-list">
            <span class="title">Diamond commands</span>
            <div class="commands">
            <span>/killeffect - Open kill effect menu</span>
            <span>/kit diamond - Diamonds kit</span>
            <span>/reset_stats - Reset stats</span>
            <span>/fw - Spawn a firework</span>
            <span>/ytb - Put a video youtube in SafeZone at your own coords.</span>
            <span>/stopytb - Stop youtube video.</span>
            </div>
        </div>
        </div>
        `
        $(".help-page-container").append(content);
    }
}

LoadInventory = inventory => {
  $(".inventory-wrapper.inventory.self > .items-container > .item-slot").remove();
  const screenWidth = window.screen.width;
  const screenHeight = window.screen.height;
  
  $.each(inventory, function(k, v) {
      const isSmallScreen = screenWidth <= 1600 && screenHeight <= 1400;
      const widthStyle = isSmallScreen ? 'style="width: 11.5vh;"' : '';
      
      const content = `
          <div class="item-slot" id="item-slot-${v.name}" onclick="FastMove('${v.name}')" onmouseenter="FastSlot('${v.name}', 'normal')" data-itemdata='${JSON.stringify({itemName: v.name, itemCount: v.count, currentContainer: "inventory"})}'>
              <span class="item-info" id="normal-count-${v.name}">x${v.count}</span>
              <div class="icon-container">
                  <img class="icon" src="assets/items/${v.name}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''} background-repeat: no-repeat; pointer-events: none; background-position: center; background-size: cover;">
              </div>
              <div class="details-container">
                  <span class="item-name">${v.label}</span>
              </div>
          </div>
      `;

      $(".inventory-wrapper.inventory.self > .items-container").append(content);
      $("#item-slot-" + v.name).data("item", v.name);
      $("#item-slot-" + v.name).data("count", v.count);
  });
};


LoadSafeInventory = (inventory, inventoryType) => {
  $(".inventory-wrapper.inventory.safe > .items-container > .item-slot").remove();
  const screenWidth = window.screen.width;
  const screenHeight = window.screen.height;

  $.each(inventory, function(k, v) {
      const isSmallScreen = screenWidth <= 1600 && screenHeight <= 1400;
      const widthStyle = isSmallScreen ? 'style="width: 11.5vh;"' : '';

      const content = `
          <div class="item-slot" id="safe-item-slot-${v.name}" onclick="FastMove('${v.name}')" onmouseenter="FastSlot('${v.name}', 'safe')" data-itemdata='${JSON.stringify({itemName: v.name, itemCount: v.count, currentContainer: inventoryType})}'>
              <span class="item-info" id="safe-count-${v.name}">x${v.count}</span>
              <div class="icon-container">
                  <img class="icon" src="assets/items/${v.name}.png" alt="${v.label}" ${isSmallScreen ? 'style="width: 157%; height: 90%;"' : ''}>
              </div>
              <div class="details-container">
                  <span class="item-name">${v.label}</span>
              </div>
          </div>
      `;

      $(".inventory-wrapper.inventory.safe > .items-container").append(content);
      $(`#safe-item-slot-${v.name}`).data("item", v.name);
      $(`#safe-item-slot-${v.name}`).data("count", v.count);
  });
};




// if (/^bags-\d+$/.test(id)) {
//   $(".inventory-wrapper.inventory.half.side .ui-title-container .top-container .title span").text("Bags");
// } else if (/^stash-\d+$/.test(id)) {
//   $(".inventory-wrapper.inventory.half.side .ui-title-container .top-container .title span").text("Stash");
// }

LoadMyInventorySide = (inventory, inventoryType, id) => {
  $(".inventory-wrapper.inventory.half.side > .items-container.side > .item-slot").remove();
  const screenWidth = window.screen.width;
  const screenHeight = window.screen.height;
  
  $.each(inventory, function(k, v) {
    const isSmallScreen = screenWidth <= 1600 && screenHeight <= 1400;
    const widthStyle = isSmallScreen ? 'style="width: 11.5vh;"' : '';
    
    const content = `
      <div class="item-slot" id="inv-item-slot-${v.name}" onclick="FastMoveContainer('${v.name}', '${id}')" onmouseenter="FastSlot('${v.name}', 'normal')" data-itemdata='${JSON.stringify({itemName: v.name, itemCount: v.count, currentContainer: inventoryType, id: id})}'>
        <span class="item-info" id="inv-count-${v.name}">x${v.count}</span>
        <div class="icon-container">
          <img class="icon" src="assets/items/${v.name}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''} background-repeat: no-repeat; pointer-events: none; background-position: center; background-size: cover;">
        </div>
        <div class="details-container">
          <span class="item-name">${v.label}</span>
        </div>
      </div>
    `;

    $(".inventory-wrapper.inventory.half.side > .items-container.side").append(content);
    $("#inv-item-slot-" + v.name).data("item", v.name);
    $("#inv-item-slot-" + v.name).data("count", v.count);
    $("#inv-item-slot-" + v.name).data("id", id);
  });
};


LoadContainerBag = (inventory, inventoryType, id) => {
  $(".inventory-wrapper.inventory.side:not(.half) > .items-container.side > .item-slot").remove();
  const screenWidth = window.screen.width;
  const screenHeight = window.screen.height;

  $.each(inventory, function(k, v) {
    const isSmallScreen = screenWidth <= 1600 && screenHeight <= 1400;
    const widthStyle = isSmallScreen ? 'style="width: 11.5vh;"' : '';

    const content = `
      <div class="item-slot" id="container-item-slot-${v.name}" onclick="FastMoveContainer('${v.name}', '${id}')" onmouseenter="FastSlot('${v.name}', 'container')" data-itemdata='${JSON.stringify({itemName: v.name, itemCount: v.count, currentContainer: inventoryType, id: id})}'>
        <span class="item-info" id="container-count-${v.name}">x${v.count}</span>
        <div class="icon-container">
          <img class="icon" src="assets/items/${v.name}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''} background-repeat: no-repeat; pointer-events: none; background-position: center; background-size: cover;">
        </div>
        <div class="details-container">
          <span class="item-name">${v.label}</span>
        </div>
      </div>
    `;

    $(".inventory-wrapper.inventory.side:not(.half) > .items-container.side").append(content);
    $("#container-item-slot-" + v.name).data("item", v.name);
    $("#container-item-slot-" + v.name).data("count", v.count);
    $("#container-item-slot-" + v.name).data("id", id);
  });
};


function FastMoveContainer(itemName, id) {
  itemid = itemName;
  id = id;
  which = LastData.hangi;

  // Fermer le menu contextuel si l'objet est déplacé
  closeContextMenu();

//   if (DisableInventoryMove == true) {
//     return;
//   }

  if (typeof which == 'undefined' || which == null) {
    return;
  }

  const screenWidth = window.screen.width;
  const screenHeight = window.screen.height;
  const isSmallScreen = screenWidth <= 1600 && screenHeight <= 1400;

  if (which == 'normal') {
    if (combatmode == true) {
      return;
    }
    safecount = $("#inv-item-slot-" + itemid).data("count");
    if (safecount > 1) {
      x = safecount - 1;
      check = document.getElementById("inv-count-" + itemid).innerHTML = 'x' + x;
      if (typeof check === "undefined" || check === null) {
        return;
      }
      $("#inv-item-slot-" + itemid).data("count", x);
      if ($("#container-item-slot-" + itemid).length > 0) {
        safecount = $('#container-item-slot-' + itemid).data("count");
        updatesafecount = safecount + 1;
        $("#container-item-slot-" + itemid).data("count", updatesafecount);
        $("#container-item-slot-" + itemid).data('item', itemid);
        document.getElementById("container-count-" + itemid).innerHTML = 'x' + updatesafecount;
        $.post("https://gamemode/CheckContainer", JSON.stringify({
          'item': itemid,
          'id': id
        }), function(_0x2ed332) {});
      } else {
        const content = `
          <div class="item-slot" id="container-item-slot-${itemid}" onclick="FastMoveContainer('${itemid}', '${id}')" onmouseenter="FastSlot('${itemid}', 'container')" data-itemdata=${JSON.stringify({itemName: itemid, itemCount: 1, currentContainer: "container", id: id})}>
            <span class="item-info" id="container-count-${itemid}">x1</span>
            <div class="icon-container">
              <img class="icon" src="assets/items/${itemid}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''}">
            </div>
            <div class="details-container">
              <span class="item-name">${normalinventoryitem[itemid].label}</span>
            </div>
          </div>
        `;
        $(".inventory-wrapper.inventory.side:not(.half) > .items-container.side").append(content);
        $("#container-item-slot-" + itemid).data("item", itemid);
        $("#container-item-slot-" + itemid).data("count", 1);
        $.post("https://gamemode/CheckContainer", JSON.stringify({
          'item': itemid,
          'id': id
        }), function(_0x5c8bee) {});
      }
    } else {
      if ($("#container-item-slot-" + itemid).length > 0) {
        safecount = $('#container-item-slot-' + itemid).data("count");
        updatesafecount = safecount + 1;
        $("#container-item-slot-" + itemid).data("count", updatesafecount);
        $("#container-item-slot-" + itemid).data('item', itemid);
        document.getElementById("container-count-" + itemid).innerHTML = 'x' + updatesafecount;
      } else {
        const content = ` 
          <div class="item-slot" id="container-item-slot-${itemid}" onclick="FastMoveContainer('${itemid}', '${id}')" onmouseenter="FastSlot('${itemid}', 'container')" data-itemdata=${JSON.stringify({itemName: itemid, itemCount: 1, currentContainer: "container", id: id})}>
            <span class="item-info" id="container-count-${itemid}">x1</span>
            <div class="icon-container">
              <img class="icon" src="assets/items/${itemid}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''}">
            </div>
            <div class="details-container">
              <span class="item-name">${normalinventoryitem[itemid].label}</span>
            </div>
          </div>
        `;
        $(".inventory-wrapper.inventory.side:not(.half) > .items-container.side").append(content);
        $("#container-item-slot-" + itemid).data("item", itemid);
        $("#container-item-slot-" + itemid).data("count", 1);
      }
      $("#inv-item-slot-" + itemid).remove();
      $.post("https://gamemode/CheckContainer", JSON.stringify({
        'item': itemid,
        'id': id
      }), function(_0xa0444a) {});
    }
  } else {
    if (PlayerWeight + normalinventoryitem[itemid].weight > PlayerMaxWeight) {
      return;
    }

    safecount = $("#container-item-slot-" + itemid).data("count");
    if (safecount > 1) {
      x = safecount - 1;
      check = document.getElementById("container-count-" + itemid).innerHTML = 'x' + x;
      if (typeof check === "undefined" || check === null) {
        return;
      }
      $("#container-item-slot-" + itemid).data("count", x);
      if ($("#inv-item-slot-" + itemid).length > 0) {
        f = $('#inv-item-slot-' + itemid).data("count");
        c = f + 1;
        $("#inv-item-slot-" + itemid).data("item", itemid);
        $("#inv-item-slot-" + itemid).data("count", c);
        document.getElementById("inv-count-" + itemid).innerHTML = 'x' + c;
        $.post("https://gamemode/CheckContainer2", JSON.stringify({
          'item': itemid,
          'id': id
        }), function(_0x2ed332) {});
      } else {
        const content = `
          <div class="item-slot" id="inv-item-slot-${itemid}" onclick="FastMoveContainer('${itemid}', '${id}')" onmouseenter="FastSlot('${itemid}', 'normal')" data-itemdata=${JSON.stringify({itemName: itemid, itemCount: 1, currentContainer: "inventory", id: id})}>
            <span class="item-info" id="inv-count-${itemid}">x1</span>
            <div class="icon-container">
              <img class="icon" src="assets/items/${itemid}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''}">
            </div>
            <div class="details-container">
              <span class="item-name">${normalinventoryitem[itemid].label}</span>
            </div>
          </div>
        `;
        $(".inventory-wrapper.inventory.half.side > .items-container.side").append(content);
        $("#inv-item-slot-" + itemid).data("item", itemid);
        $("#inv-item-slot-" + itemid).data("count", 1);
        $.post("https://gamemode/CheckContainer2", JSON.stringify({
          'item': itemid,
          'id': id
        }), function(_0x5c8bee) {});
      }
    } else {
      if ($("#inv-item-slot-" + itemid).length > 0) {
        za = $('#inv-item-slot-' + itemid).data("count");
        updatesafecount = za + 1;
        $("#inv-item-slot-" + itemid).data("item", itemid);
        $("#inv-item-slot-" + itemid).data("count", updatesafecount);
        document.getElementById("inv-count-" + itemid).innerHTML = 'x' + updatesafecount;
      } else {
        const content = `
          <div class="item-slot" id="inv-item-slot-${itemid}" onclick="FastMoveContainer('${itemid}', '${id}')" onmouseenter="FastSlot('${itemid}', 'normal')" data-itemdata=${JSON.stringify({itemName: itemid, itemCount: 1, currentContainer: "inventory", id: id})}>
            <span class="item-info" id="inv-count-${itemid}">x1</span>
            <div class="icon-container">
              <img class="icon" src="assets/items/${itemid}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''}">
            </div>
            <div class="details-container">
              <span class="item-name">${normalinventoryitem[itemid].label}</span>
            </div>
          </div>
        `;
        $(".inventory-wrapper.inventory.half.side > .items-container.side").append(content);
        $("#inv-item-slot-" + itemid).data("item", itemid);
        $("#inv-item-slot-" + itemid).data("count", 1);
      }
      $("#container-item-slot-" + itemid).remove();
      $.post("https://gamemode/CheckContainer2", JSON.stringify({
        'item': itemid,
        'id': id
      }), function(_0xa0444a) {});
    }
  }
}



UpdateInventory = data => {

    if (data.inventory) {
        LoadInventory(data.inventory);
    } else if (data.safeinventory) {
        LoadSafeInventory(data.safeinventory, "protected");
    }
}

function FastMove(itemName) {
  itemid = itemName;
  which = LastData.hangi;

  // Fermer le menu contextuel si l'objet est déplacé
  closeContextMenu();

  if (DisableInventoryMove == true) {
    return;
  }

  if (typeof which == 'undefined' || which == null) {
    return;
  }

  const screenWidth = window.screen.width;
  const screenHeight = window.screen.height;
  const isSmallScreen = screenWidth <= 1600 && screenHeight <= 1400;

  if (which == 'normal') {
    if (combatmode == true) {
      return;
    }
    if (OtherWeight + normalinventoryitem[itemid].weight > OtherMaxWeight) {
      return;
    }
    safecount = $("#item-slot-" + itemid).data("count");
    if (safecount > 1) {
      x = safecount - 1;
      check = document.getElementById("normal-count-" + itemid).innerHTML = 'x' + x;
      if (typeof check === "undefined" || check === null) {
        return;
      }
      $("#item-slot-" + itemid).data("count", x);
      if ($("#safe-item-slot-" + itemid).length > 0) {
        safecount = $('#safe-item-slot-' + itemid).data("count");
        updatesafecount = safecount + 1;
        $("#safe-item-slot-" + itemid).data("count", updatesafecount);
        $("#safe-item-slot-" + itemid).data('item', itemid);
        document.getElementById("safe-count-" + itemid).innerHTML = 'x' + updatesafecount;
        $.post("https://gamemode/CheckItems", JSON.stringify({
          'item': itemid
        }), function (_0x2ed332) {});
      } else {
        const content = `
          <div class="item-slot" id="safe-item-slot-${itemid}" onclick="FastMove('${itemid}')" onmouseenter="FastSlot('${itemid}', 'safe')" data-itemdata=${JSON.stringify({itemName: itemid, itemCount: 1, currentContainer: "protected"})}>
            <span class="item-info" id="safe-count-${itemid}">x1</span>
            <div class="icon-container">
              <img class="icon" src="assets/items/${itemid}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''}">
            </div>
            <div class="details-container">
              <span class="item-name">${normalinventoryitem[itemid].label}</span>
            </div>
          </div>
        `;
        $(".inventory-wrapper.inventory.safe > .items-container").append(content);
        $("#safe-item-slot-" + itemid).data("item", itemid);
        $("#safe-item-slot-" + itemid).data("count", 1);
        $.post("https://gamemode/CheckItems", JSON.stringify({
          'item': itemid
        }), function (_0x5c8bee) {});
      }
    } else {
      if ($("#safe-item-slot-" + itemid).length > 0) {
        safecount = $('#safe-item-slot-' + itemid).data("count");
        updatesafecount = safecount + 1;
        $("#safe-item-slot-" + itemid).data("count", updatesafecount);
        $("#safe-item-slot-" + itemid).data('item', itemid);
        document.getElementById("safe-count-" + itemid).innerHTML = 'x' + updatesafecount;
      } else {
        const content = `
          <div class="item-slot" id="safe-item-slot-${itemid}" onclick="FastMove('${itemid}')" onmouseenter="FastSlot('${itemid}', 'safe')" data-itemdata=${JSON.stringify({itemName: itemid, itemCount: 1, currentContainer: "protected"})}>
            <span class="item-info" id="safe-count-${itemid}">x1</span>
            <div class="icon-container">
              <img class="icon" src="assets/items/${itemid}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''}">
            </div>
            <div class="details-container">
              <span class="item-name">${normalinventoryitem[itemid].label}</span>
            </div>
          </div>
        `;
        $(".inventory-wrapper.inventory.safe > .items-container").append(content);
        $("#safe-item-slot-" + itemid).data("item", itemid);
        $("#safe-item-slot-" + itemid).data("count", 1);
      }
      $("#item-slot-" + itemid).remove();
      $.post("https://gamemode/CheckItems", JSON.stringify({
        'item': itemid
      }), function (_0xa0444a) {});
    }
  } else {
    if (PlayerWeight + normalinventoryitem[itemid].weight > PlayerMaxWeight) {
      return;
    }
    safecount = $("#safe-item-slot-" + itemid).data("count");
    if (safecount > 1) {
      x = safecount - 1;
      check = document.getElementById("safe-count-" + itemid).innerHTML = 'x' + x;
      if (typeof check === "undefined" || check === null) {
        return;
      }
      $("#safe-item-slot-" + itemid).data("count", x);
      if ($("#item-slot-" + itemid).length > 0) {
        f = $('#item-slot-' + itemid).data("count");
        c = f + 1;
        $("#item-slot-" + itemid).data("item", itemid);
        $("#item-slot-" + itemid).data("count", c);
        document.getElementById("normal-count-" + itemid).innerHTML = 'x' + c;
        $.post("https://gamemode/CheckItemsSafe", JSON.stringify({
          'item': itemid
        }), function (_0x2b0547) {});
      } else {
        const content = `
          <div class="item-slot" id="item-slot-${itemid}" onclick="FastMove('${itemid}')" onmouseenter="FastSlot('${itemid}', 'normal')" data-itemdata=${JSON.stringify({itemName: itemid, itemCount: 1, currentContainer: "inventory"})}>
            <span class="item-info" id="normal-count-${itemid}">x1</span>
            <div class="icon-container">
              <img class="icon" src="assets/items/${itemid}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''}">
            </div>
            <div class="details-container">
              <span class="item-name">${normalinventoryitem[itemid].label}</span>
            </div>
          </div>
        `;
        $(".inventory-wrapper.inventory.self > .items-container").append(content);
        $("#item-slot-" + itemid).data("item", itemid);
        $("#item-slot-" + itemid).data("count", 1);
        $.post("https://gamemode/CheckItemsSafe", JSON.stringify({
          'item': itemid
        }), function (_0xa0444a) {});
      }
    } else {
      if ($("#item-slot-" + itemid).length > 0) {
        za = $('#item-slot-' + itemid).data("count");
        updatesafecount = za + 1;
        $("#item-slot-" + itemid).data('item', itemid);
        $("#item-slot-" + itemid).data("count", updatesafecount);
        document.getElementById("normal-count-" + itemid).innerHTML = 'x' + updatesafecount;
      } else {
        const content = `
          <div class="item-slot" id="item-slot-${itemid}" onclick="FastMove('${itemid}')" onmouseenter="FastSlot('${itemid}', 'normal')" data-itemdata=${JSON.stringify({itemName: itemid, itemCount: 1, currentContainer: "inventory"})}>
            <span class="item-info" id="normal-count-${itemid}">x1</span>
            <div class="icon-container">
              <img class="icon" src="assets/items/${itemid}.png" style="${isSmallScreen ? 'width: 157%; height: 90%;' : ''}">
            </div>
            <div class="details-container">
              <span class="item-name">${normalinventoryitem[itemid].label}</span>
            </div>
          </div>
        `;
        $(".inventory-wrapper.inventory.self > .items-container").append(content);
        $("#item-slot-" + itemid).data("item", itemid);
        $("#item-slot-" + itemid).data("count", 1);
      }
      $("#safe-item-slot-" + itemid).remove();
      $.post("https://gamemode/CheckItemsSafe", JSON.stringify({
        'item': itemid
      }), function (_0xa0444a) {});
    }
  }
}



$(document).on("keydown", function (e) {
    switch (e.which) {
        // case 16:
        //     ShiftPressed = true
        //     break;
        // case 17:
        //     ControlPressed = true
        //     break;
    }
})

const HotBarKeys = {
    49: 1,
    50: 2,
    51: 3,
    52: 4,
    53: 5,
    54: 6,
    55: 7
}

Config = {
    CloseKeys: ["Escape"]
}

InShop = false

MouseData = null 
$(document).on("keyup", function (e) {
  // switch (e.which) {
  //     case 16:
  //         ShiftPressed = false
  //         break;
  //     case 17:
  //         ControlPressed = false
  //         break;
  // }
  $.each(HotBarKeys, function (k, v) {
      if (e.which == k && MouseData) {
        console.log("sending post")
          $.post("https://gamemode/SetHotbar", JSON.stringify({ id: v, itemName: MouseData.itemName }));
      }
  });
  $.each(Config.CloseKeys, function (k, v) {
      if (e.key == v) {
          $.post("https://gamemode/Close");
          if (InShop) {
              InShop = false;
              LoadShop({bool: false})
          }
      }
  });
})

$(document).on("mouseenter", ".item-slot", function () {
  const itemData = $(this).data("itemdata")
  MouseData = itemData
})

$(document).on("mouseleave", ".item-slot", function () {
  MouseData = null
})



function SetSettingsValue(index) {
  if (index == "opacity") {

    const inputElement = document.querySelector('.option-input-number');
    if (inputElement) {
      const inputValue = inputElement.value;
      // console.log(inputValue);
      $(".ui-content").css("background-color", "rgba(19, 21, 23, " + inputValue + ")");
    } else {
      // console.error('Element with ID "option-input-number" not found.');
    }

  }
}

// document.addEventListener('DOMContentLoaded', function () {
//   LoadMyInventorySide([
//     { name: "weapon_heavysniper", label: "AWP", count: 4 },
//   ], "inventory", "inventory")
//   LoadContainerBag([
//     { name: "weapon_heavysniper_mk2", label: "AWP Mk II", count: 1 },
//   ], "container", "container-5505005")
//   ChangePages('container');
//     $(".ui-body").show();
//     const element = document.querySelector('.ui-body');
//     if (element) {
//         element.style.display = 'flex';
//     }
// });


// Ajout d'un style CSS pour le menu contextuel (vous pourriez vouloir le déplacer dans un fichier CSS séparé)
$('head').append(`
<style>
  .context-menu {
    position: absolute;
    background-color: rgba(20, 22, 24, 0.95);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 5px;
    width: 300px;
    max-height: 350px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
    z-index: 1000;
    overflow: hidden;
    color: #fff;
    font-family: 'Roboto', sans-serif;
  }
  
  .context-menu-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 15px;
    background-color: rgba(30, 32, 34, 0.95);
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }
  
  .context-menu-title {
    font-size: 14px;
    font-weight: 600;
  }
  
  .context-menu-close {
    cursor: pointer;
    opacity: 0.7;
    transition: opacity 0.2s;
  }
  
  .context-menu-close:hover {
    opacity: 1;
  }
  
  .context-menu-body {
    max-height: 300px;
    overflow-y: auto;
  }
  
  .players-table {
    width: 100%;
    border-collapse: collapse;
  }
  
  .players-table th, .players-table td {
    padding: 8px 15px;
    text-align: left;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }
  
  .players-table th {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.6);
    text-transform: uppercase;
    font-weight: 400;
  }
  
  .players-table tr {
    cursor: pointer;
    transition: background-color 0.2s;
  }
  
  .players-table tr:hover {
    background-color: rgba(255, 255, 255, 0.05);
  }
  
  .players-table td {
    font-size: 13px;
  }
</style>
`);

// Création d'une fonction pour fermer le menu contextuel
function closeContextMenu() {
  $('#player-context-menu').remove();
}

// Ajout d'une fonction pour simuler la liste des joueurs (dans un cas réel, vous recevriez cela du serveur)
function getPlayersList() {
  // Initialize an empty array to store players
  let playersList = [];
  
  // Make a synchronous request to the server to get the player list
  $.ajax({
    url: "https://gamemode/GetListPlayers",
    type: "POST",
    async: false, // This is important to make it synchronous
    data: JSON.stringify({}),
    success: function(response) {
      if (response && response.length > 0) {
        playersList = response;
      }
    }
  });
  
  // If no players were returned, use a sample list for testing
  if (playersList.length === 0) {
    console.log("No nearby players found, using sample data");
    return [
      { username: "No players nearby", uuid: "N/A", id: 0 }
    ];
  }
  
  return playersList;
}

// Remplacer le gestionnaire de clic droit existant
// Remplacer le gestionnaire de clic droit existant
$(document).on("contextmenu", ".inventory-wrapper.inventory.self > .items-container > .item-slot", function(e) { 
    if (!e.ctrlKey) {
        e.preventDefault(); // Empêche le menu contextuel standard du navigateur
    
        // Supprime tout menu contextuel existant
        closeContextMenu();
        
        const itemData = $(this).data("itemdata");
        const elementId = $(this).attr('id');
        
        // S'assure que l'élément est un élément d'inventaire valide
        if (elementId && elementId.startsWith('item-slot-')) {
            const itemName = itemData.itemName;
            const itemCount = itemData.itemCount;
            
            // Récupérer le libellé de l'élément s'il existe
            let itemLabel = itemName;
            if (normalinventoryitem[itemName]) {
                itemLabel = normalinventoryitem[itemName].label;
            }
            
            // Créer le menu contextuel
            const contextMenu = $(`
              <div id="player-context-menu" class="context-menu">
                <div class="context-menu-header">
                  <div class="context-menu-title">Give ${itemLabel} to a player</div>
                  <div class="context-menu-close">✕</div>
                </div>
                <div class="context-menu-body">
                  <table class="players-table">
                    <thead>
                      <tr>
                        <th>Username</th>
                        <th>UUID</th>
                        <th>ID</th>
                      </tr>
                    </thead>
                    <tbody>
                      <!-- Les joueurs seront ajoutés ici dynamiquement -->
                    </tbody>
                  </table>
                </div>
              </div>
            `);
            
            // Positionner le menu contextuel près du curseur
            $('body').append(contextMenu);
            contextMenu.css({
                top: e.pageY + 'px',
                left: e.pageX + 'px'
            });
            
            // Ajouter les joueurs à la table
            const playersList = getPlayersList();
            const tbody = contextMenu.find('tbody');
            
            $.each(playersList, function(i, player) {
                const row = $(`
                  <tr data-id="${player.id}" data-uuid="${player.uuid}" data-username="${player.username}">
                    <td>${player.username}</td>
                    <td>${player.uuid}</td>
                    <td>${player.id}</td>
                  </tr>
                `);
                tbody.append(row);
            });
            
            // Gérer le clic sur la croix pour fermer
            contextMenu.find('.context-menu-close').on('click', function() {
                closeContextMenu();
            });
            
            // Gérer le clic sur un joueur
            contextMenu.find('tbody tr').on('click', function() {
                const playerId = $(this).data('id');
                const playerUuid = $(this).data('uuid');
                const playerUsername = $(this).data('username');
                
                if (playerId === 0) {
                    // No nearby players case
                    closeContextMenu();
                    return;
                }
                
                console.log('GIVE ITEM TO PLAYER', {
                    itemName: itemName,
                    itemCount: itemCount,
                    player: {
                        id: playerId,
                        uuid: playerUuid,
                        username: playerUsername
                    }
                });
                
                // Send the request to the server to give the item to the player
                $.post("https://gamemode/GiveItemToPlayer", JSON.stringify({
                    item: itemName,
                    count: itemCount,
                    playerId: playerId,
                    playerUuid: playerUuid
                }));
                
                // Fermer le menu après avoir cliqué sur un joueur
                closeContextMenu();
                
                // Option: Mettre à jour l'inventaire si nécessaire
                // Le serveur enverra probablement une mise à jour après le transfert
            });
            
            // Fermer le menu après 10 secondes
            setTimeout(closeContextMenu, 10000);
        }
    } else {
         // Récupérer les données de l'item
        const itemData = $(this).data("itemdata");
        const elementId = $(this).attr('id');
        
        if (elementId && elementId.startsWith('item-slot-')) {
            const itemName = itemData.itemName;
            const itemCount = itemData.itemCount;
            
            // Récupérer le libellé et les informations supplémentaires de l'item s'ils existent
            let itemInfo = {
                name: itemName,
                count: itemCount,
                label: normalinventoryitem[itemName] ? normalinventoryitem[itemName].label : itemName,
                weight: normalinventoryitem[itemName] ? normalinventoryitem[itemName].weight : 'N/A'
            };
            
            // Afficher les informations dans la console
            console.log('Item Information:', {
                'Item Name': itemInfo.name,
                'Item Label': itemInfo.label,
                'Count': itemInfo.count,
                'Weight': itemInfo.weight,
                'Full Item Data': itemData
            });
            $.post("https://gamemode/deleteItem", JSON.stringify({
                item: itemName,
            }));
        }
    }
});


// Fermer le menu contextuel lorsque l'inventaire est fermé
$(document).on("keyup", function(e) {
    $.each(Config.CloseKeys, function(k, v) {
        if (e.key == v) {
            closeContextMenu();
        }
    });
});

// Ajout du style pour le drag and drop
$('head').append(`
<style>
  .item-slot.dragging {
    opacity: 0.8;
    z-index: 1000;
    pointer-events: none;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
  }
  
  .item-slot.drag-over {
    background-color: rgba(255, 255, 255, 0.1) !important;
  }
  
  .inventory-wrapper.inventory.shortcut > .items-container > .item-slot.drag-over {
    background-color: rgba(50, 50, 50, 0.4) !important;
  }
</style>
`);

// Initialiser le drag and drop
function initDragAndDrop() {
  // Rendre les éléments draggable
  setupDraggable('.inventory-wrapper.inventory.self > .items-container > .item-slot', 'inventory');
  setupDraggable('.inventory-wrapper.inventory.safe > .items-container > .item-slot', 'safe');
  setupDraggable('.inventory-wrapper.inventory.half.side > .items-container > .item-slot', 'container-side');
  setupDraggable('.inventory-wrapper.inventory.side:not(.half) > .items-container > .item-slot', 'container');
  
  // Zones de dépôt
  setupDropZone('.inventory-wrapper.inventory.self > .items-container', 'inventory');
  setupDropZone('.inventory-wrapper.inventory.safe > .items-container', 'safe');
  setupDropZone('.inventory-wrapper.inventory.half.side > .items-container', 'container-side');
  setupDropZone('.inventory-wrapper.inventory.side:not(.half) > .items-container', 'container');
  
  // Ajouter les emplacements de la hotbar comme zones de dépôt
  setupHotbarDropZones();
}

function setupHotbarDropZones() {
  // Enlever tous les gestionnaires d'événements existants pour éviter les doublons
  $('.inventory-wrapper.inventory.shortcut > .items-container > .item-slot').off('mouseenter mouseleave mouseup');
  
  // Configurer chaque emplacement de la hotbar comme zone de dépôt
  $('.inventory-wrapper.inventory.shortcut > .items-container > .item-slot').each(function(index) {
    const slotNumber = index + 1; // Les numéros de slot commencent à 1
    
    $(this).on('mouseenter.hotbar', function() {
      if ($('.dragging').length > 0) {
        $(this).addClass('drag-over');
      }
    }).on('mouseleave.hotbar', function() {
      $(this).removeClass('drag-over');
    });
  });
}

function setupDraggable(selector, sourceType) {
  // Supprimer d'abord les gestionnaires existants pour éviter les doublons
  $(document).off('mousedown', selector);
  
  $(document).on('mousedown', selector, function(e) {
    // Seulement démarrer le drag avec le clic gauche (button 0)
    if (e.button !== 0) return;
    
    const $this = $(this);
    const itemData = $this.data('itemdata');
    
    if (!itemData) return;
    
    // Stocker temporairement que nous sommes en train de déplacer cet élément
    // pour que LastData.hangi soit correctement défini lors du drop
    FastSlot(itemData.itemName, sourceType === 'inventory' ? 'normal' : sourceType);
    
    // Créer un élément clone exact pour le dragging
    const $clone = $this.clone();
    
    // Capturer tous les styles calculés de l'élément original
    const computedStyle = window.getComputedStyle($this[0]);
    const computedStyleObj = {};
    for (let i = 0; i < computedStyle.length; i++) {
      const prop = computedStyle[i];
      computedStyleObj[prop] = computedStyle.getPropertyValue(prop);
    }
    
    // Appliquer des styles supplémentaires pour le drag
    $clone.addClass('dragging').css({
      position: 'absolute',
      top: e.pageY - $this.height() / 2,
      left: e.pageX - $this.width() / 2,
      width: $this.outerWidth(),
      height: $this.outerHeight(),
      background: computedStyleObj.background,
      backgroundColor: computedStyleObj.backgroundColor,
      border: computedStyleObj.border,
      borderRadius: computedStyleObj.borderRadius,
      boxShadow: computedStyleObj.boxShadow,
      margin: 0,
      padding: computedStyleObj.padding
    });
    
    // Assurer que les enfants (icon, text, etc.) ont le même style
    $clone.find('.icon-container').css({
      background: $this.find('.icon-container').css('background'),
      backgroundColor: $this.find('.icon-container').css('backgroundColor')
    });
    
    $clone.find('.details-container').css({
      background: $this.find('.details-container').css('background'),
      backgroundColor: $this.find('.details-container').css('backgroundColor')
    });
    
    $('body').append($clone);
    
    // Stocker des données pour le drag
    const dragData = {
      sourceElement: $this,
      clone: $clone,
      sourceType: sourceType,
      itemName: itemData.itemName,
      itemCount: itemData.itemCount,
      startX: e.pageX,
      startY: e.pageY,
      offsetX: e.pageX - $this.offset().left,
      offsetY: e.pageY - $this.offset().top,
      containerId: itemData.id || null
    };
    
    // Stocker les données de l'item sur le clone pour l'accès dans les handlers de drop
    $clone.data('itemdata', itemData);
    
    // Attacher les événements de mouvement à document
    $(document).on('mousemove.drag', function(e) {
      $clone.css({
        top: e.pageY - dragData.offsetY,
        left: e.pageX - dragData.offsetX
      });
      
      // Gérer la surbrillance des emplacements (seulement les emplacements individuels, pas les conteneurs)
      $('.item-slot').each(function() {
        const rect = this.getBoundingClientRect();
        if (
          e.clientX >= rect.left && 
          e.clientX <= rect.right && 
          e.clientY >= rect.top && 
          e.clientY <= rect.bottom
        ) {
          $(this).addClass('drag-over');
    } else {
          $(this).removeClass('drag-over');
        }
      });
    });
    
    $(document).on('mouseup.drag', function(e) {
      // Vérifier si on a déposé sur un emplacement de la hotbar
      let droppedOnHotbar = false;
      
      $('.inventory-wrapper.inventory.shortcut > .items-container > .item-slot').each(function(index) {
        const rect = this.getBoundingClientRect();
        if (
          e.clientX >= rect.left && 
          e.clientX <= rect.right && 
          e.clientY >= rect.top && 
          e.clientY <= rect.bottom
        ) {
          droppedOnHotbar = true;
          const slotNumber = index + 1;
          
          // Appeler l'API pour définir l'emplacement de la hotbar
          console.log("Setting hotbar slot", slotNumber, "to item", dragData.itemName);
          $.post("https://gamemode/SetHotbar", JSON.stringify({ 
            id: slotNumber, 
            itemName: dragData.itemName 
          }));
          
          return false; // Sortir de la boucle each
        }
      });
      
      // Si on n'a pas déposé sur un emplacement de la hotbar, vérifier les autres conteneurs
      if (!droppedOnHotbar) {
        // Déterminer la zone de dépôt
        let dropTarget = null;
        let dropType = null;
        
        // Vérifier les conteneurs valides
        $('.items-container').not('.inventory-wrapper.inventory.shortcut > .items-container').each(function() {
          const rect = this.getBoundingClientRect();
          if (
            e.clientX >= rect.left && 
            e.clientX <= rect.right && 
            e.clientY >= rect.top && 
            e.clientY <= rect.bottom
          ) {
            dropTarget = $(this);
            
            // Déterminer le type de drop zone
            if (dropTarget.closest('.inventory-wrapper.inventory.self').length > 0) {
              dropType = 'inventory';
            } else if (dropTarget.closest('.inventory-wrapper.inventory.safe').length > 0) {
              dropType = 'safe';
            } else if (dropTarget.closest('.inventory-wrapper.inventory.half.side').length > 0) {
              dropType = 'container-side';
            } else if (dropTarget.closest('.inventory-wrapper.inventory.side:not(.half)').length > 0) {
              dropType = 'container';
            }
          }
        });
        
        // Si nous avons une cible valide et que la source est différente de la destination
        if (dropTarget && sourceType !== dropType) {
          handleDrop(dragData, dropType);
        }
      }
      
      // Supprimer les classes de surbrillance
      $('.drag-over').removeClass('drag-over');
      
      // Nettoyer
      $clone.remove();
      $(document).off('mousemove.drag mouseup.drag');
    });
    
    // Empêcher le démarrage du drag par défaut du navigateur
    e.preventDefault();
  });
}

function setupDropZone(selector, dropType) {
  $(selector).on('dragover', function(e) {
    e.preventDefault();
  });
}

function handleDrop(dragData, dropType) {
  // Configurer LastData.hangi selon le type de conteneur source
  if (dragData.sourceType === 'inventory') {
    LastData.hangi = 'normal';
  } else if (dragData.sourceType === 'safe') {
    LastData.hangi = 'safe';
  } else if (dragData.sourceType === 'container' || dragData.sourceType === 'container-side') {
    LastData.hangi = 'container';
  }
  
  // En fonction des types source et cible, appeler la fonction appropriée
  if ((dragData.sourceType === 'inventory' && dropType === 'safe') ||
      (dragData.sourceType === 'safe' && dropType === 'inventory')) {
    // Entre l'inventaire et le coffre dans les deux sens
    FastMove(dragData.itemName);
  }
  else if ((dragData.sourceType === 'inventory' && (dropType === 'container' || dropType === 'container-side')) ||
           ((dragData.sourceType === 'container' || dragData.sourceType === 'container-side') && dropType === 'inventory')) {
    // Entre l'inventaire et les conteneurs dans les deux sens
    FastMoveContainer(dragData.itemName, dragData.containerId || '');
  }
}

// Initialiser le drag and drop lors du chargement de la page
$(document).ready(function() {
  initDragAndDrop();
});