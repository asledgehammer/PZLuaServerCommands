require 'lua_server_commands'
require 'cmd_utils'

local pi2 = math.pi * 2.0

LuaServerCommands.register('createhordepolygon', function(author, command, args)

    -- Check if the correct number of arguments are passed.
    if #args ~= 3 then
        return '/createhordepolygon [player] [amount=[3->500]] [radius=[3->32]]'
    end

    -- NOTE: The helper only becomes visible in global scope when the first lua server command is fired.
    --       Make sure to reference the helper inside of the command's handler function.
    local helper = LuaServerCommandHelper

    -- Attempt to resolve the player using the helper method.
    local username = args[1]
    local player = helper.getPlayerByUsername(username)
    if player == nil then return 'Player not found: '..tostring(username) end

    -- The amount of zombies is the amount of points in the polygon.
    local points = tonumber(args[2])
    -- This is the distance from the player. (In Tiles)
    local radius = tonumber(args[3])

    -- Clamp the radius and points arguments to prevent things getting out of control.
    if points < 3 then points = 3 end
    if points > 500 then points = 500 end
    if radius < 3 then radius = 3 end
    if radius > 32 then radius = 32 end

    -- Calculate the polygon points, translate it to the player's position as the origin,
    -- and create a zombie at that location.
    for i = 1, points, 1 do 
        local lerp = (i/points)
        local val = lerp * pi2
        local cx = math.cos(val) * radius
        local cy = math.sin(val) * radius
        local zx = player:getX() + cx
        local zy = player:getY() + cy

        -- Make sure the square is valid. (For instance if the player is on the edge of the map)
        local square = getRandomZSquare(zx, zy)
        if square ~= nil then
            local zz = square:getZ()
            -- print('Creating Zed at: {x: '..tostring(zx)..', y: '..tostring(zy)..', z: '..tostring(zz)..'}')
            helper.createZombie(zx, zy, zz)
        end
    end

    return 'Spawned horde circle around player: '
        ..tostring(username)..' (radius: '..tostring(radius)..', points: '..tostring(points)..')'
        
end)

print('Registered Lua Server Command: createhordepolygon')
