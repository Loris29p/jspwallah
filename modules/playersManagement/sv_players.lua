Players = {}
PlayersListSafeMode = {}


Discord.Register("player_connect", "Player Connect", "logs-connect");


function GetLicence(source)
  local identifiers = GetPlayerIdentifiers(source)
  local license = nil
  for _, v in pairs(identifiers) do
      if string.find(v, "license:") then
          license = v
          break
      end
  end
  return license
end

function GetIp(source)
  local identifiers = GetPlayerIdentifiers(source)
  local ip = nil
  for _, v in pairs(identifiers) do
      if string.find(v, "ip:") then
          ip = v
          break
      end
  end
  return ip
end

function GetIP2(playerId)
  for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
      if string.match(v, 'ip:') then
          local ip = string.gsub(v, 'ip:', '')
          return ip
      end
  end
end

function DoNotif(src, ...) 
    _TriggerClientEvent("ShowAboveRadarMessage", src, ...)
end

function PlayersIsOnline(src)
    if Players[src] then 
      return true
    end
    return false
end

function PlayersIsOnlineUUID(uuid)
  for k, v in pairs(Players) do 
    if v.uuid == uuid then 
      return v
    end
  end
  return false
end

function CreatePlayers(license, source)
  MySQL.Async.fetchAll("SELECT * FROM players WHERE license = @license", {["@license"] = license}, function(result)
    if not result[1] then 
        local newUuid = MySQL.Sync.fetchScalar("SELECT MAX(uuid) FROM players")
        if not newUuid then
            newUuid = tonumber(0)
        end

        MySQL.Async.execute("INSERT INTO players (license, username, uuid, token, rank, `group`, permissions, informations, inventory, kills_global, death_global, flag, data, cosmetics, settings, skin, crewId, coins, prestige, xp, identifiers, firstConnection) VALUES (@license, @username, @uuid, @token, @rank, @group, @permissions, @informations, @inventory, @kills_global, @death_global, @flag, @data, @cosmetics, @settings, @skin, @crewId, @coins, @prestige, @xp, @identifiers, @firstConnection)", {
          ["@license"] = license,
          ["@username"] = SetRemoveSpace(GetPlayerName(source)),
          ["@uuid"] = newUuid + 1,
          ["@token"] = 20000,
          ["@rank"] = "user",
          ["@group"] = "user",
          ["@permissions"] = 0, 
          ["@informations"] = json.encode({}),
          ["@inventory"] = json.encode({}),
          ["@kills_global"] = 0,
          ["@death_global"] = 0,
          ["@flag"] = "FR",
          ["@data"] = json.encode({}),
          ["@cosmetics"] = json.encode({}),
          ["@settings"] = json.encode({}),
          ["@skin"] = json.encode({}),
          ["@crewId"] = 0,
          ["@coins"] = 0,
          ["@prestige"] = 0,
          ["@xp"] = 0,
          ["@firstConnection"] = os.time(),
          ["@identifiers"] = json.encode(GetPlayerIdentifiers(source))
      }, function(rowsChanged)
            if rowsChanged > 0 then 
                LoadUser(license, source, true)
                local identifier = GetPlayerIdentifiers(source)[1]
                if not identifier then return end
                LoadPlayerItems(source, identifier)
                -- Give items to the player
                Wait(5000)
                exports["gamemode"]:AddItem(source, "protected", "weapon_specialcarbine", 30, nil, true)
                exports["gamemode"]:AddItem(source, "protected", "weapon_specialcarbine", 30, nil, true)
                exports["gamemode"]:AddItem(source, "protected", "weapon_carbinerifle_mk2", 30, nil, true)
                exports["gamemode"]:AddItem(source, "protected", "buffalo4", 50, nil, true)
                exports["gamemode"]:AddItem(source, "protected", "revolter", 20, nil, true)
                exports["gamemode"]:AddItem(source, "protected", "brioso", 20, nil, true)
            end
        end)
    else
        LoadUser(license, source, false)
        local identifier = GetPlayerIdentifiers(source)[1]
        if not identifier then return end
        LoadPlayerItems(source, identifier)
    end
  end)
end

function LoadUser(license, src, newPlayer)
  MySQL.Async.fetchAll("SELECT * FROM players WHERE license = @license", {["@license"] = license}, function(result)
    if result[1] then 
      local myIp = GetIP2(src)
      PerformHttpRequest("http://ip-api.com/json/"..myIp, function(err, text, headers)
        local country = json.decode(text)
        if CountryFlag[country.countryCode] then
          result[1].flag = CountryFlag[country.countryCode]
        else
          result[1].flag = "GB"
        end
      end)
      Players[src] = playerManagement:CreatePlayers(src, result[1])
      table.insert(PlayersListSafeMode, {
        username = result[1].username,
        uuid = result[1].uuid,
        source = src,
      })

      local inventoryA, inventoryB = exports["gamemode"]:GetInventory(src, "inventory"), exports["gamemode"]:GetInventory(src, "protected")

  
      local uuidFocus = GetUUIDFocusByUUID(result[1].uuid)
      if uuidFocus then 
        SendWebhookFocus({
          webhook = webhookFocusConnect,
          title = "Focus Connect",
          description = "A focus player has connected to the server. @everyone",
          fields = {
            { name = "UUID", value = uuidFocus.uuid, inline = true },
            { name = "Reason", value = uuidFocus.reason, inline = true },
            { name = "Staff UUID", value = uuidFocus.staffUUID, inline = true },
            { name = "Staff Name", value = uuidFocus.staffName, inline = true },
            { name = "Date", value = os.date("%Y-%m-%d %H:%M:%S"), inline = true },
          },
          footer = "Focus Connect",
        })
      end
      TriggerClientEvent("updateListPlayersServerGlobal", -1, PlayersListSafeMode)
      TriggerClientEvent("player:LoadPlayer", src, Players[src])
      LoadSettings(src, license)
    --   GetDbStats()
      Wait(500)
      local message = DiscordMessage(); 
      local returnMessage = ""
      if DiscordId(src) then 
        local PLAYER_DATA <const> = GetPlayerId(src)
        returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..") | Discord ID: <@"..DiscordId(src)..">"
      else
        local PLAYER_DATA <const> = GetPlayerId(src)
        returnMessage = PLAYER_DATA.username.." ("..PLAYER_DATA.uuid..")"
      end
      message:SetMessage(("%s"):format(returnMessage))
      message:AddField()
          :SetName("UUID")
          :SetValue(Players[src].uuid)
          :SetInline(true);
      message:AddField()
          :SetName("License")
          :SetValue(Players[src].license)
          :SetInline(true);
      message:AddField()
          :SetName("Group")
          :SetValue(Players[src].group)
          :SetInline(true);
      message:AddField()
          :SetName("Rank")
          :SetValue(Players[src].rank)
          :SetInline(true);
      message:AddField()
          :SetName("ID")
          :SetValue(src)
          :SetInline(true);
      message:AddField()
          :SetName("Tokens")
          :SetValue(Players[src].token)
          :SetInline(true);
      message:AddField()
          :SetName("Prestige")
          :SetValue(Players[src].prestige)
          :SetInline(true);
      Discord.Send("player_connect", message);
      
      -- Send leaderboard with player's individual ranking
      GetPlayerRankingSQL(Players[src].uuid, function(playerRanking)
        _TriggerClientEvent("gamemode:setLeaderboard", src, GlobalKills, GlobalDeath, GlobalToken, playerRanking)
      end)
    end
  end)
