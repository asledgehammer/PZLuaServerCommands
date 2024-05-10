--- @param x - The x coordinate. (In World-Space)
--- @param y - The y coordinate. (In World-Space)
--- @param attemptsMax - (Optional) The maximum amount of random attempts. (Default: 128)
--- @return - The next random square.
getRandomZSquare = function(x, y, attemptsMax)
    if attemptsMax == nil then attemptsMax = 128 end
    local attempts = 0
    local square = nil
    while square == nil do
        if attempts > attemptsMax then break end
        local z = toInt(ZombRand(0, 7))
        square = getSquare(x, y, z)
        -- Make sure the square can be walked on.
        if square ~= nil then 
            if square:hasFloor(false) == false then
                square = nil
            elseif square:getBuilding() == nil then
                if z ~= 0 then square = nil end
            end
        end
        attempts = attempts + 1
    end
    return square
end

randomFloat = function()
    return ZombRand(1000000000) / 1000000000
end

coordsToString = function(x, y, z)
    return '{x: '..tostring(x)..', y: '..tostring(y)..', z: '..tostring(z)..'}'
end

getSquares = function(x1, y1, z1, x2, y2, z2)
    local squares = {}
    local index = 0
    for wz = z1, z2, 1 do
        for wy = y1, y2, 1 do
            for wx = x1, x2, 1 do
                local square = getSquare(wx, wy, wz)
                if square ~= nil then
                    squares[index] = square
                    index = index + 1
                end
            end
        end
    end
    return squares
end

arrayToString = function(array, name)
    local lines = tostring(name)..': {'
    for i = 1, #array, 1 do
        lines = lines..'\n\t'..tostring(array[i])..','
    end
    return lines..'\n}'
end

arrayMap = function(array, consumer)
    local a = {}
    local index = 1
    for i = 1, #array, 1 do
        local c = consumer(array[i])
        if c ~= nil then
            a[index] = c
            index = index + 1
        end
    end
    return a
end

getObjectsAtSquare = function(square, name)
    local barricades = {}
    local index = 1
    local objects = square:getObjects()
    local size = objects:size()
    if size == 0 then return barricades end
    local lastIndex = size - 1
    for i = 0, lastIndex, 1 do
        local object = objects:get(i)
        if object:getObjectName() == name then
             barricades[index] = object
             index = index + 1
        end
    end
    return barricades
end

getSpecialObjectsAtSquare = function(square, name)
    local barricades = {}
    local index = 1
    local objects = square:getSpecialObjects()
    local size = objects:size()
    if size == 0 then return barricades end
    local lastIndex = size - 1
    for i = 0, lastIndex, 1 do
        local object = objects:get(i)
        if object:getObjectName() == name then
             barricades[index] = object
             index = index + 1
        end
    end
    return barricades
end

getNearbyWindows = function(x, y, z, radius)
    if x < 0 or y < 0 or z < 0 then return {} end
    local x1 = x - radius
    local y1 = y - radius
    local z1 = math.min(0, z - radius)
    local x2 = x + radius
    local y2 = y + radius
    local z2 = math.max(7, z + radius)
    local squares = getSquares(x1, y1, z1, x2, y2, z2)
    return arrayMap(squares, function(square)
        local objects = square:getObjects()
        local size = objects:size()
        if size == 0 then return nil end
        local lastIndex = size - 1
        for i = 0, lastIndex, 1 do
            local object = objects:get(i)
            local s = tostring(object)
            if string.find(s, 'IsoWindow@') ~= nil then
                return object
            end
        end
    end)
end

getNearbyDoors = function(x, y, z, radius)
    if x < 0 or y < 0 or z < 0 then return {} end
    local x1 = x - radius
    local y1 = y - radius
    local z1 = math.min(0, z - radius)
    local x2 = x + radius
    local y2 = y + radius
    local z2 = math.max(7, z + radius)
    local squares = getSquares(x1, y1, z1, x2, y2, z2)
    return arrayMap(squares, function(square)
        local objects = square:getObjects()
        local size = objects:size()
        if size == 0 then return nil end
        local lastIndex = size - 1
        for i = 0, lastIndex, 1 do
            local object = objects:get(i)
            local s = tostring(object)
            if string.find(s, 'IsoDoor@') ~= nil then
                return object
            end
        end
    end)
end

barricade = function(obj)
    local helper = LuaServerCommandHelper
    local success = false
    local barricade = nil
    local square = obj:getSquare()
    if square:getRoom() ~= nil then square = obj:getOppositeSquare() end
    local flag = square ~= obj:getSquare()
    local direction = nil
    if obj:getNorth() == true then
        if flag == true then direction = IsoDirections.S else direction = IsoDirections.N end
    else
        if flag == true then direction = IsoDirections.E else direction = IsoDirections.W end
    end
    barricade = IsoBarricade.GetBarricadeOnSquare(square, direction)
    if barricade == nil then
        barricade = IsoBarricade.AddBarricadeToObject(obj, flag)
        if barricade ~= nil then
            barricade:addPlank(nil, nil)
            barricade:transmitCompleteItemToClients()
            success = true
        end
    elseif barricade:getNumPlanks() < 4 then
        barricade:addPlank(nil, nil)
        helper.syncIsoObject(barricade)
        barricade:transmitUpdatedSpriteToClients()
        success = true
    end
    if success then helper.playWorldSoundSquare('hammernail', obj:getSquare(), 24.0) end
    return success
