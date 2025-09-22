const fakeTableInventory = [
    {
        name: "weapon_pistol",
        label: "Pistol",
        count: 5,
        image: "assets/items/weapon_pistol.png"
    },
    {
        name: "weapon_assaultrifle",
        label: "Assault Rifle",
        count: 1,
        image: "assets/items/weapon_assaultrifle.png"
    },
    {
        name: "weapon_pistol",
        label: "Pistol",
        count: 5,
        image: "assets/items/weapon_pistol.png"
    },
    {
        name: "weapon_assaultrifle",
        label: "Assault Rifle",
        count: 1,
        image: "assets/items/weapon_assaultrifle.png"
    },
    {
        name: "weapon_pistol",
        label: "Pistol",
        count: 5,
        image: "assets/items/weapon_pistol.png"
    },
    {
        name: "weapon_assaultrifle",
        label: "Assault Rifle",
        count: 1,
        image: "assets/items/weapon_assaultrifle.png"
    },
    {
        name: "weapon_pistol",
        label: "Pistol",
        count: 5,
        image: "assets/items/weapon_pistol.png"
    },
]

const fakeTableInventorySafe = [
    {
        name: "weapon_heavysniper",
        label: "AWP",
        count: 1,
        image: "assets/items/weapon_heavysniper.png"
    },
    {
        name: "weapon_pistol",
        label: "Pistol",
        count: 104,
        image: "assets/items/weapon_pistol.png"
    },
    {
        name: "weapon_combatmg_mk2",
        label: "M60 Mk II",
        count: 1,
        image: "assets/items/weapon_combatmg_mk2.png"
    }
]

