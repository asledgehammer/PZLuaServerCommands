-- Import these modules to register and execute LuaCommands.
require 'LuaCommands/LuaCommands';
local ServerUtils = require 'ExtraCommands/ServerUtils';

--- (Place your command name here)
--- @type string
local CMD_NAME = 'doors'
local helper = nil;

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
    if #args > 4 or #args < 3 then
        return '/' .. CMD_NAME .. ' [action] [player] [radius=1->32] [*chance=0.0->1.0 (DEFAULT: 1)]'
            .. '\n\tactions: open, close, thump, destroy, barricade, unbarricade, removebarricade'
    end

    -- NOTE: The helper only becomes visible in global scope when the first lua server command is fired.
    --       Make sure to reference the helper inside of the command's handler function.
    helper = LuaServerCommandHelper;
    --- @cast helper LuaServerCommandHelper

    local action = string.lower(args[1]);

    -- Attempt to resolve the player using the helper method.
    local username = args[2];
    local player = helper.getPlayerByUsername(username);
    if player == nil then return 'Player not found: ' .. username end

    local radius = tonumber(args[3]);
    local chance = 1;
    if #args == 4 then chance = tonumber(args[4]) end

    -- Clamp our values.
    if radius < 1 then radius = 1 end
    if radius > 32 then radius = 32 end
    if chance == 0 then return 'Chance given is zero. Nothing will happen.' end
    if chance > 1 then chance = 1 end

    local count = 0;
    local doors = ServerUtils.getNearbyDoors(player:getX(), player:getY(), player:getZ(), radius);

    if action == 'destroy' then
        for i = 1, #doors, 1 do
            local door = doors[i];
            if door:isDestroyed() == false then
                door:destroy();
                helper.playWorldSoundSquare('WoodDoorBreak', door:getSquare(), 24.0);
                count = count + 1;
            end
        end
        return tostring(count) .. ' door(s) destroyed near the player: ' .. username .. '.'
    elseif action == 'thump' then
        for i = 1, #doors, 1 do
            local door = doors[i];
            if chance == 1 or ServerUtils.randomFloat() <= chance then
                if door:isDestroyed() == false then
                    helper.playWorldSoundSquare('ZombieThumpGeneric', door:getSquare(), 24.0);
                    count = count + 1;
                end
            end
        end
        return tostring(count) .. ' door(s) thumped near the player: ' .. username .. '.';
    elseif action == 'open' then
        for i = 1, #doors, 1 do
            local door = doors[i];

            if chance == 1 or ServerUtils.randomFloat() <= chance then
                if door:IsOpen() == false and door:isBarricaded() == false then
                    door:setKeyId(-1);
                    door:setLocked(false);
                    door:ToggleDoorActual(player);
                    helper.playWorldSoundSquare('WoodDoorOpen', door:getSquare(), 24.0);
                    count = count + 1;
                end
            end
        end
        return tostring(count) .. ' door(s) opened near the player: ' .. username .. '.';
    elseif action == 'close' then
        for i = 1, #doors, 1 do
            local door = doors[i];
            if chance == 1 or ServerUtils.randomFloat() <= chance then
                if door:IsOpen() == true and door:isBarricaded() == false then
                    door:setKeyId(-1);
                    door:setLocked(false);
                    door:ToggleDoorActual(player);
                    helper.playWorldSoundSquare('WoodDoorClose', door:getSquare(), 24.0);
                    count = count + 1;
                end
            end
        end
        return tostring(count) .. ' door(s) closed near the player: ' .. username .. '.'
    elseif action == 'barricade' then
        for i = 1, #doors, 1 do
            local door = doors[i];
            if chance == 1 or ServerUtils.randomFloat() <= chance then
                if ServerUtils.barricade(door) then
                    count = count + 1;
                end
            end
        end
        return tostring(count) .. ' door(s) barricaded near the player: ' .. username .. '.';
    elseif action == 'unbarricade' then
        for i = 1, #doors, 1 do
            local door = doors[i];
            if chance == 1 or ServerUtils.randomFloat() <= chance then
                if ServerUtils.unbarricade(door) then
                    count = count + 1;
                end
            end
        end
        return tostring(count) .. ' door(s) unbarricaded near the player: ' .. username .. '.';
    elseif action == 'removebarricade' then
        for i = 1, #doors, 1 do
            local door = doors[i];
            if chance == 1 or ServerUtils.randomFloat() <= chance then
                ServerUtils.removeBarricade(door);
            end
            count = count + 1;
        end
        return tostring(count) .. ' door(s) have their barricades removed near the player: ' .. username .. '.';
    else
        return 'Unknown door action: ' .. tostring(action);
    end
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
