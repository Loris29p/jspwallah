Config = {
    InventoryTypes = {
        ["inventory"] = {
            maxWeight = 1000000, --kg
            label = "Inventory"
        },
        ["protected"] = {
            maxWeight = 10000000, --kg
            label = "Protected"
        },
        ["stash"] = {
            maxWeight = 100000000, --kg
            label = "Stash"
        },
    },
    Admins = {
        ["steam:11000010b28aec6"] = true
    },
    DeleteBlockedItems = {
        ["deluxo"] = false
    },
    RemoveInventoriesWhenDead = {
        bool = function(source)
           return true -- you can put your inSafe export to make it dynamic
        end,
        deathEvent = "baseevents:onPlayerDied",
        types = {
            "inventory",
            --"protected"
        }
    }
}

for k, v in pairs(Config.InventoryTypes) do
    Config.InventoryTypes[k].name = k
    Config.InventoryTypes[k].invMax = Config.InventoryTypes["inventory"].maxWeight
end