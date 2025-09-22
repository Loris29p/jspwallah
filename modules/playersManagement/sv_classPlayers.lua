playerManagement = {}


function playerManagement:CreatePlayers(src, data)
  local self = {}

  -- default flag
  self.flag = CountryFlag["FR"]

  local myIp = GetIP2(src)
  PerformHttpRequest("http://ip-api.com/json/" .. myIp, function(err, text, headers)
    local country = json.decode(text)
    if country.countryCode ~= nil and CountryFlag[country.countryCode] then
      self.flag = CountryFlag[country.countryCode]
    end
  end)

  self.role = "user"
  self.source = src
  self.license = data.license
  self.username = SetRemoveSpace(data.username)
  self.uuid = tonumber(data.uuid)
  self.token = tonumber(data.token)
  self.skin = json.decode(data.skin)
  self.coins = tonumber(data.coins)
  self.rank = data.rank
  self.group = data.group
  self.prestige = tonumber(data.prestige)
  self.permissions = tonumber(data.permissions)
  self.informations = json.decode(data.informations)
  self.inventory = json.decode(data.inventory) or {}
  self.stats = json.decode(data.stats)
  self.data = json.decode(data.data)
  self.cosmetics = json.decode(data.cosmetics)
  self.settings = json.decode(data.settings)
  self.crewId = tonumber(data.crewId)
  self.xp = tonumber(data.xp)
  self.identifiers = json.decode(data.identifiers)
  self.blacklist = data.blacklist
  self.kills_global = data.kills_global
  self.death_global = data.death_global
  self.inSquad = false
  self.firstConnection = tonumber(data.firstConnection)
  self.gamemode = "Lobby"

  if DiscordId(src) then
    self.discordId = DiscordId(src)

    if DiscordRole(self.discordId, "support") then
      self.isBooster = true
    end

    if DiscordRole(self.discordId, "streamer") then
      self.streamer = true
    end
  end

  if DiscordId(src) then
    print("^3[PlayerRole] Vérification des rôles Discord pour: " .. self.username .. " (Discord ID: " .. self.discordId .. ")")
    
    -- Vérification des rôles par ordre de priorité (du plus élevé au plus bas)
    if DiscordRole(self.discordId, "boss") then
      self.role = "boss"
      print("^2[PlayerRole] Rôle assigné: BOSS pour " .. self.username)
    elseif DiscordRole(self.discordId, "god") then
      self.role = "god"
      print("^2[PlayerRole] Rôle assigné: GOD pour " .. self.username)
    elseif DiscordRole(self.discordId, "mvp") then
      self.role = "mvp"
      print("^2[PlayerRole] Rôle assigné: MVP pour " .. self.username)
    elseif DiscordRole(self.discordId, "vip+") then
      self.role = "vip+"
      print("^2[PlayerRole] Rôle assigné: VIP+ pour " .. self.username)
    elseif DiscordRole(self.discordId, "vip") then
      self.role = "vip"
      print("^2[PlayerRole] Rôle assigné: VIP pour " .. self.username)
    elseif DiscordRole(self.discordId, "support") then
      self.role = "support"
      print("^2[PlayerRole] Rôle assigné: SUPPORT pour " .. self.username)
    elseif DiscordRole(self.discordId, "invite") then
      self.role = "invite"
      print("^2[PlayerRole] Rôle assigné: INVITE pour " .. self.username)
    else
      print("^1[PlayerRole] Aucun rôle Discord trouvé pour " .. self.username .. ", rôle par défaut: user")
    end
  else
    print("^1[PlayerRole] Aucun Discord ID trouvé pour " .. self.username)
  end

  if not self.firstConnection then
    self.firstConnection = os.time()
    MySQL.Async.execute("UPDATE players SET firstConnection = @firstConnection WHERE license = @license", {
      ["@firstConnection"] = self.firstConnection,
      ["@license"] = self.license
    })
  else
    self.firstConnection = tonumber(self.firstConnection)
  end

  local fiveDaysInSeconds = 2 * 24 * 60 * 60
  if (os.time() - self.firstConnection) < fiveDaysInSeconds then
    self.isNew = true
  else
    self.isNew = false
  end

  self.setNickname = function(nickname)
    self.username = SetRemoveSpace(nickname)
  end

  self.getGamemode = function() return self.gamemode end
  self.setGamemode = function(gamemode)
    self.gamemode = gamemode
  end

  -- self.maxWeight = (self.rank == "gold" and 45.0) or (self.rank == "diamond" and 50.0) or (self.prestige == tonumber(1) and 42.0) or (self.prestige == tonumber(2) and 44.0) or (self.prestige == tonumber(3) and 46.0) or 40.0

  -- self.maxSafeWeight = (self.rank == "gold" and 40.0) or (self.rank == "diamond" and 50.0) or (self.prestige == tonumber(1) and 35.0) or (self.prestige == tonumber(2) and 38.0) or (self.prestige == tonumber(3) and 45.0) or 30.0

  self.maxWeight = (self.role == "vip" and 1000000000000.0) or (self.role == "vip+" and 1000000000000.0) or
  (self.role == "mvp" and 1000000000000.0) or (self.role == "boss" and 1000000000000.0) or
  (self.prestige == tonumber(1) and 1000000000000.0) or (self.prestige == tonumber(2) and 1000000000000.0) or
  (self.prestige == tonumber(3) and 1000000000000.0) or 1000000000000.0

  self.maxSafeWeight = (self.role == "vip" and 1000000000000.0) or (self.role == "vip+" and 1000000000000.0) or
  (self.role == "mvp" and 1000000000000.0) or (self.role == "boss" and 1000000000000.0) or
  (self.prestige == tonumber(1) and 1000000000000.0) or (self.prestige == tonumber(2) and 1000000000000.0) or
  (self.prestige == tonumber(3) and 1000000000000.0) or 1000000000000.0

  self.SquadInfo = function(bool)
    self.inSquad = bool
  end

  self.RandomXP = function()
    local xpADded = math.random(300, 500)
    self.xp = self.xp + xpADded
    _TriggerClientEvent("XNL_NET:AddPlayerXP", self.source, xp)
  end

  self.AddXP = function(value)
    self.xp = self.xp + tonumber(value)
    _TriggerClientEvent("XNL_NET:AddPlayerXP", self.source, tonumber(value))
  end

  self.GetXP = function()
    return self.xp
  end

  self.RemoveXP = function(value)
    local preview = self.xp - value
    if preview < 0 then
      return false
    end
    self.xp = preview
    return true
  end

  self.AddNewData = function(key, value)
    self.data[key] = value
  end

  self.RemoveData = function(key)
    self.data[key] = nil
  end

  self.DataReplace = function(key, value)
    self.data[key] = value
  end

  self.AddDataToKey = function(key, value)
    if not self.data[key] then
      self.data[key] = {}
    end
    table.insert(self.data[key], value)
  end

  self.GetData = function()
    return self.data
  end

  self.AddKills = function()
    self.kills_global = self.kills_global + 1
  end

  self.AddDeath = function()
    self.death_global = self.death_global + 1
  end

  self.sendTrigger = function(event, data)
    _TriggerClientEvent(event, self.source, data)
  end

  self.AddTokens = function(value)
    self.token = tonumber(self.token) + tonumber(value)
  end

  self.RemoveTokens = function(value)
    local preview = self.token - value
    if preview < 0 then
      return false
    end
    self.token = preview
    return true
  end


  self.AddCoins = function(value)
    local preview = self.coins + value
    if preview < 0 then
      return false
    end
    self.coins = preview
    return true
  end

  self.RemoveCoins = function(value)
    local preview = self.coins - value
    if preview < 0 then
      return false
    end
    self.coins = preview
    return true
  end

  self.GetCoins = function()
    return self.coins
  end

  self.setRank = function(rank)
    self.rank = rank
  end

  self.resetStats = function()
    self.kills_global = 0
    self.death_global = 0
  end

  return self