end

AddEventHandler("playerDropped", function()
  local source = source
  local player = GetPlayerId(source)
  for k, v in pairs(PlayersListSafeMode) do 
    if v.source == source then
      table.remove(PlayersListSafeMode, k)
      TriggerClientEvent("updateListPlayersServerGlobal", -1, PlayersListSafeMode)
    end
  end
end)

RegisterServerEvent('GetListPlayersServerGlobal', function()
  TriggerClientEvent("updateListPlayersServerGlobal", source, PlayersListSafeMode)
end)

function ManagerUser(license, src)
  local source = src 
  if Players[source] then return end
  Players[source] = {}
  CreatePlayers(license, source)
end

function GetPlayerId(src)
  return Players[src]
end

exports("GetPlayerId", function(src)
  return GetPlayerId(src)
end)


function GetPlayerUUID(UUID)
  for k, v in pairs(Players) do
      if v.uuid == UUID then
          return v
      end
  end
  return nil
end

function GetPlayerLicense(license)
  for k, v in pairs(Players) do
      if v.license == license then
          return v
      end
  end
  return nil
end

exports("GetPlayerId", function(src)
  return GetPlayerId(src)
end)

exports("GetUUID", function(source)
  return GetPlayerId(source).uuid
end)


_RegisterServerEvent("player:JoiningServer")
_AddEventHandler("player:JoiningServer", function()
  local source = source
  local licence = GetLicence(source)
  print("Licence: "..licence)
  if not licence then 
      DropPlayer(source, "DEBUG")
      return 
  end
  ManagerUser(licence, source)

end)

ServerOpen = true


function getPlayerDiscordId(playerId)
  for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
      if string.match(identifier, "^discord:") then
          return string.sub(identifier, 9)
      end
  end
  return nil
end

function isValidPlayerName(name)
  local pattern = "^[a-zA-Z0-9 ]+$"
  return string.match(name, pattern) ~= nil
end

_AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
  deferrals.defer()

  local source = source
  local playerName = GetPlayerName(source)

  deferrals.update("Verification of your login. Please wait...")

  Citizen.Wait(2000)

  if not isValidPlayerName(playerName) then
    deferrals.done("🚫 Your username contains unauthorized special characters. Please change your username and try again.")
    return
