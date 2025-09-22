window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.type === 'shop') {
        LoadShop(data);
    }
});

// Variable globale pour stocker tous les articles du shop
let allShopItems = [];
let currentTokens = 0;
let ShiftPressed = false; // Added variable to track shift key state

// Add event listeners for shift key
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

function LoadShop(data) {
    if (data.bool) {
        console.log("SHOW")
        $(".ui-body").show();
        $(".ui-shop").css("display", "flex");
        ChangePages('shop-weapon')
        $(".ui-shop .items-shop.primary .ui-title-container .subtitle").text("Tokens: " + data.tokens);
        $(".items-shop-content .content-shop-items .item-shop").remove();

        // Stocker tous les articles et les tokens
        allShopItems = data.shopsItems;
        currentTokens = data.tokens;

        // Afficher tous les articles par défaut
        FilterShopItems('all');
    } else {
        $(".ui-shop").css("display", "none");
        $(".items-shop-content .content-shop-items .item-shop").remove();
    }
}

// Fonction pour filtrer les articles en fonction du type
function FilterShopItems(filterType) {
    // Mettre à jour les classes des boutons
    $(".header-buttons .ui-button").removeClass("primary");
    $(`.header-buttons .ui-button[onclick="FilterShopItems('${filterType}')"]`).addClass("primary");
    
    // Effacer tous les articles actuellement affichés
    $(".items-shop-content .content-shop-items .item-shop").remove();
    
    // Filtrer et afficher les articles
    let filteredItems = allShopItems;
    if (filterType !== 'all') {
        filteredItems = allShopItems.filter(item => item.type.toLowerCase() === filterType.toLowerCase());
    }
    
    // Mettre à jour l'affichage des tokens
    $(".ui-shop .items-shop.primary .ui-title-container .subtitle").text("Tokens: " + currentTokens);
    
    // Ajouter les articles filtrés au DOM
    $.each(filteredItems, function (k, v) {
        if (!v.hide) {
            const formattedPrice = formatNumberWithCommas(v.price);
            const content = `
            <div class="item-shop" data-type="${v.type.toLowerCase()}" onclick="BuyItem('${v.name}', ${v.price})">
            <div class="icon-container">
                <img class="icon" src="./assets/items/${v.name}.png">
            </div>
            <div class="item-data">
                <span class="name">${v.label}</span>
            </div>
            <div class="price-container">
                <span class="price">${formattedPrice}</span>
            </div>
        </div>
        `;
            $(".items-shop-content .content-shop-items").append(content);
        }
    });
}

function BuyItem(item, price) {
    $.post('https://gamemode/buyItem', JSON.stringify({
        item: item,
        price: price,
        shift: ShiftPressed? true : false
    }));
}   

function SellAll() {
    $.post('https://gamemode/sellAll', JSON.stringify({}));
}