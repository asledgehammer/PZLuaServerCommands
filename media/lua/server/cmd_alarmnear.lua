require 'lua_server_commands'
require 'cmd_utils'

local CMD_NAME = 'alarmnear'
local helper = nil

LuaServerCommands.register(CMD_NAME, function(author, command, args)

    -- Check if the correct number of arguments are passed.
    if #args < 1 or #args > 2 then
        return '/'..CMD_NAME..' [player] [radius=1->512 (DEFAULT: 256)]'
    end

    -- NOTE: The helper only becomes visible in global scope when the first lua server command is fired.
    --       Make sure to reference the helper inside of the command's handler function.
    helper = LuaServerCommandHelper

    -- Attempt to resolve the player using the helper method.
    local username = args[1]
    local player = helper.getPlayerByUsername(username)
    if player == nil then return 'Player not found: '..username end

    local radius = 256

    if #args == 2 then
        radius = tonumber(args[2])
        if radius <= 0 then return 'Radius is 0 or negative.'
        elseif radius > 512 then radius = 512 end
    end

    local building = getNearestBuilding(player:getX(), player:getY(), radius)
    if building == nil then
        return 'No building nearby player: '..username
    end

    local room = building:getRandomRoom()
    if room == nil then
        return 'The nearest building has no rooms.'
    end

    building:getDef():setAlarmed(true)
    helper.triggerRoomAlarm(room:getRoomDef())

    return 'Alarm sounded near player: '..username
end)

print('Registered Lua Server Command: '..CMD_NAME)