end

  local licence = GetLicence(source)

  local GetTokens = GetNumPlayerTokens(tonumber(source))
  local AllTokens = {}
  for i = 1, GetTokens do 
      table.insert(AllTokens, GetPlayerToken(tonumber(source), i))
  end

  local Banned, banID, Reason, DateBan, Expiration  = GetIfPlayerIsBanned(source, licence, { identifiers1 = GetPlayerIdentifiers(source), tokens = AllTokens, ip = GetIp(source) })
  

  local discordId = getPlayerDiscordId(source)

  if Banned then 
    local message = DiscordMessage(); 
    message:AddField()
        :SetName("Username")
        :SetValue(playerName);
    if DiscordId(source) then 
      message:AddField()
          :SetName("Discord ID")
          :SetValue("<@"..DiscordId(source)..">");
    else
      message:AddField()
          :SetName("Discord ID")
          :SetValue("None");
    end
    message:AddField()
        :SetName("Ban ID")
        :SetValue(banID);
    message:AddField()
        :SetName("Reason")
        :SetValue(Reason);
    message:AddField()
        :SetName("Banned since")
        :SetValue(DateBan);
    message:AddField()
        :SetName("Unban date")
        :SetValue(Expiration or "Permanent (99y)");
    Discord.Send("already_banned", message);
        
    local card = {
      ["type"] = "AdaptiveCard",
      ["minHeight"] = "100px",
      ["body"] = {
          {
              ["type"] = "ColumnSet",
              ["columns"] = {
                  {
                      ["type"] = "Column",
                      ["items"] = {
                          {
                              ["type"] = "TextBlock",
                              ["text"] = Reason == "blacklist" and "You are blacklist from the server (BAN ID : "..banID..")" or "You are banned from the server.\nBan ID : "..banID.."\nReason: "..Reason.."\nBanned since: "..DateBan.."\nUnban date: "..(Expiration or "Permanent (99y)"),
                              ["wrap"] = true,
                              ["color"] = Reason == "blacklist" and "Attention" or "Default"
                          },
                      },
                      ["width"] = "stretch"
                  },
                  {
                      ["type"] = "Container",
                      ["items"] = {
                          {
                              ["type"] = "Action"
                          }
                      }

                  }
              }
          },
          {
              ["type"] = "ColumnSet",
              ["columns"] = {
                  {
                      ["type"] = "Column",
                      ["items"] = {
                          {
                              ["type"] = "Image",
                              ["url"] = "https://cdn.discordapp.com/attachments/1282741878290382860/1282750414239961138/guild_pvp.png?ex=66e07deb&is=66df2c6b&hm=c948e2e658933e64a035ca6b1795aa8d35a3cf45406b14aa6f9ee197859e41ab&",
                              ["size"] = "Small",
                          },
                      },
                      ["width"] = "auto"
                  },
                  {
                      ["type"] = "Column",
                      ["items"] = {
                          {
                              ["type"] = "TextBlock",
                              ["weight"] = "Bolder",
                              ["text"] = "Guild PvP",
                              ["wrap"] = true

                          },
                          {
                              ["type"] = "TextBlock",
                              ["spacing"] = "None";
                              ["text"] = "https://discord.gg/guildpvp",
                              ["isSubtle"] = true,
                              ["wrap"] = true,

                          },
                      },
                      ["width"] = "stretch"

                  }
              }
          },
      },
      ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
      ["version"] = "1.2"
  }
      deferrals.presentCard(card)
      CancelEvent();
    return;
  end

  for k,v in pairs(GetPlayerIdentifiers(source)) do
    if v:find("license:") then
      licenseCheck = v
      break
    end
  end
  if licenseCheck == "license:49e4555301585231cdeed95ac6fcd65433b59d2e" or licenseCheck == "license:8f5ec68ec8c607a7cabc562f7bda046e362242cb" then
    deferrals.done()
  else
    -- if not discordId or not DiscordRole(discordId, "user") then 
    if not discordId then 
      local card = {
        ["type"] = "AdaptiveCard",
        ["minHeight"] = "100px",
        ["body"] = {
            {
                ["type"] = "ColumnSet",
                ["columns"] = {
                    {
                        ["type"] = "Column",
                        ["items"] = {
                            {
                                ["type"] = "TextBlock",
                                ["text"] = "You need to link your discord account & join the discord server to join the server. (discord.gg/guildpvp)",
  
                            },
                        },
                        ["width"] = "stretch"
                    },
                    {
                        ["type"] = "Container",
                        ["items"] = {
                            {
                                ["type"] = "Action"
                            }
                        }
  
                    }
                }
            },
            {
                ["type"] = "ColumnSet",
                ["columns"] = {
                    {
                        ["type"] = "Column",
                        ["items"] = {
                            {
                                ["type"] = "Image",
                                ["url"] = "https://cdn.discordapp.com/attachments/1282741878290382860/1282750414239961138/guild_pvp.png?ex=66e07deb&is=66df2c6b&hm=c948e2e658933e64a035ca6b1795aa8d35a3cf45406b14aa6f9ee197859e41ab&",
                                ["size"] = "Small",
                            },
                        },
                        ["width"] = "auto"
                    },
                    {
                        ["type"] = "Column",
                        ["items"] = {
                            {
                                ["type"] = "TextBlock",
                                ["weight"] = "Bolder",
                                ["text"] = "Guild PvP",
                                ["wrap"] = true
  
                            },
                            {
                                ["type"] = "TextBlock",
                                ["spacing"] = "None";
                                ["text"] = "https://discord.gg/guildpvp",
                                ["isSubtle"] = true,
                                ["wrap"] = true,
  
                            },
                        },
                        ["width"] = "stretch"
  
                    }
                }
            },
        },
        ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
        ["version"] = "1.2"
    }
      deferrals.presentCard(card)
      CancelEvent()
      return
    end

    if ServerOpen then 
      deferrals.done()
      return
    else
      deferrals.done("The server is currently closed. Please come back later.")
      return
    end

    deferrals.done()
  end



end)

RegisterCommand("serveropen", function(source, args)
  if source == 0 then 
    if not ServerOpen then 
      ServerOpen = true 
      print("SERVER OPEN")
    else
      ServerOpen = false 
      print("SERVER OFF")
    end
  end
end)

local IS_DEV = true
if IS_DEV then 

    RegisterCommand("setgroup_console", function(source, args)
        if source ~= 0 then return end
        local number = tonumber(args[1])
        local PLAYER = GetPlayerId(number)
        if PLAYER then 
            PLAYER.group = args[2]
        end
    end)

    RegisterCommand("setgroup", function(source, args)
        local number = tonumber(args[1])
        local PLAYER = GetPlayerId(number)
        if GetPlayerId(source).group == "owner" then 
            if PLAYER then 
                PLAYER.group = "moderator"
            end
        end
    end)
    RegisterCommand("db_players", function(source, args)
        local PLAYER = GetPlayerId(source)
        if PLAYER.group ~= "owner" then return end
        local playerTarget = args[2]

        MySQL.Async.execute("DELETE FROM players WHERE license = @license", {["@license"] = playerTarget}, function(rowsChanged)
            if rowsChanged > 0 then 
                -- print("Player deleted")
            end
        end)
      
    end) 

    RegisterCommand("db_inv", function(source, args)

        local PLAYER = GetPlayerId(source)
        if PLAYER.group ~= "owner" then return end
        local identifiers = args[1]
        MySQL.Async.execute("DELETE FROM inventory WHERE identifier = @identifier", {["@identifier"] = identifiers}, function(rowsChanged)
            if rowsChanged > 0 then 
                -- print("Player deleted")
            end
        end)

    end)

    RegisterCommand("db_crew", function(source)
        local PLAYER = GetPlayerId(source)
        if PLAYER.group ~= "owner" then return end
        MySQL.Async.execute("DELETE FROM crew", {}, function(rowsChanged)
            if rowsChanged > 0 then 
                -- print("Crew deleted")
            end
        end)
        
    end)

    RegisterCommand("db_inventory", function(source)
      local PLAYER = GetPlayerId(source)
      if PLAYER.group ~= "owner" then return end
    
      MySQL.Async.execute("DELETE FROM inventory", {}, function(rowsChanged)
          if rowsChanged > 0 then 
              print("Nombre d'items supprimés : " .. rowsChanged)
          else
              print("Une erreur s'est produite lors de la suppression des items.")
          end
      end)

    end)

    RegisterCommand("db_settings", function(source)
        local PLAYER = GetPlayerId(source)
        if PLAYER.group ~= "owner" then return end
        MySQL.Async.execute("DELETE FROM settings", {}, function(rowsChanged)
            if rowsChanged > 0 then 
                print("Nombre de paramètres supprimés : " .. rowsChanged)
            else
                print("Une erreur s'est produite lors de la suppression des paramètres.")
            end
        end)
        
    end)

end


RegisterCallback("GM:GetPlacesPlayer", function(source, typeP)
  local PLAYER = GetPlayerId(source)
  local places = {}

  MySQL.Async.fetchAll("SELECT * FROM players", function(result)
    if result[1] then 
      for _,v in pairs(result) do
        print(v.username, "result")
      end
    end
  end)

end)