end

unbarricade = function(obj)
    local helper = LuaServerCommandHelper
    local success = false
    local barricade = nil
    local square = obj:getSquare()
    local room = square:getRoom()
    if square:getRoom() ~= nil then square = obj:getOppositeSquare() end
    local flag = square ~= obj:getSquare()
    local direction = nil
    if obj:getNorth() == true then
        if flag == true then direction = IsoDirections.S else direction = IsoDirections.N end
    else
        if flag == true then direction = IsoDirections.E else direction = IsoDirections.W end
    end
    barricade = IsoBarricade.GetBarricadeOnSquare(square, direction)
    if barricade ~= nil and barricade:getNumPlanks() > 0 then
        barricade:removePlank(nil)
        if barricade:getNumPlanks() <= 0 then
            square:transmitRemoveItemFromSquare(barricade)
        else
            helper.syncIsoObject(barricade)
            barricade:transmitUpdatedSpriteToClients()
        end
        success = true
    end
    if success then helper.playWorldSoundSquare('crackwood', obj:getSquare(), 24.0) end
    return success
end

removeBarricade = function(obj)
    local helper = LuaServerCommandHelper
    local success = false
    local barricade = nil
    local square = obj:getSquare()
    local room = square:getRoom()
    if square:getRoom() ~= nil then square = obj:getOppositeSquare() end
    local flag = square ~= obj:getSquare()
    local direction = nil
    if obj:getNorth() == true then
        if flag == true then direction = IsoDirections.S else direction = IsoDirections.N end
    else
        if flag == true then direction = IsoDirections.E else direction = IsoDirections.W end
    end
    barricade = IsoBarricade.GetBarricadeOnSquare(square, direction)
    if barricade ~= nil then
        square:transmitRemoveItemFromSquare(barricade)
        success = true
    end
    if success and barricade:getNumPlanks() > 0 then
        helper.playWorldSoundSquare('crackwood', obj:getSquare(), 24.0)
    end
    return success
end

openCurtain = function(curtain)
    local helper = LuaServerCommandHelper
    if curtain ~= nil and curtain:IsOpen() == false then
        curtain:ToggleDoor(nil)
        helper.syncIsoObject(curtain)
        helper.playWorldSoundSquare(curtain:getSoundPrefix()..'Open', curtain:getSquare(), 24.0)
        return true
    end
    return false
end

closeCurtain = function(curtain)
    local helper = LuaServerCommandHelper
    if curtain ~= nil and curtain:IsOpen() == true then
        curtain:ToggleDoor(nil)
        helper.syncIsoObject(curtain)
        helper.playWorldSoundSquare(curtain:getSoundPrefix()..'Close', curtain:getSquare(), 24.0)
        return true
    end
    return false
end

arrayContains = function(array, val)
    for index, value in ipairs(array) do
        if value == val then return true end
    end
    return false
end

getBuildingsAt = function(x, y, radius)
    if x < 0 or y < 0 then return {} end
    if radius == nil then radius = 256 end
    local x1 = x - radius
    local y1 = y - radius
    local x2 = x + radius
    local y2 = y + radius
    local buildings = {}
    local index = 1
        for wy = y1, y2, 4 do
            for wx = x1, x2, 4 do
                local square = getSquare(wx, wy, 0)
                if square ~= nil then
                    local building = square:getBuilding()
                    if building ~= nil and arrayContains(buildings, building) == false then
                        buildings[index] = building
                        index = index + 1
                    end
                end
            end
        end
    return buildings
end

getDistance = function(x1, y1, x2, y2)
    return math.sqrt(math.abs(math.pow(y2 - y1, 2) + math.pow(x2 - x1, 2)))
end

getNearestBuilding = function(x, y, radius)
    local buildings = getBuildingsAt(x, y, radius)
    if #buildings == 0 then return nil end
    local distance = 999999999
    local buildingNearest = nil
    for i = 1, #buildings, 1 do
        local building = buildings[i]
        local buildingDef = building:getDef()
        local buildingCenterX = math.floor(buildingDef:getX() + (buildingDef:getW() / 2))
        local buildingCenterY = math.floor(buildingDef:getY() + (buildingDef:getH() / 2))
        local calcDistance = getDistance(x, y, buildingCenterX, buildingCenterY)
        if buildingNearest == nil then
            distance = calcDistance
            buildingNearest = building
        elseif distance > calcDistance then
            distance = calcDistance
            buildingNearest = building
        end
    end
    return buildingNearest
end
