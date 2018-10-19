_addon.author   = 'dynisor';
_addon.name     = 'AspectRatio';
_addon.version  = '1.0.1';

require 'common';
require 'timer';

-- Constants
local SIGNATURE = '81EC000100003BC174218B0D';
local ADDR_OFFSET = 0x0C;
local AR_OFFSET = 0x2F0;

-- Current aspect ratio
local aspect_ratio = 1.0;


-- Default config
local default_config =
{
	ratio = "16:9"
};
local config = default_config;

-- Pointer to memory settings
local pointer = ashita.memory.findpattern('FFXiMain.dll', 0, SIGNATURE, 0, 0);

-- If the pointer doesn't exist, throw an error
if (pointer == 0) then
    error('[AspectRatio] Could not locate the required signature to patch the Aspect Ratio');
    return true;
end

-- Address of the aspect ratio
local addr = ashita.memory.read_uint32(pointer + ADDR_OFFSET);
addr = ashita.memory.read_uint32(addr);


local setRatio = function(ratio, auto)
	-- Parse the aspect ratio
	local seperator = ratio:find(':');
	local ratioX = tonumber(ratio:sub(1,seperator-1));
	local ratioY = tonumber(ratio:sub(seperator+1));

	-- If the aspect ratio passed in is invalid, throw an error
	if not ratio:contains(':') and not ratioX > 0 and not ratioY > 0 then
		error('The ratio specified is formatted incorrectly. Please use a X:Y ratio, such as 16:9.');
		return;

	end

	-- Convert aspect ratio to float
	aspect_ratio = (4/3)/(ratioX/ratioY);

	-- Update the aspect ratio
    ashita.memory.write_float(addr + AR_OFFSET, aspect_ratio);

   	print(string.format('\31\200[\31\05AspectRatio\31\200] \31\130Set Aspect Ratio to: \30\02%s (%.4f)', config['ratio'], aspect_ratio));

    return true;
end


local createZoneTimer = function() 
	ashita.timer.adjust_timer('zoneTimer', 0.0000001, 0, function()	
		-- Read the value of the aspect ratio from memory
		local mem_aspect_ratio = ashita.memory.read_float(addr + AR_OFFSET);

		-- If the aspect ratio has changed
		if string.format('%.4f', mem_aspect_ratio) ~= string.format('%.4f', aspect_ratio) then 
			-- Revert the aspect ratio to the previous value
			ashita.memory.write_float(addr + AR_OFFSET, aspect_ratio);

			-- Stop this timer
			ashita.timer.stop('zoneTimer')
			return true 
		end
		return false
	end)
end


ashita.register_event('load', function()
	-- Get the config from aspectratio.json
	config = ashita.settings.load_merged(_addon.path .. '/settings/aspectratio.json', default_config);

	-- Set the ratio to the one retreived from the config 
	setRatio(config['ratio']);

	-- Create the timer for when we zone
	createZoneTimer();
end);



ashita.register_event('command', function(command)
    -- Get the arguments of the command
    local args = command:args();

    -- If the command is not /ar, do nothing
    if (args[1] ~= '/ar') then
        return false;
    end

    -- If no arguments are passed to /ar, or /ar help is called, display help message
    if not args[2] or args[2] == 'help' then
    	print('\31\200[\31\05AspectRatio\31\200]\30\01 ' .. '\30\68Syntax:\30\02 /ar set [ratio (x:y)]\30\71 - sets the aspect ratio to the one provided.');
    	return true;
    end

    -- If /ar set is called, set the new ratio
    if args[2] == 'set' and args[3] then
    	setRatio(args[3])
    	return true;
    end;

    return false;
end);


ashita.register_event('outgoing_packet', function(id, size, packet)
	if (id == 0x11) then
		-- Wait for the aspect ratio to change and set it back to what we want
		ashita.timer.start_timer('zoneTimer')
	end	return false
end);