GlobalKills = {}
GlobalDeath = {}
GlobalToken = {}

-- More optimized version using SQL ORDER BY and LIMIT
function GetDbStatsOptimized()
  GlobalKills = {}
  GlobalDeath = {}
  GlobalToken = {}

  -- Get top 100 kills with all stats
  MySQL.Async.fetchAll("SELECT username, kills_global, death_global, token, uuid, flag, prestige FROM players ORDER BY kills_global DESC LIMIT 100", {}, function(killsResult)
    if killsResult then
      for k, v in pairs(killsResult) do 
        table.insert(GlobalKills, {
          username = GetTextWithGameColors(v.username, false), 
          kills = v.kills_global, 
          deaths = v.death_global,
          tokens = v.token,
          uuid = v.uuid, 
          avatar = "", 
          country = v.flag, 
          prestige = v.prestige
        })
      end
    end

    -- Get top 100 deaths with all stats
    MySQL.Async.fetchAll("SELECT username, kills_global, death_global, token, uuid, flag, prestige FROM players ORDER BY death_global DESC LIMIT 100", {}, function(deathResult)
      if deathResult then
        for k, v in pairs(deathResult) do 
          table.insert(GlobalDeath, {
            username = GetTextWithGameColors(v.username, false), 
            kills = v.kills_global,
            death = v.death_global, 
            deaths = v.death_global,
            tokens = v.token,
            uuid = v.uuid, 
            avatar = "", 
            country = v.flag, 
            prestige = v.prestige
          })
        end
      end

      -- Get top 100 tokens with all stats
      MySQL.Async.fetchAll("SELECT username, kills_global, death_global, token, uuid, flag, prestige FROM players ORDER BY token DESC LIMIT 100", {}, function(tokenResult)
        if tokenResult then
          for k, v in pairs(tokenResult) do 
            table.insert(GlobalToken, {
              username = GetTextWithGameColors(v.username, false), 
              kills = v.kills_global,
              deaths = v.death_global,
              token = v.token, 
              tokens = v.token,
              uuid = v.uuid, 
              avatar = "", 
              country = v.flag, 
              prestige = v.prestige
            })
          end
        end
      end)
    end)
  end)
end

-- New function to get player's individual ranking
function GetPlayerRanking(playerUUID)
  return MySQL.Async.fetchAll("SELECT * FROM players ORDER BY kills_global DESC", {}, function(killsResult)
    local killsRank = nil
    for i, player in ipairs(killsResult) do
      if player.uuid == playerUUID then
        killsRank = i
        break
      end
    end

    MySQL.Async.fetchAll("SELECT * FROM players ORDER BY death_global DESC", {}, function(deathResult)
      local deathRank = nil
      for i, player in ipairs(deathResult) do
        if player.uuid == playerUUID then
          deathRank = i
          break
        end
      end

      MySQL.Async.fetchAll("SELECT * FROM players ORDER BY token DESC", {}, function(tokenResult)
        local tokenRank = nil
        for i, player in ipairs(tokenResult) do
          if player.uuid == playerUUID then
            tokenRank = i
            break
          end
        end

        return {
          killsRank = killsRank,
          deathRank = deathRank,
          tokenRank = tokenRank
        }
      end)
    end)
  end)
end

-- Optimized function to get player ranking using a single query
function GetPlayerRankingOptimized(playerUUID, callback)
  MySQL.Async.fetchAll("SELECT uuid, kills_global, death_global, token FROM players", {}, function(result)
    if not result or #result == 0 then
      callback({killsRank = nil, deathRank = nil, tokenRank = nil})
      return
    end

    -- Sort for kills ranking
    table.sort(result, function(a, b) return a.kills_global > b.kills_global end)
    local killsRank = nil
    for i, player in ipairs(result) do
      if player.uuid == playerUUID then
        killsRank = i
        break
      end
    end

    -- Sort for death ranking
    table.sort(result, function(a, b) return a.death_global > b.death_global end)
    local deathRank = nil
    for i, player in ipairs(result) do
      if player.uuid == playerUUID then
        deathRank = i
        break
      end
    end

    -- Sort for token ranking
    table.sort(result, function(a, b) return a.token > b.token end)
    local tokenRank = nil
    for i, player in ipairs(result) do
      if player.uuid == playerUUID then
        tokenRank = i
        break
      end
    end

    callback({
      killsRank = killsRank,
      deathRank = deathRank,
      tokenRank = tokenRank
    })
  end)
end

-- Ultra-optimized function using SQL subqueries to get rankings directly
function GetPlayerRankingSQL(playerUUID, callback)
  local killsQuery = [[
    SELECT COUNT(*) + 1 as rank 
    FROM players 
    WHERE kills_global > (SELECT kills_global FROM players WHERE uuid = ?)
  ]]
  
  local deathQuery = [[
    SELECT COUNT(*) + 1 as rank 
    FROM players 
    WHERE death_global > (SELECT death_global FROM players WHERE uuid = ?)
  ]]
  
  local tokenQuery = [[
    SELECT COUNT(*) + 1 as rank 
    FROM players 
    WHERE token > (SELECT token FROM players WHERE uuid = ?)
  ]]

  MySQL.Async.fetchScalar(killsQuery, {playerUUID}, function(killsRank)
    MySQL.Async.fetchScalar(deathQuery, {playerUUID}, function(deathRank)
      MySQL.Async.fetchScalar(tokenQuery, {playerUUID}, function(tokenRank)
        callback({
          killsRank = killsRank,
          deathRank = deathRank,
          tokenRank = tokenRank
        })
      end)
    end)
  end)
end

-- RegisterCommand("refresh_leaderboard", function()
--     GetDbStats()
-- end)

Citizen.CreateThread(function()
  while true do
    Wait(4000)
    GetDbStatsOptimized()
    Citizen.Wait(1000 * 60 * 20)
  end
end)

RegisterCommand("addtokens", function(source, args)
  local src = source
  local STAFF = GetPlayerId(src)
  local PLAYER = GetPlayerId(tonumber(args[1]))
  local value = tonumber(args[2])
  if not value then return end
  if STAFF.group == "owner" then 
    if PLAYER then 
      PLAYER.AddTokens(value)
      PLAYER.sendTrigger("ShowAboveRadarMessage", ("You received ~HUD_COLOUR_GREYLIGHT~%s ~s~tokens."):format(value))
    end
  end
end)