end

RegisterCommand("reset_stats", function(source, args)
  local player = GetPlayerId(source)
  if player then
    if player.role == "mvp" or player.role == "boss" then
      player.resetStats()
    else
      DoNotif(source, "~r~You don't have permission to use this command")
    end
  end
end)

function AddTokensByZombie(src, value)
  local player = GetPlayerId(src)
  player.AddTokens(value)
end

function AddXPByZombies(src, value)
  local player = GetPlayerId(src)
  player.AddXP(value)
end

exports("AddXPByZombies", function(src, value)
  AddXPByZombies(src, value)
end)

exports("AddTokensByZombie", function(src, value)
  AddTokensByZombie(src, value)
end)

_AddEventHandler("gamemode:RandomXP", function()
  local player = GetPlayerId(source)
  player.RandomXP()
end)

_AddEventHandler("gamemode:AddTokens", function(value)
  local player = GetPlayerId(source)
  player.AddTokens(value)
end)


_RegisterServerEvent("gamemode:saveAppearance", function(app)
  if not app then return end

  if type(app) == "table" then
    local src = source
    local PLAYER = GetPlayerId(src)

    MySQL.Async.fetchAll("SELECT * FROM players WHERE license = @license", { ["@license"] = PLAYER.license },
      function(result)
        if result[1] then
          MySQL.Async.execute("UPDATE players SET skin = @skin WHERE license = @license",
            { ["@skin"] = json.encode(app), ["@license"] = PLAYER.license }, function(rowsChanged)
            if rowsChanged > 0 then
              PLAYER.skin = app
            end
          end)
        end
      end)
  end
end)

RegisterCommand("addcoins", function(source, args)
  if source == 0 then
    local player = GetPlayerId(tonumber(args[1]))
    player.AddCoins(tonumber(args[2]))
  end
end)

function GetStreamerRole(src)
  local player = GetPlayerId(src)
  return player.streamer and true or false
end

exports("GetStreamerRole", function(src)
  return GetStreamerRole(src)
end)