function formatNumberWithCommas(number) {
    if (!number) return 0;
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

let firstLoadLeaderboard = false;

var tblItems = {};

// Gestionnaire pour Shift + clic molette (bouton du milieu)
window.addEventListener("mousedown", function (event) {
    if (event.shiftKey && event.button === 1) { // button === 1 = bouton du milieu (molette)
        event.preventDefault();

        // Trouver l'élément sous le curseur
        const elementUnderCursor = document.elementFromPoint(event.clientX, event.clientY);

        // Vérifier si c'est un item slot
        if (elementUnderCursor && (elementUnderCursor.classList.contains('item-slot') || elementUnderCursor.closest('.item-slot'))) {
            const itemSlot = elementUnderCursor.classList.contains('item-slot') ? elementUnderCursor : elementUnderCursor.closest('.item-slot');

            if (itemSlot) {
                // Extraire le nom de l'item depuis l'ID
                const itemId = itemSlot.id;
                let itemName = null;
                let invType = null;

                if (itemId.includes('safe-item-slot-')) {
                    itemName = itemId.replace('safe-item-slot-', '');
                    invType = "safe";
                } else if (itemId.includes('item-slot-')) {
                    itemName = itemId.replace('item-slot-', '');
                    invType = "inventory";
                }

                if (itemName && invType) {
                    // Définir hoveredItem temporairement pour MoveAllItems
                    const originalHoveredItem = hoveredItem;
                    hoveredItem = { invType: invType };

                    MoveAllItems(itemName);

                    // Restaurer hoveredItem
                    hoveredItem = originalHoveredItem;
                }
            }
        }
    }
});


window.addEventListener("message", function (event) {
    const data = event.data;
    switch (data.type) {
        case "importItemTbl":
            $.each(data.tbl, function (k, v) {
                tblItems[k] = v;
            });
            // Sort items by price (highest to lowest)
            const sortedItems = Object.keys(tblItems).sort((a, b) => {
                const priceA = tblItems[a].price || 0;
                const priceB = tblItems[b].price || 0;
                return priceB - priceA; // Sort from highest to lowest price
            });
            // Rebuild tblItems with sorted order
            const sortedTblItems = {};
            sortedItems.forEach(key => {
                sortedTblItems[key] = tblItems[key];
            });
            tblItems = sortedTblItems;
            console.log("All items successfully imported and sorted by price");
            break;
        case "display":
            Display(data);
            SetTebexCoins(data.coins);
            break;
        case "updateinventory":
            SetupInventory("inventory", data.inventory);
            SetupInventory("inventory-safe", data.safeinventory);
            break;
        case "updateinventory-safe":
            SetupInventory("inventory-safe", data.inventory);
            break;
        case "inventory":
            SetupInventory("inventory", data.inventory);
            break;
        case "inventory-safe":
            SetupInventory("inventory-safe", data.inventory);
            break;
        case "hotbar":
            LoadShortcut(data.hotbar);
            break;
        case "leaderboard":
            updateLeaderboard("kills", data.podium, data.leaderboard);
            break;
        case "leaderboard-death":
            updateLeaderboard("deaths", data.podium, data.leaderboard);
            break;
        case "leaderboard-token":
            updateLeaderboard("tokens", data.podium, data.leaderboard);
            break;
        case "crew-stats":
            SetLeaderboardCrew(data.crewData, "crew", data.podium);
            break;
        case "stats":
            LoadProfilePlayer(data.playerData);
            break;
        case "updatecombatmode":
            if (data.combatmode == true) {
                CombatMode = true;
            } else {
                CombatMode = false;
            }
            break;
        case "cc":
            DisableUseInventory = data.movestatus;
            break;
    }
});

function LoadProfilePlayer(data) {
    // Redirect to the new profile system
    if (window.LoadProfilePlayer && typeof window.LoadProfilePlayer === 'function') {
        window.LoadProfilePlayer(data);
    } else {
        console.log("Profile system not loaded yet, data:", data);
    }
}

Display = data => {
    if (data.bool) {
        // Hide other sections first
        $(".leaderboard-section").hide();
        $(".crew-big-container").hide();
        $(".shop-section").hide();
        $(".ui-tebex").hide();

        // Hide profile and settings section when opening inventory
        if (window.HideProfile && typeof window.HideProfile === 'function') {
            window.HideProfile();
        }
        if (window.HideSettings && typeof window.HideSettings === 'function') {
            window.HideSettings();
        }

        // Show inventory and setup
        $(".inventorydiv").show();
        SetupInventory("inventory", data.inventory);
        SetupInventory("inventory-safe", data.safeinventory);

        // Update navigation
        $(".menu-link").removeClass("current-page");
        $(".menu-link:contains('INVENTORY')").addClass("current-page");

        $(".ui-body").show();
    } else {
        // Hide profile and settings when closing inventory
        if (window.HideProfile && typeof window.HideProfile === 'function') {
            window.HideProfile();
        }
        if (window.HideSettings && typeof window.HideSettings === 'function') {
            window.HideSettings();
        }
        // Close context menu when closing inventory
        closeContextMenu();
        $(".ui-body").hide();
    }
}

let CanSafeItem = true;
let DisableUseInventory = false;
let CombatMode = false;

var hoveredItem = {};

function SetData(label, itemName, itemCount, invType) {
    hoveredItem = {
        'label': label,
        'name': itemName,
        'count': itemCount,
        'invType': invType
    }
}

function LoadShortcut(hotbar) {
    // Clear existing slots
    $(".shortcut-grid .item-slot").empty();

    // Loop through 7 slots
    for (let i = 0; i < 7; i++) {
        const v = hotbar ? hotbar[i] : null;
        const content = `
            <div class="icon-container">
                <img src="./assets/items/${v ? v.name : ''}.png" alt="${v ? v.label : ''}" class="item-image" ${!v || !v.hasItem ? 'style="display: none;"' : ''}>
            </div>
        `;
        // <span class="slot-number">SLOT ${i + 1}</span>

        // Update the slot content
        $(`#slot-${i}`).html(content);

        // Remove empty class if we have an item
        if (v && v.name && v.hasItem) {
            $(`#slot-${i}`).removeClass('empty');
        } else {
            $(`#slot-${i}`).addClass('empty');
        }
    }
}

function SetupInventory(type, dataInventory) {
    if (type == "inventory") {
        $("#inventory").empty();
        dataInventory.forEach((item) => {
            const itemSlot = `
                <div class="item-slot" id="item-slot-${item.name}" onclick="MoveItem('${item.name}', event)" onmouseenter="SetData('${item.label}', '${item.name}', ${item.count}, 'inventory')">
                    <img src="./assets/items/${item.name}.png" alt="${item.label}" class="item-image">
                    <span class="item-name">${item.label}</span>
                    <span class="item-quantity" id="normal-count-${item.name}">${item.count}x</span>
                </div>
            `;
            $("#inventory").append(itemSlot);
            $("#item-slot-" + item.name).data("item", item.name);
            $("#item-slot-" + item.name).data("count", item.count);
        });
    } else if (type == "inventory-safe") {
        $("#inventory-safe").empty();
        dataInventory.forEach((item) => {
            const itemSlot = `
                <div class="item-slot item-slot-safe" id="safe-item-slot-${item.name}"  onclick="MoveItem('${item.name}', event)" onmouseenter="SetData('${item.label}', '${item.name}', ${item.count}, 'inventory-safe')">
                    <img src="./assets/items/${item.name}.png" alt="${item.label}" class="item-image">
                    <span class="item-name">${item.label}</span>
                    <span class="item-quantity" id="safe-count-${item.name}">${item.count}x</span>
                </div>
            `;
            $("#inventory-safe").append(itemSlot);
            $("#safe-item-slot-" + item.name).data("item", item.name);
            $("#safe-item-slot-" + item.name).data("count", item.count);
        });
    }
}

function MoveItem(item, event) {
    item_id = item;
    which = hoveredItem.invType;

    if (DisableUseInventory == true) {
        return;
    }

    if (typeof which == "undefined" || which == null) {
        return;
    }

    if (CanSafeItem == false) {
        return;
    }

    // Vérifier si Shift + clic molette est pressé pour transférer tout
    if (event && event.shiftKey && event.button === 1) {
        // Transférer tout l'item (Shift + clic molette)
        if (which == "inventory") {
            if (CombatMode == true) {
                return;
            }
            safecount = $("#item-slot-" + item_id).data("count");
            if (safecount > 0) {
                // Sauvegarder la quantité avant de la modifier
                let totalCount = safecount;
                // Transférer tout l'item
                $("#item-slot-" + item_id).data("count", 0);
                $("#item-slot-" + item_id).hide();
                if ($("#safe-item-slot-" + item_id).length > 0) {
                    let safeCount = $('#safe-item-slot-' + item_id).data("count");
                    let updateSafeCount = safeCount + totalCount;
                    $("#safe-item-slot-" + item_id).data("count", updateSafeCount);
                    $("#safe-item-slot-" + item_id).data("item", item_id);
                    document.getElementById("safe-count-" + item_id).innerHTML = updateSafeCount + 'x';
                } else {
                    const content = `
                <div class="item-slot item-slot-safe" id="safe-item-slot-${item_id}"  onclick="MoveItem('${item_id}')" onmouseenter="SetData('${tblItems[item_id].label}', '${item_id}', ${totalCount}, 'inventory-safe')">
                    <img src="./assets/items/${item_id}.png" alt="${tblItems[item_id].label}" class="item-image">
                    <span class="item-name">${tblItems[item_id].label}</span>
                    <span class="item-quantity" id="safe-count-${item_id}">${totalCount}x</span>
                </div>
                `;
                    $("#inventory-safe").append(content);
                }
                $.post("https://gamemode/CheckItems", JSON.stringify({
                    'item': item_id
                }), function (_0x2ed332) { });
            }
        } else if (which == "inventory-safe") {
            safecount = $("#safe-item-slot-" + item_id).data("count");
            if (safecount > 0) {
                // Sauvegarder la quantité avant de la modifier
                let totalCount = safecount;
                // Transférer tout l'item
                $("#safe-item-slot-" + item_id).data("count", 0);
                $("#safe-item-slot-" + item_id).hide();
                if ($("#item-slot-" + item_id).length > 0) {
                    let normalCount = $('#item-slot-' + item_id).data("count");
                    let updateNormalCount = normalCount + totalCount;
                    $("#item-slot-" + item_id).data("count", updateNormalCount);
                    $("#item-slot-" + item_id).data("item", item_id);
                    document.getElementById("normal-count-" + item_id).innerHTML = updateNormalCount + 'x';
                } else {
                    const content = `
                <div class="item-slot" id="item-slot-${item_id}" onclick="MoveItem('${item_id}')" onmouseenter="SetData('${tblItems[item_id].label}', '${item_id}', ${totalCount}, 'inventory')">
                    <img src="./assets/items/${item_id}.png" alt="${tblItems[item_id].label}" class="item-image">
                    <span class="item-name">${tblItems[item_id].label}</span>
                    <span class="item-quantity" id="normal-count-${item_id}">${totalCount}x</span>
                </div>
                `;
                    $("#inventory").append(content);
                }
                $.post("https://gamemode/CheckItems", JSON.stringify({
                    'item': item_id
                }), function (_0x2ed332) { });
            }
        }
        return;
    }

    if (which == "inventory") {
        if (CombatMode == true) {
            return;
        }

        safecount = $("#item-slot-" + item_id).data("count");
        if (safecount > 1) {
            x = safecount - 1;
            check = document.getElementById("normal-count-" + item_id).innerHTML = x + 'x';
            if (typeof check === "undefined" || check === null) {
                return;
            }
            $("#item-slot-" + item_id).data("count", x);
            if ($("#safe-item-slot-" + item_id).length > 0) {
                safecount = $('#safe-item-slot-' + item_id).data("count");
                updatesafecount = safecount + 1;
                $("#safe-item-slot-" + item_id).data("count", updatesafecount);
                $("#safe-item-slot-" + item_id).data("item", item_id);
                document.getElementById("safe-count-" + item_id).innerHTML = updatesafecount + 'x';
                $.post("https://gamemode/CheckItems", JSON.stringify({
                    'item': item_id
                }), function (_0x2ed332) { });
            } else {
                const content = `
            <div class="item-slot item-slot-safe" id="safe-item-slot-${item_id}"  onclick="MoveItem('${item_id}')" onmouseenter="SetData('${tblItems[item_id].label}', '${item_id}', 1, 'inventory-safe')">
                <img src="./assets/items/${item_id}.png" alt="${tblItems[item_id].label}" class="item-image">
                <span class="item-name">${tblItems[item_id].label}</span>
                <span class="item-quantity" id="safe-count-${item_id}">1x</span>
            </div>
            `;
                $("#inventory-safe").append(content);
                $("#safe-item-slot-" + item_id).data("item", item_id);
                $("#safe-item-slot-" + item_id).data("count", 1);
                $.post("https://gamemode/CheckItems", JSON.stringify({
                    'item': item_id
                }), function (_0x5c8bee) { });
            }
        } else {
            if ($("#safe-item-slot-" + item_id).length > 0) {
                safecount = $('#safe-item-slot-' + item_id).data("count");
                updatesafecount = safecount + 1;
                $("#safe-item-slot-" + item_id).data("count", updatesafecount);
                $("#safe-item-slot-" + item_id).data("item", item_id);
                document.getElementById("safe-count-" + item_id).innerHTML = updatesafecount + 'x';
            } else {
                const content = `
            <div class="item-slot item-slot-safe" id="safe-item-slot-${item_id}"  onclick="MoveItem('${item_id}')" onmouseenter="SetData('${tblItems[item_id].label}', '${item_id}', 1, 'inventory-safe')">
                <img src="./assets/items/${item_id}.png" alt="${tblItems[item_id].label}" class="item-image">
                <span class="item-name">${tblItems[item_id].label}</span>
                <span class="item-quantity" id="safe-count-${item_id}">1x</span>
            </div>
            `;
                $("#inventory-safe").append(content);
                $("#safe-item-slot-" + item_id).data("item", item_id);
                $("#safe-item-slot-" + item_id).data("count", 1);
            }
            $("#item-slot-" + item_id).remove();
            $.post("https://gamemode/CheckItems", JSON.stringify({
                'item': item_id
            }), function (_0xa0444a) { });
        }
    } else {
        safecount = $("#safe-item-slot-" + item_id).data("count");
        if (safecount > 1) {
            x = safecount - 1;
            check = document.getElementById("safe-count-" + item_id).innerHTML = x + 'x';
            if (typeof check === "undefined" || check === null) {
                return;
            }
            $("#safe-item-slot-" + item_id).data("count", x);
            if ($("#item-slot-" + item_id).length > 0) {
                f = $('#item-slot-' + item_id).data("count");
                c = f + 1;
                $("#item-slot-" + item_id).data("item", item_id);
                $("#item-slot-" + item_id).data("count", c);
                document.getElementById("normal-count-" + item_id).innerHTML = c + 'x';
                $.post("https://gamemode/CheckItemsSafe", JSON.stringify({
                    'item': item_id
                }), function (_0x2b0547) { });
            } else {
                const content = `
            <div class="item-slot" id="item-slot-${item_id}" onclick="MoveItem('${item_id}')" onmouseenter="SetData('${tblItems[item_id].label}', '${item_id}', ${item.count}, 'inventory')">
                <img src="./assets/items/${item_id}.png" alt="${tblItems[item_id].label}" class="item-image">
                <span class="item-name">${tblItems[item_id].label}</span>
                <span class="item-quantity" id="normal-count-${item_id}">1x</span>
            </div>
            `;
                $("#inventory").append(content);
                $("#item-slot-" + item_id).data("item", item_id);
                $("#item-slot-" + item_id).data("count", 1);
                $.post("https://gamemode/CheckItemsSafe", JSON.stringify({
                    'item': item_id
                }), function (_0x2b0547) { });
            }
        } else {
            if ($("#item-slot-" + item_id).length > 0) {
                za = $('#item-slot-' + item_id).data("count");
                updatesafecount = za + 1;
                $("#item-slot-" + item_id).data("item", item_id);
                $("#item-slot-" + item_id).data("count", updatesafecount);
                document.getElementById("normal-count-" + item_id).innerHTML = updatesafecount + 'x';
            } else {
                const content = `
            <div class="item-slot" id="item-slot-${item_id}" onclick="MoveItem('${item_id}')" onmouseenter="SetData('${tblItems[item_id].label}', '${item_id}', ${item.count}, 'inventory')">
                <img src="./assets/items/${item_id}.png" alt="${tblItems[item_id].label}" class="item-image">
                <span class="item-name">${tblItems[item_id].label}</span>
                <span class="item-quantity" id="normal-count-${item_id}">1x</span>
            </div>
            `;
                $("#inventory").append(content);
                $("#item-slot-" + item_id).data("item", item_id);
                $("#item-slot-" + item_id).data("count", 1);
            }
            $("#safe-item-slot-" + item_id).remove();
            $.post("https://gamemode/CheckItemsSafe", JSON.stringify({
                'item': item_id
            }), function (_0xa0444a) { });
        }
    }
}

function MoveAllItems(item) {
    item_id = item;
    which = hoveredItem.invType;

    if (DisableUseInventory == true) {
        return;
    }

    if (typeof which == "undefined" || which == null) {
        return;
    }

    if (CanSafeItem == false) {
        return;
    }

    if (which == "inventory") {
        if (CombatMode == true) {
            return;
        }

        // Récupérer le nombre total d'items
        const totalCount = $("#item-slot-" + item_id).data("count");
        if (!totalCount || totalCount <= 0) {
            return;
        }

        // Transférer tout d'un coup
        $("#item-slot-" + item_id).remove();

        // Créer ou mettre à jour l'item dans le safe
        if ($("#safe-item-slot-" + item_id).length > 0) {
            const safeCount = $('#safe-item-slot-' + item_id).data("count");
            const newCount = safeCount + totalCount;
            $("#safe-item-slot-" + item_id).data("count", newCount);
            document.getElementById("safe-count-" + item_id).innerHTML = newCount + 'x';
        } else {
            const content = `
            <div class="item-slot item-slot-safe" id="safe-item-slot-${item_id}" onclick="MoveItem('${item_id}', event)" onmouseenter="SetData('${tblItems[item_id].label}', '${item_id}', ${totalCount}, 'inventory-safe')">
                <img src="./assets/items/${item_id}.png" alt="${tblItems[item_id].label}" class="item-image">
                <span class="item-name">${tblItems[item_id].label}</span>
                <span class="item-quantity" id="safe-count-${item_id}">${totalCount}x</span>
            </div>
            `;
            $("#inventory-safe").append(content);
            $("#safe-item-slot-" + item_id).data("item", item_id);
            $("#safe-item-slot-" + item_id).data("count", totalCount);
        }

        // Envoyer la requête pour transférer tout
        $.post("https://gamemode/CheckItemsAll", JSON.stringify({
            'item': item_id,
            'count': totalCount
        }), function (response) { });

    } else {
        // Transférer du safe vers l'inventaire
        const totalCount = $("#safe-item-slot-" + item_id).data("count");
        if (!totalCount || totalCount <= 0) {
            return;
        }

        // Supprimer l'item du safe
        $("#safe-item-slot-" + item_id).remove();

        // Créer ou mettre à jour l'item dans l'inventaire
        if ($("#item-slot-" + item_id).length > 0) {
            const invCount = $('#item-slot-' + item_id).data("count");
            const newCount = invCount + totalCount;
            $("#item-slot-" + item_id).data("count", newCount);
            document.getElementById("normal-count-" + item_id).innerHTML = newCount + 'x';
        } else {
            const content = `
            <div class="item-slot" id="item-slot-${item_id}" onclick="MoveItem('${item_id}', event)" onmouseenter="SetData('${tblItems[item_id].label}', '${item_id}', ${totalCount}, 'inventory')">
                <img src="./assets/items/${item_id}.png" alt="${tblItems[item_id].label}" class="item-image">
                <span class="item-name">${tblItems[item_id].label}</span>
                <span class="item-quantity" id="normal-count-${item_id}">${totalCount}x</span>
            </div>
            `;
            $("#inventory").append(content);
            $("#item-slot-" + item_id).data("item", item_id);
            $("#item-slot-" + item_id).data("count", totalCount);
        }

        // Envoyer la requête pour transférer tout
        $.post("https://gamemode/CheckItemsSafeAll", JSON.stringify({
            'item': item_id,
            'count': totalCount
        }), function (response) { });
    }
}

// Fake data for leaderboard testing
const fakeLeaderboardData = {
    players: [
        { username: "xXShadowKillerXx", kills: 156, death: 45, token: 25000, prestige: 3, country: "FR" },
        { username: "ProGamer123", kills: 142, death: 32, token: 22000, prestige: 2, country: "US" },
        { username: "NightHawk", kills: 138, death: 28, token: 20000, prestige: 1, country: "GB" },
        { username: "StealthMaster", kills: 125, death: 40, token: 18000, prestige: 2, country: "DE" },
        { username: "EliteSniper", kills: 120, death: 35, token: 15000, prestige: 0, country: "ES" }
    ],
    crews: [
        { crewName: "Shadow Warriors", kills: 450, airdrops: 25, redzoneKills: 75, country: "FR" },
        { crewName: "Elite Squad", kills: 380, airdrops: 20, redzoneKills: 60, country: "US" },
        { crewName: "Night Ravens", kills: 350, airdrops: 18, redzoneKills: 55, country: "GB" },
        { crewName: "Ghost Protocol", kills: 320, airdrops: 15, redzoneKills: 45, country: "DE" },
        { crewName: "Phoenix Rising", kills: 300, airdrops: 12, redzoneKills: 40, country: "ES" }
    ]
};

// Cache pour le leaderboard
let leaderboardCache = {
    kills: { podium: null, data: null, timestamp: 0 },
    deaths: { podium: null, data: null, timestamp: 0 },
    tokens: { podium: null, data: null, timestamp: 0 },
    crew: { podium: null, data: null, timestamp: 0 }
};

const CACHE_DURATION = 30000; // 30 secondes de cache

// Ajout des styles pour le loading
const style = document.createElement('style');
style.textContent = `
    .loading-overlay {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.7);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 1000;
    }
    .loading-spinner {
        width: 50px;
        height: 50px;
        border: 3px solid #f3f3f3;
        border-top: 3px solid #dc2626;
        border-radius: 50%;
        animation: spin 1s linear infinite;
    }
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
`;
document.head.appendChild(style);

// Fonction pour montrer/cacher le loading
function toggleLoading(show) {
    const existingOverlay = document.querySelector('.loading-overlay');
    if (show) {
        if (!existingOverlay) {
            const overlay = document.createElement('div');
            overlay.className = 'loading-overlay';
            overlay.innerHTML = '<div class="loading-spinner"></div>';
            document.querySelector('.leaderboard-section').appendChild(overlay);
        }
    } else if (existingOverlay) {
        existingOverlay.remove();
    }
}

// Fonction optimisée pour mettre à jour le leaderboard
// Fonction optimisée pour mettre à jour le leaderboard
function updateLeaderboard(type, podiumData, leaderboardData) {
    // Cache les données
    leaderboardCache[type] = {
        podium: podiumData,
        data: leaderboardData,
        timestamp: Date.now()
    };

    const topPlayers = document.querySelector('.top-players');
    const tableBody = document.querySelector('.leaderboard-table tbody');

    // Update active tab
    document.querySelectorAll('.tab-button').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.type === type) btn.classList.add('active');
    });

    // Clear existing content
    topPlayers.innerHTML = '';
    tableBody.innerHTML = '';

    // Création des templates HTML
    let headerTemplate = '';
    let podiumTemplate = '';
    let tableTemplate = '';

    switch (type) {
        case 'kills':
            headerTemplate = `
                <th>#</th>
                <th>Player</th>
                <th>Kills</th>
                <th>Deaths</th>
                <th>Tokens</th>
                <th>Country</th>
            `;
            break;
        case 'deaths':
            headerTemplate = `
                <th>#</th>
                <th>Player</th>
                <th>Deaths</th>
                <th>Country</th>
            `;
            break;
        case 'tokens':
            headerTemplate = `
                <th>#</th>
                <th>Player</th>
                <th>Tokens</th>
                <th>Country</th>
            `;
            break;
    }

    document.querySelector('.leaderboard-table thead tr').innerHTML = headerTemplate;

    // Construction du podium
    if (podiumData) {
        const podiumHtml = [];
        for (let i = 0; i < Math.min(3, podiumData.length); i++) {
            const player = podiumData[i];
            podiumHtml.push(`
                <div class="top-player-card">
                    <div class="player-rank">Top ${i + 1}</div>
                    <img class="player-flag" src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${player.country.toLowerCase()}.svg" 
                         onerror="this.src='./assets/default-flag.png'">
                    <div class="player-name">${player.username}</div>
                    <div class="player-stats">
                        ${type === 'kills' ? `
                            <div class="stat-item">
                                <div class="stat-value">${player.kills || 0}</div>
                                <div class="stat-label">Kills</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">${player.deaths || player.death || 0}</div>
                                <div class="stat-label">Deaths</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">${formatNumberWithCommas(player.tokens || player.token || 0)}</div>
                                <div class="stat-label">Tokens</div>
                            </div>
                        ` : type === 'deaths' ? `
                            <div class="stat-item">
                                <div class="stat-value">${player.death || 0}</div>
                                <div class="stat-label">Deaths</div>
                            </div>
                        ` : `
                            <div class="stat-item">
                                <div class="stat-value">${formatNumberWithCommas(player.token || 0)}</div>
                                <div class="stat-label">Tokens</div>
                            </div>
                        `}
                    </div>
                </div>`);
        }
        topPlayers.innerHTML = podiumHtml.join('');
    }

    // Construction du tableau
    if (leaderboardData) {
        const tableRows = [];
        for (let i = 0; i < leaderboardData.length; i++) {
            const player = leaderboardData[i];
            tableRows.push(`
                <tr>
                    <td>#${i + 1}</td>
                    <td>
                        <div class="player-info">
                            ${player.prestige > 0 ? `<img class="player-prestige" src="./assets/badges/badge_${player.prestige}.png">` : ''}
                            <span>${player.username}</span>
                        </div>
                    </td>
                    ${type === 'kills' ? `
                        <td>${player.kills || 0}</td>
                        <td>${player.deaths || player.death || 0}</td>
                        <td>${formatNumberWithCommas(player.tokens || player.token || 0)}</td>
                    ` : type === 'deaths' ? `
                        <td>${player.death || 0}</td>
                    ` : `
                        <td>${formatNumberWithCommas(player.token || 0)}</td>
                    `}
                    <td>
                        <img class="country-flag" src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${player.country.toLowerCase()}.svg" 
                             onerror="this.src='./assets/default-flag.png'">
                    </td>
                </tr>`);
        }
        tableBody.innerHTML = tableRows.join('');
    }

    toggleLoading(false);
}