_AddEventHandler("playerDropped", function()
  local src = source
  local PLAYER = GetPlayerId(src)
  if PLAYER then 
    SavePlayer(src, true)
  end
end)

RegisterCommand("delete_perso", function(source, args)
  local src = source
  local STAFF = GetPlayerId(src)
  local PLAYER = GetPlayerId(tonumber(args[1]))
  if STAFF.group == "owner" then 
    if PLAYER then 

      MySQL.Async.execute("DELETE FROM players WHERE uuid = @uuid", {["@uuid"] = PLAYER.uuid}, function(rowsChanged)
        if rowsChanged > 0 then 
          print("Player deleted")

          if PLAYER then
            DropPlayer(PLAYER.source, "Wipe")
          end
        end
      end)
    end
  end
end)

RegisterCommand("delete_perso_uuid", function(source, args)
  local src = source
  local STAFF = GetPlayerId(src)
  local uuid = tonumber(args[1])
  if uuid == nil then return end

  if STAFF.group == "owner" then 

    MySQL.Async.execute("DELETE FROM players WHERE uuid = @uuid", {["@uuid"] = uuid}, function(rowsChanged)
      if rowsChanged > 0 then 
        print("Player deleted")
      end
    end)
  end
end)

RegisterCommand("setrank", function(source, args)
  local src = source
  local STAFF = GetPlayerId(src)
  local PLAYER = GetPlayerId(tonumber(args[1]))
  local rank = args[2]
  if STAFF.group == "owner" then 
    if PLAYER then 
      PLAYER.setRank(rank)
    end
  end
end)

function ReturnUsernameWithTagAndColor(src)
  if not src then
    return "Unknown Player"
  end
  
  local username = ReturnUsername(src)
  return GetTextWithGameColors(username, false)
end

function ReturnUsernameWithTagAndColorUUID(uuid)
    if not uuid then
      return "Unknown Player"
    end
    
    local username = ReturnUsernameUUID(uuid)
    return GetTextWithGameColors(username, false)
end

function SearchUuidInDatabase(uuid)
  local results = MySQL.Sync.fetchAll("SELECT * FROM players WHERE uuid = @uuid", {["@uuid"] = uuid})
  if results[1] then
    return results[1]
  end
  return false
end

function GetPlayerUUIDBySource(source)
  local src = tonumber(source)
  for k, v in pairs(Players) do 
    if v.source == src then
      return v.uuid
    end
  end
  return nil
end

function GetRolePlayer(src)
    local intSource = tonumber(src)
    local PLAYER_DATA = GetPlayerId(intSource)
    return PLAYER_DATA.role
end

exports("GetRolePlayer", GetRolePlayer)

function GetPlayerGroup(src)
  local intSource = tonumber(src)
  local PLAYER_DATA = GetPlayerId(intSource)
  return PLAYER_DATA.group
end

exports("GetPlayerGroup", GetPlayerGroup)

RegisterCommand("reset_all_tokens", function(source, args)
  local src = source
  if source == 0 then 
    local players = MySQL.query.await("SELECT * FROM players")
    for k, v in pairs(players) do 
      v.token = 5000
      MySQL.update("UPDATE players SET token = @token WHERE uuid = @uuid", {["@token"] = 5000, ["@uuid"] = v.uuid})
      print(v.username, "TOKEN RESET")
    end
  end
end, true)

RegisterCommand("reset_all_kills", function(source, args)
    local src = source
    if source == 0 then 
      local players = MySQL.query.await("SELECT * FROM players")
      for k, v in pairs(players) do 
        v.kills_global = 0  
        v.death_global = 0
        MySQL.update("UPDATE players SET kills_global = @kills_global, death_global = @death_global WHERE uuid = @uuid", {["@kills_global"] = 0, ["@death_global"] = 0, ["@uuid"] = v.uuid})
        print(v.username, "KILLS RESET")
      end
    end
end, true)

function GetLicenceFromUUID(uuid)
  local results = MySQL.Sync.fetchAll("SELECT * FROM players WHERE uuid = @uuid", {["@uuid"] = uuid})
  if results[1] then
    return results[1].license
  end
  return false
end

-- RegisterCommand("wipe_staff", function(source, args)
  
-- end)

RegisterCommand("wipe", function(source, args)
    local STAFF = GetPlayerId(source) or 0
    if STAFF.group == "owner" or source == 0 then
      local uuid = tonumber(args[1])
      if uuid == nil then return end
      local licence = GetLicenceFromUUID(uuid)
      if not licence then return end
      local wipeInventory = MySQL.query.await("SELECT * FROM inventory WHERE identifier = @identifier", {["@identifier"] = licence})
      if wipeInventory[1] then
        MySQL.Async.execute("DELETE FROM inventory WHERE identifier = @identifier", {["@identifier"] = licence})
        print("Inventory wiped")
      end
      MySQL.Async.execute("UPDATE players SET token = @token, inventory = @inventory, prestige = @prestige, kills_global = @kills_global, death_global = @death_global, xp = @xp, crewId = @crewId, permissions = @permissions, `group` = @group, rank = @rank WHERE uuid = @uuid", 
      {
        ["@token"] = 0,
        ["@inventory"] = json.encode({}),
        ["@uuid"] = uuid,
        ["@prestige"] = 0,
        ["@kills_global"] = 0,
        ["@death_global"] = 0,
        ["@xp"] = 0,
        ["@crewId"] = 0, 
        ["@permissions"] = 0,
        ["@group"] = "user",
        ["@rank"] = "user",
      }, 
      function(rowsChanged)
        if rowsChanged > 0 then 
          print("Player wiped - Tokens reset to 0 and inventory cleared for UUID: " .. uuid)
          
          local playerData = PlayersIsOnlineUUID(uuid)
          if playerData then
            playerData.token = 0
            playerData.prestige = 0
            playerData.kills_global = 0
            playerData.death_global = 0
            playerData.xp = 0
            playerData.crewId = 0
            playerData.permissions = 0
            playerData.group = "user" 
            playerData.rank = "user"
            local identifiers = GetPlayerIdentifiers(playerData.source)
            if identifiers and identifiers[1] then
              exports["gamemode"]:ClearInventory(playerData.source, "inventory")
              exports["gamemode"]:ClearInventory(playerData.source, "protected")
              
              DoNotif(playerData.source, "Your account has been wiped - all tokens and items have been removed.")
              Wait(10000) 
            end
          end
        end
      end)
    end
end)

