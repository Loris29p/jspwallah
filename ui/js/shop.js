window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.type === 'shop') {
        LoadShop(data);
    }
});

// Global variables
let allShopItems = [];
let currentTokens = 0;
let ShiftPressed = false;
let searchTerm = '';

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
    
    // Hide profile and settings when switching to shop
    if (window.HideProfile && typeof window.HideProfile === 'function') {
        window.HideProfile();
    }
    if (window.HideSettings && typeof window.HideSettings === 'function') {
        window.HideSettings();
    }
    
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
        // Hide inventory if it's visible
        $("#inventorydiv").hide();
        $(".leaderboard-section").hide();
        
        // Hide profile and settings when switching to shop
        if (window.HideProfile && typeof window.HideProfile === 'function') {
            window.HideProfile();
        }
        if (window.HideSettings && typeof window.HideSettings === 'function') {
            window.HideSettings();
        }
        
        // Remove current-page class from all menu links
        $(".menu-link").removeClass("current-page");
        // Add current-page class to shop link
        $(".menu-link[onclick='OpenShop()']").addClass("current-page");
        
        // Create shop section if it doesn't exist
        if ($(".shop-section").length === 0) {
            const shopHTML = `
                <div class="shop-section">
                    <div class="shop-header">
                        <h2 class="shop-title">Shop</h2>
                        <div class="shop-tokens">Tokens: <span class="tokens-amount">0</span></div>
                    </div>
                    <div class="shop-search">
                        <input type="text" placeholder="Search items..." onkeyup="SearchItems(this.value)">
                    </div>
                    <div class="shop-controls">
                        <button class="shop-filter-button active" onclick="FilterShopItems('all')">All</button>
                        <button class="shop-filter-button" onclick="FilterShopItems('weapon')">Weapons</button>
                        <button class="shop-filter-button" onclick="FilterShopItems('item')">Items</button>
                        <button class="shop-filter-button" onclick="FilterShopItems('vehicle')">Vehicles</button>
                        <button class="shop-filter-button" onclick="FilterShopItems('heal')">Heal</button>
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

function SearchItems(value) {
    searchTerm = value.toLowerCase();
    FilterShopItems($(".shop-filter-button.active").attr("onclick").match(/'(.*?)'/)[1]);
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
    
    // Apply search filter if there's a search term
    if (searchTerm) {
        filteredItems = filteredItems.filter(item => 
            item.label.toLowerCase().includes(searchTerm) || 
            item.name.toLowerCase().includes(searchTerm)
        );
    }
    
    // Sort items by price (highest to lowest)
    filteredItems.sort((a, b) => {
        const priceA = a.price || 0;
        const priceB = b.price || 0;
        return priceB - priceA; // Sort from highest to lowest price
    });
    
    // Update tokens display
    $(".tokens-amount").text(formatNumberWithCommas(currentTokens));
    
    // Add filtered items
    $.each(filteredItems, function (k, v) {
        if (!v.hide) {
            const formattedPrice = formatNumberWithCommas(v.price);
            const content = `
            <div class="item-shop" data-type="${v.type.toLowerCase()}" onclick="BuyItem('${v.name}', ${v.price})">
                <div class="icon-container">
                    <img class="icon" src="./assets/items/${v.name}.png" alt="${v.label}">
                </div>
                <div class="item-data">
                    <span class="name">${v.label}</span>
                </div>
                <div class="price-container">
                    <span class="price">${formattedPrice}</span>
                </div>
            </div>
            `;
            $(".shop-items-grid").append(content);
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
