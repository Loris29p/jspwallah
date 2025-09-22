// Tebex Page JavaScript
let currentTebexCategory = 'rank';
let isBuyingTebexItem = false;

function formatNumberWithCommas(number) {
    if (!number) return 0;
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// Configuration for ranks (same as donator.js)
const tebexRankConfig = {
    ranks: [
      {
        nameRank: "VIP",
        descriptionRank: "🟨 VIP rank in-game & discord",
        price: "7.00€",
        advantages: [
          {description: "Discord role & chat color", check: true},
          {description: "Unlock all player models", check: true},
          {description: "Speed boost in safe-zones & lobby", check: false},
          {description: "FX Effect (/killeffect) on the player you killed", check: false},
          {description: "Custom message after killing a player", check: false},
          {description: "Kit", text: "VIP"},
          {description: "Heal & Armor more faster", text: "2.3sec & 1.3sec"},
          {description: "XP Boost", text: "1.25%"},
          {description: "Unlimited /reset_stats", check: false},
        ]
      },
      {
        nameRank: "VIP +",
        descriptionRank: " 🟩 VIP+ rank in-game & discord",
        price: "10.00€",
        advantages: [
          {description: "Discord role & chat color", check: true},
          {description: "Unlock all player models", check: true},
          {description: "Speed boost in safe-zones & lobby", check: true},
          {description: "FX Effect (/killeffect) on the player you killed", check: true},
          {description: "Custom message after killing a player", check: true},
          {description: "Kit", text: "VIP+"},
          {description: "Heal & Armor more faster", text: "2.1sec & 1.1sec"},
          {description: "XP Boost", text: "1.25%"},
          {description: "Unlimited /reset_stats", check: false},
        ]
      },
      {
        nameRank: "MVP",
        descriptionRank: "🟦 MVP rank in-game & discord",
        price: "14.00€",
        advantages: [
          {description: "Discord role & chat color", check: true},
          {description: "Unlock all player models", check: true},
          {description: "Speed boost in safe-zones & lobby", check: true},
          {description: "FX Effect (/killeffect) on the player you killed", check: true},
          {description: "Custom message after killing a player", check: true},
          {description: "Kit", text: "MVP"},
          {description: "Heal & Armor more faster", text: "1.9sec & 0.9sec"},
          {description: "XP Boost", text: "1.50%"},
          {description: "Unlimited /reset_stats", check: true},
        ]
      },
      {
        nameRank: "BOSS",
        descriptionRank: "🧡 BOSS rank in-game & discord",
        price: "17.00€",
        advantages: [
          {description: "Discord role & chat color", check: true},
          {description: "Unlock all player models", check: true},
          {description: "Speed boost in safe-zones & lobby", check: true},
          {description: "FX Effect (/killeffect) on the player you killed", check: true},
          {description: "Custom message after killing a player", check: true},
          {description: "Kit", text: "BOSS"},
          {description: "Heal & Armor more faster", text: "1.9sec & 0.9sec"},
          {description: "XP Boost", text: "1.50%"},
          {description: "Unlimited /reset_stats", check: true},
        ]
      }
    ]
};


const tebexTokenConfig = {
    tokens: [
      {
        price: "3.99€",
        tokens_description: "1.000.000 Tokens",
      },
      {
        price: "8.99€",
        tokens_description: "2.000.000 Tokens",
      },
      {
        price: "13.99€",
        tokens_description: "5.000.000 Tokens",
      },
      {
        price: "18.99€",
        tokens_description: "10.000.000 Tokens",
      },
      {
        price: "25.99€",
        tokens_description: "20.000.000 Tokens",
      },
      {
        price: "35.00€",
        tokens_description: "40.000.000 Tokens",
      },
      {
        price: "44.99€",
        tokens_description: "50.000.000 Tokens",
      },
    ]
};

// Configuration for Others section (same as donator.js)
const tebexOthersConfig = {
  categories: [
    {
      categoryName: "Kill Effects 1 Month",
      categoryDescription: "💥 Special effects when you kill a player",
      items: [
        {
          itemName: "Kill Effect",
          itemDescription: "Access to all kill effects",
          price: "500 Coins",
          number: 500,
          image: "kill_effect"
        },
      ]
    },
    {
      categoryName: "Ped Access 1 Month",
      categoryDescription: "👤 Exclusive character models",
      items: [
        {
          itemName: "Ped Access",
          itemDescription: "Access to all player models",
          price: "500 Coins",
          number: 500,
          image: "ped_access"
        },
      ]
    },
    {
      categoryName: "Unban League",
      categoryDescription: "🔓 Get unbanned from league matches",
      items: [
        {
          itemName: "Unban League",
          itemDescription: "Remove your ban from league matches",
          number: 700,
          price: "700 Coins",
          image: "unban_league"
        }
      ]
    }
  ]
};

/**
 * Initialize Tebex page
 */
function InitTebex() {
    // Set default category
    ChangeTebexCategory('rank');
    
    // Set up category button event listeners
    $('.tebex-category-btn').on('click', function() {
        const category = $(this).data('category');
        ChangeTebexCategory(category);
    });
}

/**
 * Show Tebex page
 */
function ShowTebex() {
    console.log("Show Tebex");
    // Hide other sections
    $('.inventorydiv').hide();
    $('.leaderboard-section').hide();
    $('.ui-shop').hide();
    
    // Hide profile and settings when switching to tebex
    if (window.HideProfile && typeof window.HideProfile === 'function') {
        window.HideProfile();
    }
    if (window.HideSettings && typeof window.HideSettings === 'function') {
        window.HideSettings();
    }
    
    // Show Tebex
    $('.ui-tebex').show();
    
    // Update navigation
    $('.menu-link').removeClass('current-page');
    $('.menu-link').each(function() {
        if ($(this).text().trim() === 'TEBEX') {
            $(this).addClass('current-page');
        }
    });
    
    // Initialize if not already done
    $(".ui-body").show();
    InitTebex();
}

/**
 * Change Tebex category
 * @param {String} category - The category to switch to ('rank' or 'other')
 */
function ChangeTebexCategory(category) {
    currentTebexCategory = category;
    
    // Update button states
    $('.tebex-category-btn').removeClass('active');
    $(`.tebex-category-btn[data-category="${category}"]`).addClass('active');
    
    // Clear content
    $('.tebex-content').empty();
    
    // Load appropriate content
    if (category === 'rank') {
        LoadTebexRanks();
    } else if (category === 'other') {
        LoadTebexOthers();
    } else if (category === 'token') {
        LoadTebexToken();
    }
}

/**
 * Load rank content
 */
function LoadTebexRanks() {
    let cardsContent = `<div class="rank-cards-container">`;

    // Add rank cards
    tebexRankConfig.ranks.forEach((rank, index) => {
        cardsContent += `
          <div class="rank-card">
            <div class="rank-header">
              <h3 class="rank-name">${rank.nameRank}</h3>
              <div class="rank-description">${rank.descriptionRank}</div>
            </div>
            
            <div class="rank-advantages">
              <h4 class="advantages-title">Advantages</h4>
              <ul class="advantages-list">
        `;

        // Add advantages
        rank.advantages.forEach(advantage => {
            if (advantage.check !== undefined) {
                if (advantage.check) {
                    // Green checkmark for features included
                    cardsContent += `
                        <li class="advantage-item included">
                          <span class="advantage-icon">
                            <svg width="16" height="16" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="circle-check" class="svg-inline--fa fa-circle-check check-green" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                              <path fill="currentColor" d="M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zM369 209L241 337c-9.4 9.4-24.6 9.4-33.9 0l-64-64c-9.4-9.4-9.4-24.6 0-33.9s24.6-9.4 33.9 0l47 47L335 175c9.4-9.4 24.6-9.4 33.9 0s9.4 24.6 0 33.9z"></path>
                            </svg>
                          </span>
                          <span class="advantage-description">${advantage.description}</span>
                        </li>
                    `;
                } else {
                    // X mark for features not included
                    cardsContent += `
                        <li class="advantage-item not-included">
                          <span class="advantage-icon">
                            <svg width="16" height="16" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="circle-xmark" class="svg-inline--fa fa-circle-xmark" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                              <path fill="currentColor" d="M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zM175 175c9.4-9.4 24.6-9.4 33.9 0l47 47 47-47c9.4-9.4 24.6-9.4 33.9 0s9.4 24.6 0 33.9l-47 47 47 47c9.4 9.4 9.4 24.6 0 33.9s-24.6 9.4-33.9 0l-47-47-47 47c-9.4 9.4-24.6 9.4-33.9 0s-9.4-24.6 0-33.9l47-47-47-47c-9.4-9.4-9.4-24.6 0-33.9z"></path>
                            </svg>
                          </span>
                          <span class="advantage-description">${advantage.description}</span>
                        </li>
                    `;
                }
            } else if (advantage.text !== undefined) {
                // Text value
                cardsContent += `
                    <li class="advantage-item with-value">
                      <span class="advantage-description">${advantage.description}:</span>
                      <span class="advantage-value">${advantage.text}</span>
                    </li>
                `;
            }
        });

        cardsContent += `
              </ul>
            </div>
            
            <div class="rank-footer">
              <div class="rank-price">${rank.price}</div>
              <div class="shop-buy-button" onclick="window.invokeNative('openUrl', 'https://store.guildpvp.fr/category/ranks')">
                <svg width="16" height="16" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="basket-shopping" class="svg-inline--fa fa-basket-shopping" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512">
                  <path fill="currentColor" d="M253.3 35.1c6.1-11.8 1.5-26.3-10.2-32.4s-26.3-1.5-32.4 10.2L117.6 192H32c-17.7 0-32 14.3-32 32s14.3 32 32 32L83.9 463.5C91 492 116.6 512 146 512H430c29.4 0 55-20 62.1-48.5L544 256c17.7 0 32-14.3 32-32s-14.3-32-32-32H458.4L365.3 12.9C359.2 1.2 344.7-3.4 332.9 2.7s-16.3 20.6-10.2 32.4L404.3 192H171.7L253.3 35.1zM192 304v96c0 8.8-7.2 16-16 16s-16-7.2-16-16V304c0-8.8 7.2-16 16-16s16 7.2 16 16zm96-16c8.8 0 16 7.2 16 16v96c0 8.8-7.2 16-16 16s-16-7.2-16-16V304c0-8.8 7.2-16 16-16zm128 16v96c0 8.8-7.2 16-16 16s-16-7.2-16-16V304c0-8.8 7.2-16 16-16s16 7.2 16 16z"></path>
                </svg>
                <span>Buy</span>
              </div>
            </div>
          </div>
        `;
    });

    cardsContent += `</div>`;

    // Append the cards to the DOM
    $('.tebex-content').append(cardsContent);
}

/**
 * Load others content
 */
function LoadTebexOthers() {
    let content = `<div class="others-categories-container">`;

    // Add category items directly without category headers
    tebexOthersConfig.categories.forEach((category, catIndex) => {
        category.items.forEach((item, itemIndex) => {
            // Generate unique ID for each button
            const buttonId = `tebex-buy-btn-${catIndex}-${itemIndex}`;
            
            content += `
                <div class="others-box">
                  <div class="others-box-content">
                    <div class="others-box-header">
                      <h3 class="others-box-title">${item.itemName}</h3>
                      <div class="others-box-category">${category.categoryName}</div>
                    </div>
                    <div class="others-box-description">${item.itemDescription}</div>
                  </div>
                  <div class="others-box-footer">
                    <div class="others-box-price">${item.price}</div>
                    <div class="shop-buy-button" id="${buttonId}" data-category="${category.categoryName}" data-item="${item.itemName}" data-price="${item.price}" data-number="${item.number}">
                      <svg width="16" height="16" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="basket-shopping" class="svg-inline--fa fa-basket-shopping" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512">
                        <path fill="currentColor" d="M253.3 35.1c6.1-11.8 1.5-26.3-10.2-32.4s-26.3-1.5-32.4 10.2L117.6 192H32c-17.7 0-32 14.3-32 32s14.3 32 32 32L83.9 463.5C91 492 116.6 512 146 512H430c29.4 0 55-20 62.1-48.5L544 256c17.7 0 32-14.3 32-32s-14.3-32-32-32H458.4L365.3 12.9C359.2 1.2 344.7-3.4 332.9 2.7s-16.3 20.6-10.2 32.4L404.3 192H171.7L253.3 35.1zM192 304v96c0 8.8-7.2 16-16 16s-16-7.2-16-16V304c0-8.8 7.2-16 16-16s16 7.2 16 16zm96-16c8.8 0 16 7.2 16 16v96c0 8.8-7.2 16-16 16s-16-7.2-16-16V304c0-8.8 7.2-16 16-16zm128 16v96c0 8.8-7.2 16-16 16s-16-7.2-16-16V304c0-8.8 7.2-16 16-16s16 7.2 16 16z"></path>
                      </svg>
                      <span>Buy</span>
                    </div>
                  </div>
                </div>
            `;
        });
    });

    content += `</div>`;

    // Append the content to the DOM
    $('.tebex-content').append(content);
    
    // Remove all previous event handlers
    $('.shop-buy-button').off('click');
    
    // Add event handlers using delegation
    $('.others-categories-container').on('click', '.shop-buy-button', function() {
        const category = $(this).data('category');
        const item = $(this).data('item');
        const price = $(this).data('price');
        const number = $(this).data('number');
        
        BuyTebexOthersItem(category, item, price, number);
    });
}


function LoadTebexToken() {
    let cardsContent = `<div class="token-cards-container">`;

    // Add token cards
    tebexTokenConfig.tokens.forEach((token, index) => {
        const tokenDescription = token.tokens_description || token.description || "0 Tokens";
        const rate = calculateRate(token.price, tokenDescription);
        const formattedRate = formatNumberWithCommas(rate);
        
        cardsContent += `
            <div class="token-card">
                <div class="token-card-header">
                    <div class="token-amount">
                        <i class="fa-solid fa-coins"></i>
                        <span>${tokenDescription}</span>
                    </div>
                </div>
                <div class="token-card-content">
                    <div class="token-info">
                        <div class="token-rate">
                            <span class="rate-label">Rate</span>
                            <span class="rate-value">${formattedRate} tokens/€</span>
                        </div>
                        <div class="token-bonus">
                            <span class="bonus-label">Bonus</span>
                            <span class="bonus-value">${calculateBonus(tokenDescription)}</span>
                        </div>
                    </div>
                </div>
                <div class="token-card-footer">
                    <div class="token-price">${token.price}</div>
                    <button class="token-buy-button" onclick="window.invokeNative('openUrl', 'https://store.guildpvp.fr/category/tokens')">
                        <i class="fa-solid fa-cart-shopping"></i>
                        <span>Purchase</span>
                    </button>
                </div>
            </div>
        `;
    });

    cardsContent += `</div>`;

    // Helper functions for calculations
    function calculateRate(price, tokens) {
        if (!price || !tokens) return 0;
        try {
            const numericPrice = parseFloat(price.replace('€', ''));
            const numericTokens = parseInt(tokens.replace(/[^0-9]/g, ''));
            if (isNaN(numericPrice) || isNaN(numericTokens) || numericPrice === 0) return 0;
            const rate = (numericTokens / numericPrice).toFixed(0);
            return parseInt(rate);
        } catch (e) {
            console.error("Error calculating rate:", e);
            return 0;
        }
    }

    function calculateBonus(tokens) {
        if (!tokens) return "0%";
        try {
            const amount = parseInt(tokens.replace(/[^0-9]/g, ''));
            if (isNaN(amount)) return "0%";
            
            let bonus = 0;
            if (amount >= 50000000) bonus = "25%";
            else if (amount >= 40000000) bonus = "20%";
            else if (amount >= 20000000) bonus = "15%";
            else if (amount >= 10000000) bonus = "10%";
            else if (amount >= 5000000) bonus = "5%";
            else bonus = "0%";
            return bonus;
        } catch (e) {
            console.error("Error calculating bonus:", e);
            return "0%";
        }
    }

    // Append the cards to the DOM
    $('.tebex-content').append(cardsContent);
}

/**
 * Buy rank function (same $.post as donator.js)
 * @param {String} rankName - The name of the rank to buy
 * @param {String} price - The price of the rank
 */
function BuyTebexRank(rankName, price) {
    if (isBuyingTebexItem) {
        return;
    }
    
    isBuyingTebexItem = true;
    
    $.post("https://gamemode/BuyTebexRank", JSON.stringify({ rank: rankName, price: price }), function (data) {
        setTimeout(() => {
            isBuyingTebexItem = false;
        }, 1000);
        
        if (data.status == "success") {
            // Update coins if provided
            if (data.coins !== undefined) {
                SetTebexCoins(data.coins);
            }
        } else {
            console.log("error");
        }
    });
}

/**
 * Buy others item function (same $.post as donator.js)
 * @param {String} category - The category of the item
 * @param {String} itemName - The name of the item to buy
 * @param {String} itemPrice - The price of the item
 * @param {Number} number - The number of items to buy
 */
function BuyTebexOthersItem(category, itemName, itemPrice, number) {
    if (isBuyingTebexItem) {
        return;
    }
    
    isBuyingTebexItem = true;
    // Buying item: Kill Effects 1 Month Kill Effect 500 Coins 50
    
    $.post("https://gamemode/BuyOthersItem", JSON.stringify({ category: category, item: itemName, price: itemPrice, number: number }), function (data) {
        setTimeout(() => {
            isBuyingTebexItem = false;
        }, 1000);
        
        if (data.status == "success") {
            // Update coins if provided
            if (data.coins !== undefined) {
                SetTebexCoins(data.coins);
            }
        } else {
            console.log("error");
        }
    });
}

/**
 * Set coins display in Tebex
 * @param {Number} amount - The amount of coins to display
 */
function SetTebexCoins(amount) {
    $('.tebex-coins').text(amount + " Coins");
}

/**
 * Handle Tebex window message events
 */
window.addEventListener('message', function (event) {
    const data = event.data;
    if (data.type == "tebex") {
        console.log("tebex");
        if (data.bool) {
            console.log("Show Tebex");
            ShowTebex();
            // Set coins if provided
            if (data.coins !== undefined) {
                SetTebexCoins(data.coins);
            }
        } else {
            $('.ui-tebex').hide();
        }
    }
});

// Initialize when document is ready
$(document).ready(function() {
    // Add click handler for Tebex menu link
    $('.menu-link').each(function() {
        if ($(this).text().trim() === 'TEBEX') {
            $(this).on('click', function(e) {
                e.preventDefault();
                ShowTebex();
            });
        }
    });
});