RegisterCommand("wipe", function(source, args)
  local STAFF = GetPlayerId(source) or 0
  if STAFF.group == "owner" or source == 0 then
    local uuid = tonumber(args[1])
    if uuid == nil then return end
    local licence = GetLicenceFromUUID(uuid)
    if not licence then return end
    local wipeInventory = MySQL.query.await("SELECT * FROM inventory WHERE identifier = @identifier", {["@identifier"] = licence})
    if wipeInventory[1] then
      MySQL.Async.execute("DELETE FROM inventory WHERE identifier = @identifier", {["@identifier"] = licence})
      print("Inventory wiped")
    end
    MySQL.Async.execute("UPDATE players SET token = @token, inventory = @inventory, prestige = @prestige, kills_global = @kills_global, death_global = @death_global, xp = @xp, crewId = @crewId, permissions = @permissions, `group` = @group, rank = @rank WHERE uuid = @uuid", 
    {
      ["@token"] = 0,
      ["@inventory"] = json.encode({}),
      ["@uuid"] = uuid,
      ["@prestige"] = 0,
      ["@kills_global"] = 0,
      ["@death_global"] = 0,
      ["@xp"] = 0,
      ["@crewId"] = 0, 
      ["@permissions"] = 0,
      ["@group"] = "user",
      ["@rank"] = "user",
    }, 
    function(rowsChanged)
      if rowsChanged > 0 then 
        print("Player wiped - Tokens reset to 0 and inventory cleared for UUID: " .. uuid)
        
        local playerData = PlayersIsOnlineUUID(uuid)
        if playerData then
          playerData.token = 0
          playerData.prestige = 0
          playerData.kills_global = 0
          playerData.death_global = 0
          playerData.xp = 0
          playerData.crewId = 0
          playerData.permissions = 0
          playerData.group = "user" 
          playerData.rank = "user"
          local identifiers = GetPlayerIdentifiers(playerData.source)
          if identifiers and identifiers[1] then
            exports["gamemode"]:ClearInventory(playerData.source, "inventory")
            exports["gamemode"]:ClearInventory(playerData.source, "protected")
            
            DoNotif(playerData.source, "Your account has been wiped - all tokens and items have been removed.")
            Wait(10000) 
          end
        end
      end
    end)
  end
end)


RegisterCommand("wipe_stuff", function(source, args)
    local STAFF = GetPlayerId(source) or 0
    if STAFF.group == "owner" or source == 0 then
      local uuid = tonumber(args[1])
      if uuid == nil then return end
      local licence = GetLicenceFromUUID(uuid)
      if not licence then return end
      local wipeInventory = MySQL.query.await("SELECT * FROM inventory WHERE identifier = @identifier", {["@identifier"] = licence})
      if wipeInventory[1] then
        MySQL.Async.execute("DELETE FROM inventory WHERE identifier = @identifier", {["@identifier"] = licence})
        print("Inventory wiped")
      end
      MySQL.Async.execute("UPDATE players SET inventory = @inventory, permissions = @permissions, `group` = @group, rank = @rank WHERE uuid = @uuid", 
      {
        ["@inventory"] = json.encode({}),
        ["@uuid"] = uuid,
        ["@permissions"] = 0,
        ["@group"] = "user",
        ["@rank"] = "user",
      }, 
      function(rowsChanged)
        if rowsChanged > 0 then 
          print("Player wiped - Tokens reset to 0 and inventory cleared for UUID: " .. uuid)
          
          local playerData = PlayersIsOnlineUUID(uuid)
          if playerData then
            playerData.permissions = 0
            playerData.group = "user" 
            playerData.rank = "user"
            local identifiers = GetPlayerIdentifiers(playerData.source)
            if identifiers and identifiers[1] then
              exports["gamemode"]:ClearInventory(playerData.source, "inventory")
              exports["gamemode"]:ClearInventory(playerData.source, "protected")
              
              DoNotif(playerData.source, "Your account has been wiped - all tokens and items have been removed.")
              Wait(10000) 
            end
          end
        end
      end)
    end
end)

RegisterCommand("demote", function(source, args)
    local STAFF = GetPlayerId(source) or 0
    if STAFF.group == "owner" or source == 0 then
      local uuid = tonumber(args[1])
      if uuid == nil then return end
      local licence = GetLicenceFromUUID(uuid)
      if not licence then return end
      MySQL.Async.execute("UPDATE players SET `group` = @group, rank = @rank WHERE uuid = @uuid", 
      {
        ["@uuid"] = uuid,
        ["@group"] = "user",
        ["@rank"] = "user",
      }, 
      function(rowsChanged)
        if rowsChanged > 0 then 
          
          local playerData = PlayersIsOnlineUUID(uuid)
          if playerData then
            playerData.permissions = 0
            playerData.group = "user" 
            playerData.rank = "user"
          end
        end
      end)
    end
end)

RegisterCommand("demote_console", function(source, args)
    if source == 0 then
      local uuid = tonumber(args[1])
      if uuid == nil then return end
      local licence = GetLicenceFromUUID(uuid)
      if not licence then return end
      MySQL.Async.execute("UPDATE players SET `group` = @group, rank = @rank WHERE uuid = @uuid", 
      {
        ["@uuid"] = uuid,
        ["@group"] = "user",
        ["@rank"] = "user",
      }, 
      function(rowsChanged)
        if rowsChanged > 0 then 
          
          local playerData = PlayersIsOnlineUUID(uuid)
          if playerData then
            playerData.permissions = 0
            playerData.group = "user" 
            playerData.rank = "user"
          end
        end
      end)
    end
end)

RegisterCommand("reset_all_deaths", function(source, args)
    local src = source
    if source == 0 then 
      local players = MySQL.query.await("SELECT * FROM players")
      for k, v in pairs(players) do 
        v.death_global = 0  
        MySQL.update("UPDATE players SET death_global = @death_global WHERE uuid = @uuid", {["@death_global"] = 0, ["@uuid"] = v.uuid})
        print(v.username, "DEATHS RESET")
      end
    end
  end, true)