// Fonction optimisée pour sélectionner le leaderboard
function SelectLeaderboard(type) {
    // Vérifie si les données en cache sont encore valides
    const cache = leaderboardCache[type];
    const now = Date.now();

    if (cache && cache.podium && cache.data && (now - cache.timestamp) < CACHE_DURATION) {
        if (type === 'crew') {
            SetLeaderboardCrew(cache.data, type, cache.podium);
        } else {
            updateLeaderboard(type, cache.podium, cache.data);
        }
        return;
    }

    toggleLoading(true);

    // Remove active class from all buttons
    document.querySelectorAll('.tab-button').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.type === type) btn.classList.add('active');
    });

    // Map the type to the correct backend type
    const backendType = {
        'kills': 'player',
        'deaths': 'death',
        'tokens': 'token',
        'crew': 'crew'
    }[type] || 'player';

    // Send request to backend
    $.post("https://gamemode/SelectLeaderboard", JSON.stringify({
        type: backendType
    }));
}

function SetLeaderboardCrew(data, type, podium) {
    // Cache les données
    leaderboardCache.crew = {
        podium: podium,
        data: data,
        timestamp: Date.now()
    };

    const topPlayers = document.querySelector('.top-players');
    const tableBody = document.querySelector('.leaderboard-table tbody');

    // Update active tab
    document.querySelectorAll('.tab-button').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.type === 'crew') btn.classList.add('active');
    });

    // Update table headers
    document.querySelector('.leaderboard-table thead tr').innerHTML = `
        <th>#</th>
        <th>Crew</th>
        <th>Kills</th>
        <th>Airdrops</th>
        <th>Redzone Kills</th>
        <th>Country</th>
    `;

    // Clear existing content
    topPlayers.innerHTML = '';
    tableBody.innerHTML = '';

    // Display top 3 crews
    if (podium && Array.isArray(podium)) {
        const podiumHtml = [];
        for (let i = 0; i < Math.min(3, podium.length); i++) {
            const crew = podium[i];
            if (crew) {
                podiumHtml.push(`
                    <div class="top-player-card">
                        <div class="player-rank">Top ${i + 1}</div>
                        <img class="player-flag" src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${(crew.country || 'fr').toLowerCase()}.svg" 
                             onerror="this.src='./assets/default-flag.png'">
                        <div class="player-name">${crew.crewName || 'Unknown Crew'}</div>
                        <div class="player-stats">
                            <div class="stat-item">
                                <div class="stat-value">${formatNumberWithCommas(crew.kills || 0)}</div>
                                <div class="stat-label">Kills</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">${formatNumberWithCommas(crew.airdrops || 0)}</div>
                                <div class="stat-label">Airdrops</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">${formatNumberWithCommas(crew.redzoneKills || 0)}</div>
                                <div class="stat-label">Redzone</div>
                            </div>
                        </div>
                    </div>`);
            }
        }
        topPlayers.innerHTML = podiumHtml.join('');
    }

    // Add to table
    if (data && Array.isArray(data)) {
        const tableRows = [];
        for (let i = 0; i < data.length; i++) {
            const crew = data[i];
            if (crew) {
                tableRows.push(`
                    <tr>
                        <td>#${i + 1}</td>
                        <td>
                            <div class="player-info">
                                <span>${crew.crewName || 'Unknown Crew'}</span>
                            </div>
                        </td>
                        <td>${formatNumberWithCommas(crew.kills || 0)}</td>
                        <td>${formatNumberWithCommas(crew.airdrops || 0)}</td>
                        <td>${formatNumberWithCommas(crew.redzoneKills || 0)}</td>
                        <td>
                            <img class="country-flag" src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${(crew.country || 'fr').toLowerCase()}.svg" 
                                 onerror="this.src='./assets/default-flag.png'">
                        </td>
                    </tr>`);
            }
        }
        tableBody.innerHTML = tableRows.join('');
    }

    toggleLoading(false);
}

