ListBooster = {}

function CreateBoosterTable()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS booster (
            id INT AUTO_INCREMENT PRIMARY KEY,
            uuid VARCHAR(255) NOT NULL,
            total_duration INT NOT NULL DEFAULT 1800,
            remaining_time INT NOT NULL DEFAULT 1800,
            end_timestamp BIGINT NULL,
            active BOOLEAN NOT NULL DEFAULT FALSE,
            type VARCHAR(50) NOT NULL DEFAULT 'global',
            action JSON NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
    print("Table booster créée/vérifiée")
end

MySQL.ready(function()
    CreateBoosterTable()
end)

function CreateBooster(tblData)
    if not tblData then return end
    if type(tblData) ~= "table" then return end
    
    MySQL.query.await("INSERT INTO booster (uuid, total_duration, remaining_time, type, action) VALUES (?, ?, ?, ?, ?)", {
        tblData.uuid, 
        tblData.time or 1800, 
        tblData.time or 1800, 
        tblData.type or "global", 
        json.encode(tblData.action or {})
    }, function(result)
        if result then
            ListBooster[tblData.uuid] = ClassBooster:new({
                uuid = tblData.uuid,
                time = tblData.time,
                type = tblData.type,
                action = tblData.action
            })
            print("Booster created")
            return true
        else
            print("Booster not created")
            return false
        end
    end)
end