Citizen.CreateThread(function()
    while true do 
        Wait(1000 * 60 * 5)
        TriggerClientEvent('chat:addMessage', -1, { 
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgb(0 173 255 / 60%);"><i class="fas fa-user-crown"></i> {0} </div>',
            args = { "^#01ffc4Tebex: ^7\nIf you want to buy items, you can go to the tebex. \nhttps://store.guildpvp.fr/"}, color = { 0, 153, 153 } 
        })
        Wait(1000 * 60 * 5)
        TriggerClientEvent('chat:addMessage', -1, { 
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgb(0 173 255 / 60%);"><i class="fas fa-user-crown"></i> {0} </div>',
            args = { "^#01ffc4Tebex: ^7\nYou can buy a role in the tebex. \nhttps://store.guildpvp.fr/"}, color = { 255, 222, 1 } 
        })
    end
end)

-- RegisterCommand('change_skin', function(source, args)
--     local src = source
--     local STAFF = GetPlayerId(src)
--     if STAFF.group ~= "owner" then return end
--     print(STAFF.skin.model, "MODEL")
--     STAFF.skin.model = "mp_f_freemode_01"
--     MySQL.update("UPDATE players SET skin = @skin WHERE uuid = @uuid", {["@skin"] = json.encode(STAFF.skin), ["@uuid"] = STAFF.uuid})
-- end)

Discord.Register('logs_transferpoint', 'Transfer Point', 'logs-transferpoint');

RegisterCommand("transferpoint", function(source, args)
  local src = source
  local PLAYER = GetPlayerId(src)
  
  local target = GetPlayerId(tonumber(args[1]))
  if not target then
    DoNotif(src, ("You didn't specify the ID of the player to transfer the tokens to."))
    return
  end
  if tonumber(args[2]) > 1000000 then
    DoNotif(src, ("You can't transfer more than 1.000.000 tokens at a time."))
    return
  end
  if PLAYER and target then 
    if tonumber(args[2]) == nil then
      DoNotif(src, ("You didn't specify the amount of tokens to transfer."))
      return
    end

    if tonumber(args[2]) > 0 then 
        if PLAYER.token < tonumber(args[2]) then DoNotif(src, ("You don't have enough tokens to transfer.")) return end
        PLAYER.RemoveTokens(tonumber(args[2]))
        target.AddTokens(tonumber(args[2]))
        DoNotif(src, ("You have transferred ~HUD_COLOUR_GREYLIGHT~%s ~s~tokens to ~HUD_COLOUR_GREYLIGHT~%s"):format(tonumber(args[2]), target.username))
        DoNotif(target.source, ("You have received ~HUD_COLOUR_GREYLIGHT~%s ~s~tokens from ~HUD_COLOUR_GREYLIGHT~%s"):format(tonumber(args[2]), PLAYER.username))
        local message = DiscordMessage();
        message:AddField()
            :SetName("From")
            :SetValue(PLAYER.username.." ("..PLAYER.uuid..") | Discord ID: <@"..DiscordId(src)..">");
        message:AddField()
            :SetName("To")
            :SetValue(target.username.." ("..target.uuid..") | Discord ID: <@"..DiscordId(target.source)..">");
        message:AddField()
            :SetName("Amount")
            :SetValue("`"..tonumber(args[2]).."` @here");
        Discord.Send("logs_transferpoint", message);
    end
  end
end)

RegisterCommand("uuid_discord", function(source, args)
  if source ~= 0 then return end
  
  local src = source
  local discordId = args[1]
  local discordIdentifier = "discord:" .. discordId
  
  MySQL.Async.fetchAll("SELECT uuid, username, identifiers FROM players", {}, function(results)
    if results and #results > 0 then
      local found = false
      for _, player in ipairs(results) do
        local identifiers = json.decode(player.identifiers)
        for _, identifier in ipairs(identifiers) do
          if identifier == discordIdentifier then
            print("Player found: " .. player.username .. " (UUID: " .. player.uuid .. ")")
            found = true
            break
          end
        end
        if found then break end
      end
      
      if not found then
        print("No player found with Discord ID: " .. discordId)
      end
    else
      print("No players in database")
    end
  end)
end, false)

RegisterCommand("identifiers_discord", function(source, args)
  if source ~= 0 then return end
  
  local src = source
  local discordId = args[1]
  if not discordId then
    print("Usage: identifiers_discord <discord_id>")
    return
  end
  
  local discordIdentifier = "discord:" .. discordId
  
  MySQL.Async.fetchAll("SELECT uuid, username, identifiers FROM players", {}, function(results)
    if results and #results > 0 then
      local found = false
      for _, player in ipairs(results) do
        local identifiers = json.decode(player.identifiers)
        for _, identifier in ipairs(identifiers) do
          if identifier == discordIdentifier then
            print("=== Player found ===")
            print("Username: " .. player.username)
            print("UUID: " .. player.uuid)
            print("All identifiers:")
            for i, id in ipairs(identifiers) do
              print("  " .. i .. ": " .. id)
            end
            print("===================")
            found = true
            break
          end
        end
        if found then break end
      end
      
      if not found then
        print("No player found with Discord ID: " .. discordId)
      end
    else
      print("No players in database")
    end
  end)
end, false)

RegisterCommand("add_tokens_all", function(source, args)
  if source ~= 0 then return end
  
  print("Starting to add 100,000 tokens to all players...")
  
  local players = MySQL.query.await("SELECT * FROM players")
  local totalPlayers = 0
  local updatedPlayers = 0
  
  for k, v in pairs(players) do 
    totalPlayers = totalPlayers + 1
    local newTokenAmount = v.token + 5000
    
    MySQL.update("UPDATE players SET token = @token WHERE uuid = @uuid", {
      ["@token"] = newTokenAmount, 
      ["@uuid"] = v.uuid
    })
    
    -- Update player data if they are online
    local onlinePlayer = PlayersIsOnlineUUID(v.uuid)
    if onlinePlayer then
      onlinePlayer.token = newTokenAmount
      onlinePlayer.sendTrigger("ShowAboveRadarMessage", "You received ~HUD_COLOUR_GREYLIGHT~5,000 ~s~tokens from server administration!")
    end
    
    updatedPlayers = updatedPlayers + 1
    print(v.username .. " (UUID: " .. v.uuid .. ") - Added 5,000 tokens (New total: " .. newTokenAmount .. ")")
  end
  
  print("=== TOKEN DISTRIBUTION COMPLETE ===")
  print("Total players processed: " .. totalPlayers)
  print("Players updated: " .. updatedPlayers)
  print("Tokens distributed per player: 5,000")
  print("Total tokens distributed: " .. (updatedPlayers * 5000))
  print("===================================")
end, true)