// Context Menu Functions
function createContextMenu() {
    // Add context menu styles if not already added
    if (!$('#context-menu-styles').length) {
        $('head').append(`
            <style id="context-menu-styles">
                .context-menu {
                    position: absolute;
                    background: linear-gradient(135deg, rgba(11, 12, 13, 0.95) 0%, rgba(43, 47, 51, 0.95) 100%);
                    border: 1px solid #2B2F33;
                    border-radius: 0.5vh;
                    width: 25vh;
                    max-height: 30vh;
                    z-index: 1000;
                    overflow: hidden;
                    color: #FFFFFF;
                    font-family: 'Exo', sans-serif;
                    animation: contextMenuFadeIn 0.2s ease forwards;
                }
                
                @keyframes contextMenuFadeIn {
                    from {
                        opacity: 0;
                        transform: scale(0.9) translateY(-1vh);
                    }
                    to {
                        opacity: 1;
                        transform: scale(1) translateY(0);
                    }
                }
                
                .context-menu-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 1vh 1.5vh;
                    background: linear-gradient(90deg, #F31439 0%, #d10e2e 100%);
                    border-bottom: 1px solid #2B2F33;
                    position: relative;
                }
                
                .context-menu-header::after {
                    content: '';
                    position: absolute;
                    bottom: 0;
                    left: 0;
                    right: 0;
                    height: 2px;
                    background: linear-gradient(90deg, transparent 0%, rgba(255, 255, 255, 0.2) 50%, transparent 100%);
                }
                
                .context-menu-title {
                    font-size: 1.2vh;
                    font-weight: 600;
                    color: #FFFFFF;
                    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
                }
                
                .context-menu-close {
                    cursor: pointer;
                    opacity: 0.8;
                    transition: all 0.2s ease;
                    font-size: 1.2vh;
                    width: 2vh;
                    height: 2vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    border-radius: 50%;
                    background: rgba(255, 255, 255, 0.1);
                }
                
                .context-menu-close:hover {
                    opacity: 1;
                    background: rgba(255, 255, 255, 0.2);
                    transform: scale(1.1);
                }
                
                .context-menu-body {
                    max-height: 25vh;
                    overflow-y: auto;
                    padding: 0.5vh 0;
                }
                
                .context-menu-body::-webkit-scrollbar {
                    width: 0.5vh;
                }
                
                .context-menu-body::-webkit-scrollbar-track {
                    background: rgba(43, 47, 51, 0.3);
                }
                
                .context-menu-body::-webkit-scrollbar-thumb {
                    background: #F31439;
                    border-radius: 0.25vh;
                }
                
                .players-table {
                    width: 100%;
                    border-collapse: collapse;
                }
                
                .players-table th {
                    padding: 0.8vh 1.5vh;
                    text-align: left;
                    font-size: 1vh;
                    color: #909090;
                    text-transform: uppercase;
                    font-weight: 500;
                    background: rgba(43, 47, 51, 0.3);
                    border-bottom: 1px solid #2B2F33;
                }
                
                .players-table td {
                    padding: 0.8vh 1.5vh;
                    font-size: 1.1vh;
                    border-bottom: 1px solid rgba(43, 47, 51, 0.3);
                }
                
                .players-table tr {
                    cursor: pointer;
                    transition: all 0.2s ease;
                    position: relative;
                }
                
                .players-table tbody tr:hover {
                    background: linear-gradient(90deg, rgba(243, 20, 57, 0.1) 0%, rgba(243, 20, 57, 0.05) 100%);
                    transform: translateX(0.3vh);
                }
                
                .players-table tbody tr:hover::before {
                    content: '';
                    position: absolute;
                    left: 0;
                    top: 0;
                    bottom: 0;
                    width: 3px;
                    background: #F31439;
                }
                
                .player-username {
                    font-weight: 600;
                    color: #FFFFFF;
                }
                
                .player-uuid {
                    color: #909090;
                    font-family: 'Exo', sans-serif;
                    font-size: 0.9vh;
                }
                
                .player-id {
                    color: #F31439;
                    font-weight: 600;
                }
                
                .no-players-message {
                    text-align: center;
                    padding: 2vh 1vh;
                    color: #909090;
                    font-style: italic;
                    font-size: 1vh;
                }
                
                .context-menu-overlay {
                    position: fixed;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    z-index: 999;
                    background: rgba(0, 0, 0, 0.1);
                }
            </style>
        `);
    }
}

