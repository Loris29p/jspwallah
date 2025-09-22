window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.type === 'shop') {
        LoadShop(data)
    }
});

// Global variables
let allShopItems = [];
let currentTokens = 0;
let ShiftPressed = false;

// Shift key event listeners
document.addEventListener('keydown', function(e) {
    if (e.key === 'Shift') {
        ShiftPressed = true;
    }
});

document.addEventListener('keyup', function(e) {
    if (e.key === 'Shift') {
        ShiftPressed = false;
    }
});

function formatNumberWithCommas(number) {
    if (!number) return 0;
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function OpenShop() {
    // Hide inventory if it's visible
    $("#inventorydiv").hide();
    $(".leaderboard-section").hide();
    
    // Remove current-page class from all menu links
    $(".menu-link").removeClass("current-page");
    // Add current-page class to shop link
    $(".menu-link[onclick='OpenShop()']").addClass("current-page");
    
    // Post to backend to request shop data
    $.post('https://gamemode/openShop', JSON.stringify({}));
}

function LoadShop(data) {
    if (data.bool) {
        $(".ui-body").show();
        
        // Create shop section if it doesn't exist
        if ($(".shop-section").length === 0) {
            const shopHTML = `
                <div class="shop-section">
                    <div class="shop-header">
                        <h2 class="shop-title">Shop</h2>
                        <div class="shop-tokens">Tokens: <span class="tokens-amount">0</span></div>
                    </div>
                    <div class="shop-controls">
                        <button class="shop-filter-button active" onclick="FilterShopItems('all')">All</button>
                        <button class="shop-filter-button" onclick="FilterShopItems('weapon')">Weapons</button>
                        <button class="shop-filter-button" onclick="FilterShopItems('item')">Items</button>
                        <button class="shop-filter-button" onclick="FilterShopItems('vehicle')">Vehicles</button>
                        <button class="sell-all-button" onclick="SellAll()">Sell All</button>
                    </div>
                    <div class="shop-items-grid"></div>
                </div>
            `;
            $(".ui-body").append(shopHTML);
        }

        // Show shop section
        $(".shop-section").show();

        // Update tokens display
        $(".tokens-amount").text(formatNumberWithCommas(data.tokens));
        
        // Store shop data
        allShopItems = data.shopsItems;
        currentTokens = data.tokens;

        // Show initial items
        FilterShopItems('all');
    } else {
        $(".shop-section").hide();
    }
}

function FilterShopItems(filterType) {
    // Update active button
    $(".shop-filter-button").removeClass("active");
    $(`.shop-filter-button[onclick="FilterShopItems('${filterType}')"]`).addClass("active");
    
    // Clear current items
    $(".shop-items-grid").empty();
    
    // Filter items
    let filteredItems = allShopItems;
    if (filterType !== 'all') {
        filteredItems = allShopItems.filter(item => item.type.toLowerCase() === filterType.toLowerCase());
    }
    
    // Update tokens display
    $(".tokens-amount").text(formatNumberWithCommas(currentTokens));
    
    // Add filtered items
    filteredItems.forEach(item => {
        if (!item.hide) {
            const formattedPrice = formatNumberWithCommas(item.price);
            const itemHTML = `
                <div class="shop-item" onclick="BuyItem('${item.name}', ${item.price})">
                    <img class="shop-item-image" src="./assets/items/${item.name}.png" alt="${item.label}">
                    <div class="shop-item-details">
                        <span class="shop-item-name">${item.label}</span>
                        <span class="shop-item-type">${item.type}</span>
                        <span class="shop-item-price">${formattedPrice} Tokens</span>
                    </div>
                    <span class="shop-item-buy">Buy</span>
                </div>
            `;
            $(".shop-items-grid").append(itemHTML);
        }
    });
}

function BuyItem(item, price) {
    $.post('https://gamemode/buyItem', JSON.stringify({
        item: item,
        price: price,
        shift: ShiftPressed ? true : false
    }));
}   

function SellAll() {
    $.post('https://gamemode/sellAll', JSON.stringify({}));
} 