-- Event to allow players to request their current ranking
_RegisterServerEvent("gamemode:requestPlayerRanking", function()
    local src = source
    local player = GetPlayerId(src)
    
    if not player then return end
    
    GetPlayerRankingSQL(player.uuid, function(playerRanking)
        _TriggerClientEvent("gamemode:receivePlayerRanking", src, playerRanking)
    end)
end)

-- Command to check player ranking
RegisterCommand("myrank", function(source, args)
    local src = source
    local player = GetPlayerId(src)
    
    if not player then return end
    
    GetPlayerRankingSQL(player.uuid, function(playerRanking)
        if playerRanking then
            DoNotif(src, ("Your Rankings:\n~HUD_COLOUR_GREYLIGHT~Kills: ~s~#%s\n~HUD_COLOUR_GREYLIGHT~Deaths: ~s~#%s\n~HUD_COLOUR_GREYLIGHT~Tokens: ~s~#%s"):format(
                playerRanking.killsRank or "N/A",
                playerRanking.deathRank or "N/A", 
                playerRanking.tokenRank or "N/A"
            ))
        else
            DoNotif(src, "Unable to retrieve your ranking at the moment.")
        end
    end)
end)

-- Fallback function for compatibility
function GetDbStats()
  GetDbStatsOptimized()
end

-- Command to manually refresh leaderboard (admin only)
RegisterCommand("refresh_leaderboard", function(source, args)
    local src = source
    if src == 0 or (GetPlayerId(src) and GetPlayerId(src).group == "owner") then
        GetDbStatsOptimized()
        if src ~= 0 then
            DoNotif(src, "Leaderboard has been refreshed.")
        else
            print("Leaderboard has been refreshed.")
        end
    end
end)

RegisterCommand("add_stats", function(source, args)
    local STAFF = GetPlayerId(source)
    if STAFF.group == "owner" then
        local uuid = tonumber(args[1])
        local kills = tonumber(args[2])
        local deaths = tonumber(args[3])
        
        if uuid == nil or kills == nil or deaths == nil then 
            if source ~= 0 then
                DoNotif(source, "Usage: /add_stats [uuid] [kills] [deaths]")
            else
                print("Usage: add_stats [uuid] [kills] [deaths]")
            end
            return 
        end

        MySQL.Async.fetchAll("SELECT kills_global, death_global FROM players WHERE uuid = @uuid", {["@uuid"] = uuid}, function(result)
            if result[1] then
                local newKills = result[1].kills_global + kills
                local newDeaths = result[1].death_global + deaths
                
                MySQL.Async.execute("UPDATE players SET kills_global = @kills_global, death_global = @death_global WHERE uuid = @uuid", 
                {
                    ["@kills_global"] = newKills,
                    ["@death_global"] = newDeaths,
                    ["@uuid"] = uuid
                }, 
                function(rowsChanged)
                    if rowsChanged > 0 then 
                        print("Stats updated for UUID: " .. uuid .. " - Added " .. kills .. " kills and " .. deaths .. " deaths")
                        
                        local playerData = PlayersIsOnlineUUID(uuid)
                        if playerData then
                            playerData.kills_global = newKills
                            playerData.death_global = newDeaths
                            
                            DoNotif(playerData.source, ("Your stats have been updated: +%s kills, +%s deaths"):format(kills, deaths))
                        end
                    end
                end)
            else
                if source ~= 0 then
                    DoNotif(source, "Player with UUID " .. uuid .. " not found")
                else
                    print("Player with UUID " .. uuid .. " not found")
                end
            end
        end)
    end
end)


RegisterCommand("wipe_all_players", function(source, args)
    if source ~= 0 then return end
    
    local players = MySQL.query.await("SELECT * FROM players")
    local totalPlayers = 0
    local updatedPlayers = 0
    
    print("=== STARTING MASS WIPE ===")
    
    for k, v in pairs(players) do 
      totalPlayers = totalPlayers + 1
      
      -- Reset les stats
      MySQL.update("UPDATE players SET token = @token, xp = @xp, prestige = @prestige, crewId = @crewId, death_global = @death_global, kills_global = @kills_global, inventory = @inventory WHERE uuid = @uuid", {
        ["@token"] = 0, 
        ["@xp"] = 0, 
        ["@prestige"] = 0, 
        ["@crewId"] = 0, 
        ["@death_global"] = 0, 
        ["@kills_global"] = 0,
        ["@inventory"] = json.encode({}),
        ["@uuid"] = v.uuid
      })
      
      -- Supprime l'inventaire dans la table inventory
      MySQL.update("DELETE FROM inventory WHERE identifier = @license", {
        ["@license"] = v.license
      }, function()
        print("Inventory wiped for player", v.username)
      end)
      
      updatedPlayers = updatedPlayers + 1
      print(v.username .. " (UUID: " .. v.uuid .. ") - Stats and inventory wiped")
    end
    
    print("=== MASS WIPE COMPLETE ===")
    print("Total players processed: " .. totalPlayers)
    print("Players updated: " .. updatedPlayers)
    print("===================================")
end, true)

RegisterCommand("all_staffs", function(source, args)
  if source ~= 0 then return end
  
  local players = MySQL.query.await("SELECT * FROM players")
  print("=== STAFF LIST ===")
  for k, v in pairs(players) do 
    if v.group ~= "user" then
      local discordInfo = ""
      local identifiers = json.decode(v.identifiers)
      for _, identifier in ipairs(identifiers) do
        if string.find(identifier, "discord:") then
          discordInfo = " | Discord: " .. string.sub(identifier, 9)
        end
      end
      print(v.username .. " | " .. v.group .. " | UUID: " .. v.uuid .. discordInfo)
    end
  end
  print("================")
end, true)