require 'lua_server_commands'
require 'cmd_utils'

-- Our constants.
local CMD_NAME = 'switchroomlight'

LuaServerCommands.register(CMD_NAME, function(author, command, args)

    -- Check if the correct number of arguments are passed.
    if #args ~= 1 then
        return '/'..CMD_NAME..' [player]'
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

    local world = getWorld()
    local square = player:getSquare()
    local room = square:getRoom()

    if room == nil then
        return 'The player '..tostring(username)..' is not in a room.'
    end
    
    if world:isHydroPowerOn() == false and square:haveElectricity() == false then
        return 'The light switch for the room does not have electricity.'
    end

    local lightSwitches = room:getLightSwitches()
    if lightSwitches:size() == 0 then
        return 'The room does not have any light switches.'
    end

    local lightSwitch = lightSwitches:get(0)

    lightSwitch:toggle()

    return 'Toggled light switch near player: '..tostring(username)..'.'
end)

print('Registered Lua Server Command: '..CMD_NAME)