function closeContextMenu() {
    $('.context-menu-overlay').remove();
    $('#player-context-menu').remove();
}

function getPlayersList() {
    let playersList = [];

    $.ajax({
        url: "https://gamemode/GetListPlayers",
        type: "POST",
        async: false,
        data: JSON.stringify({}),
        success: function (response) {
            if (response && response.length > 0) {
                playersList = response;
            }
        },
        error: function () {
            console.log("Failed to get players list");
        }
    });

    if (playersList.length === 0) {
        return [];
    }

    return playersList;
}

function showContextMenu(e, itemName, itemCount, itemLabel) {
    // Close any existing context menu
    closeContextMenu();

    // Create context menu
    createContextMenu();

    // Create overlay
    const overlay = $('<div class="context-menu-overlay"></div>');
    $('body').append(overlay);

    const contextMenu = $(`
        <div id="player-context-menu" class="context-menu">
            <div class="context-menu-header">
                <div class="context-menu-title">Give ${itemLabel} to Player</div>
                <div class="context-menu-close">✕</div>
            </div>
            <div class="context-menu-body">
                <table class="players-table">
                    <thead>
                        <tr>
                            <th>Player</th>
                            <th>UUID</th>
                            <th>ID</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Players will be added here -->
                    </tbody>
                </table>
            </div>
        </div>
    `);

    // Position the context menu
    $('body').append(contextMenu);

    // Get players list
    const playersList = getPlayersList();
    const tbody = contextMenu.find('tbody');

    if (playersList.length === 0) {
        tbody.append(`
            <tr>
                <td colspan="3" class="no-players-message">
                    <i class="fas fa-users"></i><br>
                    No players nearby
                </td>
            </tr>
        `);
    } else {
        $.each(playersList, function (i, player) {
            const row = $(`
                <tr data-id="${player.id}" data-uuid="${player.uuid}" data-username="${player.username}">
                    <td class="player-username">${player.username}</td>
                    <td class="player-uuid">${player.uuid}</td>
                    <td class="player-id">${player.id}</td>
                </tr>
            `);
            tbody.append(row);
        });
    }

    // Position the menu near the cursor but ensure it stays within viewport
    const menuWidth = contextMenu.outerWidth();
    const menuHeight = contextMenu.outerHeight();
    const windowWidth = $(window).width();
    const windowHeight = $(window).height();

    let left = e.pageX + 10;
    let top = e.pageY + 10;

    // Adjust if menu would go off screen
    if (left + menuWidth > windowWidth) {
        left = e.pageX - menuWidth - 10;
    }
    if (top + menuHeight > windowHeight) {
        top = e.pageY - menuHeight - 10;
    }

    contextMenu.css({
        top: top + 'px',
        left: left + 'px'
    });

    // Event handlers
    contextMenu.find('.context-menu-close').on('click', closeContextMenu);
    overlay.on('click', closeContextMenu);

    // Handle player selection
    contextMenu.find('tbody tr').on('click', function () {
        const playerId = $(this).data('id');
        const playerUuid = $(this).data('uuid');
        const playerUsername = $(this).data('username');

        if (!playerId || playerId === 0) {
            closeContextMenu();
            return;
        }

        // Send request to server
        $.post("https://gamemode/GiveItemToPlayer", JSON.stringify({
            item: itemName,
            count: itemCount,
            playerId: playerId,
            playerUuid: playerUuid
        }));

        closeContextMenu();
    });

    // Auto-close after 15 seconds
    setTimeout(closeContextMenu, 15000);
}

