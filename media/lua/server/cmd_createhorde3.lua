require 'lua_server_commands'
require 'cmd_utils'

-- Our constants.
local CMD_NAME = 'createhorde3'
local pi2 = math.pi * 2.0

LuaServerCommands.register(CMD_NAME, function(author, command, args)

    -- Check if the correct number of arguments are passed.
    if #args ~= 4 then
        return '/'..CMD_NAME..' [player] [amount=[1->500]] [inner_radius=[0->infinity]] [outer_radius=[inner_radius->infinity]]'
    end

    -- NOTE: The helper only becomes visible in global scope when the first lua server command is fired.
    --       Make sure to reference the helper inside of the command's handler function.
    local helper = LuaServerCommandHelper

    -- Attempt to resolve the player using the helper method.
    local username = args[1]
    local player = helper.getPlayerByUsername(username)
    if player == nil then 
        return 'Player not found: '..tostring(username) 
    end

    local amount = tonumber(args[2])
    local inner_radius = tonumber(args[3])
    local outer_radius = tonumber(args[4])

    -- Check to make sure that the parameters are valid.
    if amount <= 0 then return CMD_NAME..': Amount is less than or equal to zero. No zombies spawned.' end
    if amount > 500 then amount = 500 end
    if inner_radius < 0 then inner_radius = 0 end
    if outer_radius < inner_radius then outer_radius = inner_radius end
    if outer_radius == 0 then return CMD_NAME..': The inner_radius and outer_radius parameter is 0. No zombies spawned.' end

    -- Go through and spawn each zombie between the values of inner-radius and outer-radius,
    -- between 0 and 2*PI.
    for i = 1, amount, 1 do

        -- Calculate radi within the limits.
        local radius = inner_radius
        if inner_radius ~= outer_radius then
            radius = ZombRandBetween(inner_radius * 100000, outer_radius * 100000) / 100000
        end

        -- Calculate angle to use as the position with the calculated radius above. 
        local angle = ZombRand(0, pi2 * 100000) / 100000
        local center_x = math.cos(angle) * radius
        local center_y = math.sin(angle) * radius

        -- Translate it to the world coordinates of the player.
        local zombie_x = player:getX() + center_x
        local zombie_y = player:getY() + center_y

        -- Make sure the square is valid. (For instance if the player is on the edge of the map)
        local square = getRandomZSquare(zombie_x, zombie_y)
        if square ~= nil then
            local zombie_z = square:getZ()
            -- print('Creating Zed at: {x: '..tostring(zombie_x)..', y: '..tostring(zombie_y)..', z: '..tostring(zombie_z)..'}')
            helper.createZombie(zombie_x, zombie_y, zombie_z)
        end
    end

    return 'Spawned horde around player: '..tostring(username)..'.'

end)

print('Registered Lua Server Command: '..CMD_NAME)
