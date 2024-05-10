-- Import these modules to register and execute LuaCommands.
require 'LuaCommands/LuaCommands';
local ServerUtils = require 'ExtraCommands/ServerUtils';

local CMD_NAME = 'createhordepolygon';
local pi2 = math.pi * 2.0;

--- Executes the command when fired in a Single-Player environment.
---
--- @param args string[] Any arguments passed with the command.
local function onSinglePlayerCommand(args)
    -- Execute the command in Single-player here.
    return 'Command not supported in single-player mode.';
end

--- Executes the command when fired in a Server environment.
---
--- @param author string The username of the player that executed the command, or 'admin' if console or RCON.
--- @param args string[] Any arguments passed with the command.
local function onServerCommand(author, args)
    -- Check if the correct number of arguments are passed.
    if #args ~= 3 then
        return '/createhordepolygon [player] [amount=[3->500]] [radius=[3->32]]'
    end

    -- NOTE: The helper only becomes visible in global scope when the first lua server command is fired.
    --       Make sure to reference the helper inside of the command's handler function.
    local helper = LuaServerCommandHelper;

    -- Attempt to resolve the player using the helper method.
    --- @type string
    local username = args[1];

    local player = helper.getPlayerByUsername(username);
    if player == nil then return 'Player not found: ' .. tostring(username) end
    --- @cast player IsoPlayer

    -- The amount of zombies is the amount of points in the polygon.
    local points = tonumber(args[2]);

    -- This is the distance from the player. (In Tiles)
    local radius = tonumber(args[3]);

    -- Clamp the radius and points arguments to prevent things getting out of control.
    if points < 3 then points = 3 end
    if points > 500 then points = 500 end
    if radius < 3 then radius = 3 end
    if radius > 32 then radius = 32 end

    -- Calculate the polygon points, translate it to the player's position as the origin,
    -- and create a zombie at that location.
    for i = 1, points, 1 do
        local lerp = (i / points);
        local val = lerp * pi2;
        local cx = math.cos(val) * radius;
        local cy = math.sin(val) * radius;
        local zx = player:getX() + cx;
        local zy = player:getY() + cy;

        -- Make sure the square is valid. (For instance if the player is on the edge of the map)
        local square = ServerUtils.getRandomZSquare(zx, zy);
        if square ~= nil then
            local zz = square:getZ();
            -- print('Creating Zed at: {x: '..tostring(zx)..', y: '..tostring(zy)..', z: '..tostring(zz)..'}')
            helper.createZombie(zx, zy, zz);
        end
    end

    return 'Spawned horde circle around player: '
        .. tostring(username) .. ' (radius: ' .. tostring(radius) .. ', points: ' .. tostring(points) .. ')';
end

-- Register the command here.
LuaCommands.register(CMD_NAME, function(author, command, args)
    if isClient() then
        return nil
    elseif isServer() then
        return onServerCommand(author, args)
    end
    return onSinglePlayerCommand(args);
end);

-- Print to the console to see if this file is valid and executed.
print('Registered LuaCommand: ' .. CMD_NAME);
