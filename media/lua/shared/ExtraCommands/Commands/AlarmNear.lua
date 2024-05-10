-- Import these modules to register and execute LuaCommands.
require 'LuaCommands/LuaCommands';
local ServerUtils = require 'ExtraCommands/ServerUtils';

--- (Place your command name here)
--- @type string
local CMD_NAME = 'alarmnear';

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
    if #args < 1 or #args > 2 then
        return '/' .. CMD_NAME .. ' [player] [radius=1->512 (DEFAULT: 256)]';
    end

    -- NOTE: The helper only becomes visible in global scope when the first lua server command is fired.
    --       Make sure to reference the helper inside of the command's handler function.
    local helper = LuaServerCommandHelper;

    -- Attempt to resolve the player using the helper method.
    local username = args[1];
    local player = helper.getPlayerByUsername(username);
    if player == nil then return 'Player not found: ' .. username end

    --- @type integer
    local radius = 256;

    if #args == 2 then
        radius = tonumber(args[2]);
        if radius <= 0 then
            return 'Radius is 0 or negative.';
        elseif radius > 512 then
            radius = 512;
        end
    end

    local building = ServerUtils.getNearestBuilding(player:getX(), player:getY(), radius);
    if building == nil then return 'No building nearby player: ' .. username end

    local room = building:getRandomRoom();
    if room == nil then return 'The nearest building has no rooms.' end

    building:getDef():setAlarmed(true);
    helper.triggerRoomAlarm(room:getRoomDef());

    return 'Alarm sounded near player: ' .. username;
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
