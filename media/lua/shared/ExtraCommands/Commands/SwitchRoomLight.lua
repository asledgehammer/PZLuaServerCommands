-- Import these modules to register and execute LuaCommands.
require 'LuaCommands/LuaCommands';
local ServerUtils = require 'ExtraCommands/ServerUtils';

--- (Place your command name here)
--- @type string
local CMD_NAME = 'switchroomlight';

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
    if #args ~= 1 then
        return '/' .. CMD_NAME .. ' [player]';
    end

    -- NOTE: The helper only becomes visible in global scope when the first lua server command is fired.
    --       Make sure to reference the helper inside of the command's handler function.
    local helper = LuaServerCommandHelper;
    --- @cast helper LuaServerCommandHelper

    -- Attempt to resolve the player using the helper method.
    local username = args[1];
    local player = helper.getPlayerByUsername(username);
    if player == nil then return 'Player not found: ' .. tostring(username) end

    local world = getWorld();
    local square = player:getSquare();
    local room = square:getRoom();

    if room == nil then
        return 'The player ' .. tostring(username) .. ' is not in a room.';
    end

    if world:isHydroPowerOn() == false and square:haveElectricity() == false then
        return 'The light switch for the room does not have electricity.';
    end

    local lightSwitches = room:getLightSwitches();
    if lightSwitches:size() == 0 then
        return 'The room does not have any light switches.';
    end

    local lightSwitch = lightSwitches:get(0);
    lightSwitch:toggle();

    return 'Toggled light switch near player: ' .. tostring(username) .. '.';
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