// Track double right click
let lastRightClickTime = 0;
let lastRightClickTarget = null;

// Add middle mouse button (wheel click) handler for taking all items
$(document).on("mousedown", ".item-slot", function(e) {
    // Middle mouse button (wheel click) with Shift = take all items
    if (e.which === 2 && e.shiftKey) {
        e.preventDefault();

        const itemName = $(this).data("item");
        const itemCount = $(this).data("count");
        const isInSafe = $(this).closest("#inventory-safe").length > 0;

        if (itemName && itemCount > 1) {
            // Simulate taking all items by triggering MoveItem with count
            for (let i = 0; i < itemCount; i++) {
                setTimeout(() => {
                    // Set the correct hover data for MoveItem
                    if (isInSafe) {
                        hoveredItem = {
                            name: itemName,
                            invType: 'inventory-safe'
                        };
                    } else {
                        hoveredItem = {
                            name: itemName,
                            invType: 'inventory'
                        };
                    }
                    MoveItem(itemName);
                }, i * 50); // Small delay between each item transfer
            }
        }
        return false;
    }
});

// Add context menu event handlers
$(document).on("contextmenu", ".item-slot", function (e) {
    // Only handle right-click on inventory items (not safe inventory)
    if ($(this).closest("#inventory").length === 0) {
        return;
    }

    // Double right click detection (delete item)
    const currentTime = Date.now();
    const timeDiff = currentTime - lastRightClickTime;
    const isSameTarget = lastRightClickTarget === this;

    if (timeDiff < 500 && isSameTarget) { // 500ms for double click
        e.preventDefault();
        const itemName = $(this).data("item");
        if (itemName) {
            // Double right click = delete item
            $.post("https://gamemode/deleteItem", JSON.stringify({
                item: itemName,
            }));
        }
        lastRightClickTime = 0;
        lastRightClickTarget = null;
        return;
    }

    lastRightClickTime = currentTime;
    lastRightClickTarget = this;

    if (!e.ctrlKey) {
        e.preventDefault();

        const itemName = $(this).data("item");
        const itemCount = $(this).data("count");

        if (itemName && itemCount) {
            // Get item label from tblItems
            const itemLabel = tblItems[itemName] ? tblItems[itemName].label : itemName;
            showContextMenu(e, itemName, itemCount, itemLabel);
        }
    } else {
        // Ctrl + Right click to delete item  (kept for backwards compatibility)
        e.preventDefault();
        const itemName = $(this).data("item");

        if (itemName) {
            $.post("https://gamemode/deleteItem", JSON.stringify({
                item: itemName,
            }));
        }
    }
});

// Close context menu when inventory is closed
$(document).on("keyup", function (e) {
    $.each(Config.CloseKeys, function (k, v) {
        if (e.key == v) {
            closeContextMenu();
        }
    });
});

