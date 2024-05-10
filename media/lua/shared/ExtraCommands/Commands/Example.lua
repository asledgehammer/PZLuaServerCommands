--- This file serves as a template for creating and executing custom Lua commands using the LuaCommands patch
--- & workshop mod.
---
--- {FILES}
--- Java Patch: https://discord.gg/taP6ZxSTGJ
--- Workshop Mod: <url_link>
---
--- {DEVELOPER LINKS}
--- Workshop GitHub: https://github.com/asledgehammer/LuaCommands
--- Asledgehammer Discord: https://discord.gg/u3vWvcPX8f
---
--- @author JabDoesThings | asledgehammer

-- Import these modules to register and execute LuaCommands.
require 'LuaCommands/LuaCommands';
local ServerUtils = require 'ExtraCommands/ServerUtils';

--- (Place your command name here)
--- @type string
local CMD_NAME = 'example';

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
    -- NOTE: The helper only becomes visible in global scope when the first lua server command is fired.
    --       Make sure to reference the helper inside of the command's handler function.
    --
    -- local helper = LuaServerCommandHandler;
    --- @cast helper LuaServerCommandHelper

    -- Execute the command in Server-mode here.
    return 'Command not supported in server mode.';
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
