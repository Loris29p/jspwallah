window.addEventListener('message', function (event) {
  const data = event.data;
  if (data.type == "donator") {
    if (data.bool) {
        $(".ui-boutique-rank").css("display", "flex");
        // Initialiser avec la section des rangs
        ChangeDonatorPages('rank');
    } else {
        $(".ui-boutique-rank").css("display", "none");
    }
  }
});

/**
 * Met à jour le nombre de coins affichés dans le portefeuille de la boutique
 * @param {Number} amount - Le montant de coins à afficher
 */
function SetCoinsShop(amount) {
  $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-container-header .shop-right-side .wallet").text(amount + " Coins");
}

// Create a custom configuration
const myRankConfig = {
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
      }
    ]
};

// Configuration for Others section
const myOthersConfig = {
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
 * Toggle primary class on buttons
 * @param {String} primaryId - The ID of the button to set as primary
 * @param {String} secondaryId - The ID of the button to remove primary from
 */
function togglePrimaryClass(primaryId, secondaryId) {
  $(`#${primaryId}`).addClass("primary");
  $(`#${secondaryId}`).removeClass("primary");
}

function ChangeDonatorPages(str) {
  if (str == "rank") {
    togglePrimaryClass("rank-button", "daily-button");
    togglePrimaryClass("rank-button", "weapon-button");
    togglePrimaryClass("rank-button", "myskins-button");
    $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content").empty();
    
    // Use AddRankShop with the custom rank configuration
    AddRankShop(myRankConfig);
  } else if (str == 'daily') {
    togglePrimaryClass("daily-button", "rank-button");
    togglePrimaryClass("daily-button", "weapon-button");
    togglePrimaryClass("daily-button", "myskins-button");

    $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content").empty();

    const content = `
        <div class="category-items">
            <div class="shop-packages-content">
              
            </div>
          </div>
        `

    $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content").append(content)

    $.get("https://gamemode/GetDailyShop", function (data) {
      // console.log(JSON.stringify(data.List))
      $.each(data.List, function (k, v) {
        // console.log(v.type)
        if (v.type == "items") {
          const content = `
               <div class="shop-pkg-container">
                <div class="icon-container">
                  <div class="icon" style="background-image: url(&quot;/ui/assets/items/${v.image}.png&quot;);"></div>
                </div>
                <div class="details-container">
                  <span class="item-name">${v.label}</span>
                  <span class="item-category">${v.Description}</span>
                </div>
                <div class="purchase-container">
                  <div class="purchase-button" onclick="BuyInShop('${v.id}')">
                    <span class="purchase-button-text">${v.price} Tokens</span>
                  </div>
                </div>
              </div>
              `
          $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content .category-items .shop-packages-content").append(content);

        } else if (v.type == "ped") {
          const content = `
              <div class="shop-pkg-container">
               <div class="icon-container">
                 <div class="icon" style="background-image: url(&quot;/ui/assets/shop/packages/${v.model}.webp&quot;);"></div>
               </div>
               <div class="details-container">
                 <span class="item-name">${v.label}</span>
                 <span class="item-category">${v.Description}</span>
               </div>
               <div class="purchase-container">
                 <div class="purchase-button" onclick="BuyInShop('${v.id}')">
                   <span class="purchase-button-text">${v.price} Tokens</span>
                 </div>
               </div>
             </div>
             `
          $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content .category-items .shop-packages-content").append(content);
        }
      });

    });
  } else if (str == 'myskins') {
    togglePrimaryClass("myskins-button", "daily-button");
    togglePrimaryClass("myskins-button", "weapon-button");
    togglePrimaryClass("myskins-button", "rank-button");

    $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content").empty();

    const content = `
        <div class="category-items">
            <div class="shop-packages-content">
              
            </div>
          </div>
        `

    $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content").append(content)

    const freemode = `
              <div class="shop-pkg-container">
               <div class="icon-container">
                 <div class="icon" style="background-image: url(&quot;/ui/assets/shop/packages/mp_m_freemode_01.webp&quot;);"></div>
               </div>
               <div class="details-container">
                 <span class="item-name">Default Skin Male</span>
               </div>
               <div class="purchase-container">
                 <div class="purchase-button" onclick="EquipSkin('mp_m_freemode_01')">
                   <span class="purchase-button-text">Equip the Skin</span>
                 </div>
               </div>
               <div class="purchase-container customize-container">
                <div class="purchase-button" onclick="CustomizeSkin()">
                  <span class="purchase-button-text">Customize the Skin</span>
                  </div>
              </div>
              <div class="purchase-container old-container">
                <div class="purchase-button" onclick="OldSkin()">
                  <span class="purchase-button-text">Put on my old skin</span>
                </div>
              </div>
            </div>
             </div>
             `
    $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content .category-items .shop-packages-content").append(freemode);

    const freemode2 = `
        <div class="shop-pkg-container">
        <div class="icon-container">
          <div class="icon" style="background-image: url(&quot;/ui/assets/shop/packages/mp_f_freemode_01.webp&quot;);"></div>
        </div>
        <div class="details-container">
          <span class="item-name">Default Skin Female</span>
        </div>
        <div class="purchase-container">
          <div class="purchase-button" onclick="EquipSkin('mp_f_freemode_01')">
            <span class="purchase-button-text">Equip the Skin</span>
          </div>
        </div>
        <div class="purchase-container customize-container">
          <div class="purchase-button" onclick="CustomizeSkin()">
            <span class="purchase-button-text">Customize the Skin</span>
          </div>
        </div>
        <div class="purchase-container old-container">
          <div class="purchase-button" onclick="OldSkin()">
            <span class="purchase-button-text">Put on my old skin</span>
          </div>
        </div>
      </div>
      `
    $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content .category-items .shop-packages-content").append(freemode2);

    $.get("https://gamemode/GetMySkins", function (data) {
      console.log(JSON.stringify(data.peds))
      if (data.peds) {
        $.each(data.peds, function (k, v) {
          const content = `
              <div class="shop-pkg-container">
               <div class="icon-container">
                 <div class="icon" style="background-image: url(&quot;/ui/assets/shop/packages/${v.model}.webp&quot;);"></div>
               </div>
               <div class="details-container">
                 <span class="item-name">${v.label}</span>
                 <span class="item-category">${v.Description}</span>
               </div>
               <div class="purchase-container">
                 <div class="purchase-button" onclick="EquipSkin('${v.id}')">
                   <span class="purchase-button-text">Equip the Skin</span>
                 </div>
               </div>
             </div>
             `
          $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content .category-items .shop-packages-content").append(content);
        });
      } else if (data.weapons) {

      }
    });

  } else if (str == 'others') {
    togglePrimaryClass("myskins-button", "daily-button");
    togglePrimaryClass("myskins-button", "rank-button");
    $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content").empty();
    
    // Use AddOthersShop with the custom others configuration
    AddOthersShop(myOthersConfig);
  }
}

/**
 * Adds rank shops dynamically based on configuration
 * @param {Object} config Optional configuration, if not provided will use default ranks
 */
function AddRankShop(config) {
  // Default ranks if no config is provided
  if (!config) {
    config = {
      ranks: [
        {
          nameRank: "Gold",
          descriptionRank: "🟨 Gold rank in-game & discord",
          price: "800 Coins",
          advantages: [
            { description: "Discord role & chat color", check: true },
            { description: "Unlock all player models available in the character creation", check: true },
            { description: "Speed boost in safe-zones & lobby", check: true },
            { description: "Custom message after killing a player", check: true },
            { description: "FX Effect (/effect) on the player you killed", check: false },
            { description: "Launch fireworks with /fw", check: false },
            { description: "Unlimited saved outfits slots", text: "6" },
            { description: "Unlimited reset skin (/selfresethead)", check: true },
            { description: "Unlimited rename /nickname", check: false },
            { description: "(Guild PvP) Choose the plate of your vehicle", check: false },
            { description: "(Guild PvP) Control the in-game screen/tv to play videos with /screen", check: false },
            { description: "(Guild PvP) Special daily kit", text: "Gold" },
            { description: "(Guild PvP) XP boost", text: "3%" },
            { description: "(Guild PvP) Unlimited /reset_stats", check: false }
          ]
        },
        {
          nameRank: "Diamond",
          descriptionRank: "💎 Diamond rank in-game & discord",
          price: "1,600 Coins",
          advantages: [
            { description: "Discord role & chat color", check: true },
            { description: "Unlock all player models available in the character creation", check: true },
            { description: "Speed boost in safe-zones & lobby", check: true },
            { description: "Custom message after killing a player", check: true },
            { description: "FX Effect (/effect) on the player you killed", check: true },
            { description: "Launch fireworks with /fw", check: true },
            { description: "Unlimited saved outfits slots", text: "∞" },
            { description: "Unlimited reset skin (/selfresethead)", check: true },
            { description: "Unlimited rename /nickname", check: true },
            { description: "(Guild PvP) Choose the plate of your vehicle", check: true },
            { description: "(Guild PvP) Control the in-game screen/tv to play videos with /screen", check: false },
            { description: "(Guild PvP) Special daily kit", text: "Diamond" },
            { description: "(Guild PvP) XP boost", text: "6%" },
            { description: "(Guild PvP) Unlimited /reset_stats", check: true }
          ]
        }
      ]
    };
  }

  // Create modern rank cards
  let cardsContent = `
    <div class="rank-cards-container">
  `;

  // Add rank cards
  config.ranks.forEach(rank => {
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

  cardsContent += `
    </div>
  `;

  // Append the cards to the DOM
  $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content").append(cardsContent);
}

function OldSkin() {
  $.post("https://gamemode/OldSkin", JSON.stringify({}), function (data) {
    if (data.status == "success") {
      console.log("success")
    } else {
      console.log("error")
    }
  });
}

function CustomizeSkin() {
  $.post("https://gamemode/Close");
  $.post("https://gamemode/CustomizeSkin", JSON.stringify({}), function (data) {
    if (data.status == "success") {
      console.log("success")
    } else {
      console.log("error")
    }
  });
}
function EquipSkin(id) {
  console.log(id)
  $.post("https://gamemode/EquipSkin", JSON.stringify({ id: id }), function (data) {
    if (data.status == "success") {
      console.log("success")
    } else {
      console.log("error")
    }
  });
}

function BuyInShop(id) {
  $.post("https://gamemode/BuyDaily", JSON.stringify({ id: id }), function (data) {
    if (data.status == "success") {
      console.log("success")
    } else {
      console.log("error")
    }
  });
}

/**
 * Adds others shop categories dynamically based on configuration
 * @param {Object} config Configuration for the others shop
 */
function AddOthersShop(config) {
  if (!config) {
    return;
  }

  // Create container
  let content = `
    <div class="others-categories-container">
  `;

  // Add category items directly without category headers
  config.categories.forEach((category, catIndex) => {
    category.items.forEach((item, itemIndex) => {
      // Générer un ID unique pour chaque bouton
      const buttonId = `buy-btn-${catIndex}-${itemIndex}`;
      
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

  content += `
    </div>
  `;

  // Append the content to the DOM
  $(".ui-boutique-rank .premium-shop-home .premium-shop-market .shop-content").append(content);
  
  // Supprimer tous les gestionnaires d'événements précédents
  $(".shop-buy-button").off("click");
  
  // Ajouter des gestionnaires d'événements en utilisant la délégation
  $(".others-categories-container").on("click", ".shop-buy-button", function() {
    const category = $(this).data("category");
    const item = $(this).data("item");
    const price = $(this).data("price");
    const number = $(this).data("number");
    
    BuyOthersItem(category, item, price, number);
  });
}

// Variable pour empêcher les clics multiples
let isBuyingItem = false;

/**
 * Handles purchase of items from the Others shop
 * @param {String} category - The category of the item
 * @param {String} itemName - The name of the item to buy
 * @param {Number} number - The number of items to buy
 */
function BuyOthersItem(category, itemName, itemPrice, number) {
  // Protection contre les clics multiples
  if (isBuyingItem) {
    console.log("Purchase already in progress");
    return;
  }
  
  isBuyingItem = true;
  console.log("Buying item:", category, itemName, itemPrice, number);
  
  $.post("https://gamemode/BuyOthersItem", JSON.stringify({ category: category, item: itemName, price: itemPrice, number: number }), function (data) {
    // Réinitialiser après un court délai pour éviter les clics rapides
    setTimeout(() => {
      isBuyingItem = false;
    }, 1000);
    
    if (data.status == "success") {
      console.log("success")
      SetCoinsShop(data.coins);
    } else {
      console.log("error")
    }
  });
} 