// Add click handlers for navigation
$(document).ready(function () {
    SetupInventory("inventory", fakeTableInventory);
    SetupInventory("inventory-safe", fakeTableInventorySafe);

    // Initialize empty shortcuts
    LoadShortcut();

    // Hide sections initially except inventory
    $(".leaderboard-section").hide();
    $(".crew-big-container").hide();
    $(".shop-section").hide();

    // Add responsive handler for window resize
    $(window).on('resize', function () {
        adjustInventoryLayout();
    });

    // Initial layout adjustment
    adjustInventoryLayout();

    // Add click handlers for navigation
    $(".menu-link").click(function (e) {
        e.preventDefault();
        const page = $(this).text().toLowerCase();

        // Remove current-page class from all links
        $(".menu-link").removeClass("current-page");
        // Add current-page class to clicked link
        $(this).addClass("current-page");

        // Hide all sections first
        $(".inventorydiv").hide();
        $(".leaderboard-section").hide();
        $(".shop-section").hide();
        $(".ui-tebex").hide();
        $(".crew-big-container").hide();

        if (page === "leaderboard") {
            // Hide profile and settings when switching to leaderboard
            if (window.HideProfile && typeof window.HideProfile === 'function') {
                window.HideProfile();
            }
            if (window.HideSettings && typeof window.HideSettings === 'function') {
                window.HideSettings();
            }
            $(".leaderboard-section").show();
            SelectLeaderboard('kills');
        } else if (page === "inventory") {
            // Hide profile and settings when switching to inventory
            if (window.HideProfile && typeof window.HideProfile === 'function') {
                window.HideProfile();
            }
            if (window.HideSettings && typeof window.HideSettings === 'function') {
                window.HideSettings();
            }
            $(".inventorydiv").show();
        } else if (page === "tebex") {
            // Hide profile and settings when switching to tebex
            if (window.HideProfile && typeof window.HideProfile === 'function') {
                window.HideProfile();
            }
            if (window.HideSettings && typeof window.HideSettings === 'function') {
                window.HideSettings();
            }
            ShowTebex();
        } else if (page === "profil" || page === "profile") {
            // Hide settings when switching to profile
            if (window.HideSettings && typeof window.HideSettings === 'function') {
                window.HideSettings();
            }
            if (window.ShowProfile && typeof window.ShowProfile === 'function') {
                window.ShowProfile();
            } else {
                console.log("Profile system not loaded yet");
            }
        } else if (page === "crew") {
            // Hide profile and settings when switching to crew
            if (window.HideProfile && typeof window.HideProfile === 'function') {
                window.HideProfile();
            }
            if (window.HideSettings && typeof window.HideSettings === 'function') {
                window.HideSettings();
            }
            // For now, crew functionality is not implemented
            $(".crew-big-container").show();
            fetchCrewData();
        } else if (page === "settings") {
            // Hide profile when switching to settings
            if (window.HideProfile && typeof window.HideProfile === 'function') {
                window.HideProfile();
            }
            if (window.ShowSettings && typeof window.ShowSettings === 'function') {
                window.ShowSettings();
            } else {
                console.log("Settings system not loaded yet");
            }
        }
        // Note: Shop visibility is handled by its own OpenShop function
    });

    // Add click handlers for leaderboard tabs
    $('.tab-button').click(function () {
        SelectLeaderboard($(this).data('type'));
    });

    // Also use event delegation to ensure it works even if elements are added dynamically
    $(document).on('click', '.tab-button', function () {
        SelectLeaderboard($(this).data('type'));
    });

    // Initialize drag and drop
    initDragAndDrop();
});

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


$(document).on("keyup", function (e) {
    $.each(HotBarKeys, function (k, v) {
        if (e.which == k && hoveredItem) {
            if (typeof hoveredItem.name == "undefined" || hoveredItem.name == null) {
                return;
            }

            if (hoveredItem.invType == "inventory-safe") {
                return;
            }
            $.post("https://gamemode/SetHotbar", JSON.stringify({ id: v, itemName: hoveredItem.name }));
        }
    });
    $.each(Config.CloseKeys, function (k, v) {
        if (e.key == v) {
            $.post("https://gamemode/Close");
        }
    });
})

function SetPodiumLeaderbard(data, type) {
    $(".leaderboard-podium").empty();

    if (type === "player-killed") {
        data.forEach((v, k) => {
            const content = `
            <div class="leaderboard-player">
                <div class="picture-profil">
                    <img class="image" src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${v.country.toLowerCase()}.svg" onerror="this.src='./assets/default-avatar.jpg';">
                </div>
                <span class="rank">Top ${k + 1}</span>
                <div class="player-info">
                    <span class="player-name">
                        <span class="color" style="color: #8b8378">${v.username}</span>
                    </span>
                </div>
                <div class="player-points">
                    <span class="points">${v.kills}</span>
                    <span class="points-label">Players killed</span>
                </div>
            </div>`;
            $(".leaderboard-podium").append(content);
        });
    } else if (type === "player-death") {
        data.forEach((v, k) => {
            const content = `
            <div class="leaderboard-player">
                <div class="picture-profil">
                    <img class="image" src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${v.country.toLowerCase()}.svg" onerror="this.src='./assets/default-avatar.jpg';">
                </div>
                <span class="rank">Top ${k + 1}</span>
                <div class="player-info">
                    <span class="player-name">
                        <span class="color" style="color: #8b8378">${v.username}</span>
                    </span>
                </div>
                <div class="player-points">
                    <span class="points">${v.death}</span>
                    <span class="points-label">Deaths</span>
                </div>
            </div>`;
            $(".leaderboard-podium").append(content);
        });
    } else if (type === "player-token") {
        data.forEach((v, k) => {
            const tokenVARIABLE = formatNumberWithCommas(v.token);
            const content = `
            <div class="leaderboard-player">
                <div class="picture-profil">
                    <img class="image" src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${v.country.toLowerCase()}.svg" onerror="this.src='./assets/default-avatar.jpg';">
                </div>
                <span class="rank">Top ${k + 1}</span>
                <div class="player-info">
                    <span class="player-name">
                        <span class="color" style="color: #8b8378">${v.username}</span>
                    </span>
                </div>
                <div class="player-points">
                    <span class="points">${tokenVARIABLE}</span>
                    <span class="points-label">Guild Token</span>
                </div>
            </div>`;
            $(".leaderboard-podium").append(content);
        });
    }
}

