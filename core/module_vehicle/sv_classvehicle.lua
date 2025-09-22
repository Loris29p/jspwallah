ListVehicle = {
    id = 0,
    model = "",
    data = {},
}


ListVehicle.__index = ListVehicle

function ListVehicle:CreateVeh(data)
    local self = setmetatable({}, ListVehicle)
    self.id = data.id and data.id or math.random(0, 999999)
    self.model = data.model and data.model or nil  
    self.data = data.data and data.data or {}
    return self
end