function SetLeaderboard(data, type) {
    const tbody = document.querySelector('.ui-table tbody');
    if (tbody) {
        tbody.innerHTML = '';
    }

    if (type === "player-killed") {
        data.forEach((v, k) => {
            const content = `
            <tr>
                <td class="rank-column">#${k + 1}</td>
                <td class="name-column">
                    <div style="display: flex; flex-direction: row; align-items: center; padding-left: 8px;">
                        <div class="game-badge leaderboard-badge">
                            ${v.prestige > 0 ? `<img alt="" src="./assets/badges/badge_${v.prestige}.png" style="margin-left: 10px; margin-right: 8px;">` : ''}
                        </div>
                        <span class="leaderboard-name">
                            <span class="color" style="color: #8b8378">${v.username}</span>
                        </span>
                    </div>
                </td>
                <td class="total-column">${v.kills}</td>
                <td class="right-cell" style="text-align: right; padding-right: 3vh;">
                    <img class="country-flag-cell" src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${v.country.toLowerCase()}.svg" onerror="this.style.display='none'; this.parentNode.textContent='${v.country}';">
                </td>
            </tr>`;
            $(".ui-table tbody").append(content);
        });
    } else if (type === "player-death") {
        data.forEach((v, k) => {
            const content = `
            <tr>
                <td class="rank-column">#${k + 1}</td>
                <td class="name-column">
                    <div style="display: flex; flex-direction: row; align-items: center; padding-left: 8px;">
                        <div class="game-badge leaderboard-badge">
                            ${v.prestige > 0 ? `<img alt="" src="./assets/badges/badge_${v.prestige}.png" style="margin-left: 10px; margin-right: 8px;">` : ''}
                        </div>
                        <span class="leaderboard-name">
                            <span class="color" style="color: #8b8378">${v.username}</span>
                        </span>
                    </div>
                </td>
                <td class="total-column">${v.death}</td>
                <td class="right-cell" style="text-align: right; padding-right: 3vh;">
                    <img class="country-flag-cell" src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${v.country.toLowerCase()}.svg" onerror="this.style.display='none'; this.parentNode.textContent='${v.country}';">
                </td>
            </tr>`;
            $(".ui-table tbody").append(content);
        });
    } else if (type === "player-token") {
        data.forEach((v, k) => {
            const tokenVARIABLE = formatNumberWithCommas(v.token);
            const content = `
            <tr>
                <td class="rank-column">#${k + 1}</td>
                <td class="name-column">
                    <div style="display: flex; flex-direction: row; align-items: center; padding-left: 8px;">
                        <div class="game-badge leaderboard-badge">
                            ${v.prestige > 0 ? `<img alt="" src="./assets/badges/badge_${v.prestige}.png" style="margin-left: 10px; margin-right: 8px;">` : ''}
                        </div>
                        <span class="leaderboard-name">
                            <span class="color" style="color: #8b8378">${v.username}</span>
                        </span>
                    </div>
                </td>
                <td class="total-column">${tokenVARIABLE}</td>
                <td class="right-cell" style="text-align: right; padding-right: 3vh;">
                    <img class="country-flag-cell" src="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/flags/4x3/${v.country.toLowerCase()}.svg" onerror="this.style.display='none'; this.parentNode.textContent='${v.country}';">
                </td>
            </tr>`;
            $(".ui-table tbody").append(content);
        });
    }
}

// Variables globales pour le drag and drop
var LastData = {};

// Function to adjust inventory layout based on screen size (keep 7 columns, only scale)
function adjustInventoryLayout() {
    // Only reinitialize drag and drop, no column changes
    initDragAndDrop();
}

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
    // background-color: rgba(255, 255, 255, 0.1) !important;
  }
  
  .shortcut-grid .item-slot.drag-over {
    // background-color: rgba(50, 50, 50, 0.4) !important;
  }
  
  /* Keep 7 columns at all screen sizes, only scale item sizes */
</style>
`);

// Initialiser le drag and drop
function initDragAndDrop() {
    // Rendre les éléments draggable
    setupDraggable('#inventory .item-slot', 'inventory');
    setupDraggable('#inventory-safe .item-slot', 'safe');

    // Ajouter les emplacements de la hotbar comme zones de Depot
    setupHotbarDropZones();
}

function setupHotbarDropZones() {
    // Enlever tous les gestionnaires d'événements existants pour éviter les doublons
    $('.shortcut-grid .item-slot').off('mouseenter.hotbar mouseleave.hotbar');

    // Configurer chaque emplacement de la hotbar comme zone de Depot
    $('.shortcut-grid .item-slot').each(function (index) {
        $(this).on('mouseenter.hotbar', function () {
            if ($('.dragging').length > 0) {
                $(this).addClass('drag-over');
            }
        }).on('mouseleave.hotbar', function () {
            $(this).removeClass('drag-over');
        });
    });
}

function setupDraggable(selector, sourceType) {
    // Supprimer d'abord les gestionnaires existants pour éviter les doublons
    $(document).off('mousedown', selector);

    $(document).on('mousedown', selector, function (e) {
        // Seulement démarrer le drag avec le clic gauche (button 0)
        if (e.button !== 0) return;

        const $this = $(this);
        const itemName = $this.data('item');
        const itemCount = $this.data('count');

        if (!itemName) return;

        // Stocker temporairement que nous sommes en train de déplacer cet élément
        // pour que LastData.hangi soit correctement défini lors du drop
        if (sourceType === 'inventory') {
            LastData.hangi = 'normal';
            hoveredItem = {
                name: itemName,
                invType: 'inventory'
            };
        } else if (sourceType === 'safe') {
            LastData.hangi = 'safe';
            hoveredItem = {
                name: itemName,
                invType: 'inventory-safe'
            };
        }

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

        $('body').append($clone);

        // Stocker des données pour le drag
        const dragData = {
            sourceElement: $this,
            clone: $clone,
            sourceType: sourceType,
            itemName: itemName,
            itemCount: itemCount,
            startX: e.pageX,
            startY: e.pageY,
            offsetX: e.pageX - $this.offset().left,
            offsetY: e.pageY - $this.offset().top
        };

        // Attacher les événements de mouvement à document
        $(document).on('mousemove.drag', function (e) {
            $clone.css({
                top: e.pageY - dragData.offsetY,
                left: e.pageX - dragData.offsetX
            });

            // Gérer la surbrillance des emplacements
            $('.item-slot, .shortcut-grid .item-slot').each(function () {
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

        $(document).on('mouseup.drag', function (e) {
            // Vérifier si on a déposé sur un emplacement de la hotbar
            let droppedOnHotbar = false;

            $('.shortcut-grid .item-slot').each(function (index) {
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
                    $.post("https://gamemode/SetHotbar", JSON.stringify({
                        id: slotNumber,
                        itemName: dragData.itemName
                    }));

                    return false; // Sortir de la boucle each
                }
            });

            // Si on n'a pas déposé sur un emplacement de la hotbar, vérifier les autres conteneurs
            if (!droppedOnHotbar) {
                // Déterminer la zone de Depot
                let dropTarget = null;
                let dropType = null;

                // Vérifier les conteneurs valides
                $('#inventory, #inventory-safe').each(function () {
                    const rect = this.getBoundingClientRect();
                    if (
                        e.clientX >= rect.left &&
                        e.clientX <= rect.right &&
                        e.clientY >= rect.top &&
                        e.clientY <= rect.bottom
                    ) {
                        dropTarget = $(this);

                        // Déterminer le type de drop zone
                        if (dropTarget.attr('id') === 'inventory') {
                            dropType = 'inventory';
                        } else if (dropTarget.attr('id') === 'inventory-safe') {
                            dropType = 'safe';
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

function handleDrop(dragData, dropType) {
    // Configurer LastData.hangi selon le type de conteneur source
    if (dragData.sourceType === 'inventory') {
        LastData.hangi = 'normal';
    } else if (dragData.sourceType === 'safe') {
        LastData.hangi = 'safe';
    }

    // Configurer hoveredItem pour la compatibilité avec MoveItem
    if (dragData.sourceType === 'inventory') {
        hoveredItem = {
            name: dragData.itemName,
            invType: 'inventory'
        };
    } else if (dragData.sourceType === 'safe') {
        hoveredItem = {
            name: dragData.itemName,
            invType: 'inventory-safe'
        };
    }

    // En fonction des types source et cible, appeler la fonction appropriée
    if ((dragData.sourceType === 'inventory' && dropType === 'safe') ||
        (dragData.sourceType === 'safe' && dropType === 'inventory')) {
        // Entre l'inventaire et le coffre dans les deux sens
        MoveItem(dragData.itemName);
    }
}