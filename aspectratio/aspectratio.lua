_addon.author   = 'dynisor';
_addon.name     = 'AspectRatio';
_addon.version  = '1.0.0';

require 'common';

local signature = '81EC000100003BC174218B0D';
local addr_offset = 0x0C;
local ar_offset = 0x2F0;
local aspect_ratio = 1.0;

local default_config =
{
	ratio = "16:9"
};
local config = default_config;

local pointer   = ashita.memory.findpattern('FFXiMain.dll', 0, signature, 0, 0);

-- local aspectRatioChanged = function()
-- 	if (pointer == 0) then
-- 	    print('[AspectRatio] Could not locate the required signature to patch the Aspect Ratio');
-- 	    return true;
-- 	end

-- 	-- Read into the pointer..
-- 	local addr = ashita.memory.read_uint32(pointer + addr_offset);
-- 	addr = ashita.memory.read_uint32(addr);
-- 	-- Set the new Aspect Ratio..
-- 	local mem_aspect_ratio = ashita.memory.read_float(addr + ar_offset);
-- 	if string.format('%.4f', mem_aspect_ratio) ~= string.format('%.4f', aspect_ratio) then return true end
-- 	return false
-- end

local patchAspectRatio = function()

	-- Validate the pointers.
	if (pointer == 0) then
        print('[AspectRatio] Could not locate the required signature to patch the Aspect Ratio');
        return true;
    end
	
	-- Read into the pointer..
	local addr = ashita.memory.read_uint32(pointer + addr_offset);
	addr = ashita.memory.read_uint32(addr);
	-- Set the new Aspect Ratio..
	ashita.memory.write_float(addr + ar_offset, aspect_ratio);
end

local changeRatio = function(ratio, auto)
	-- Find the current pointer from memory
	local pointer   = ashita.memory.findpattern('FFXiMain.dll', 0, signature, 0, 0);

	local seperator = ratio:find(':');
	-- print('seperator', seperator)
	local ratioX = tonumber(ratio:sub(1,seperator-1));
	-- print('ratioX', ratioX)
	local ratioY = tonumber(ratio:sub(seperator+1));
	-- print('ratioY', ratioY)
	
	if not ratio:contains(':') and not ratioX > 0 and not ratioY > 0 then
		error('The ratio specified is formatted incorrectly. Please use a X:Y ratio, such as 16:9.');
		return;

	end

	aspect_ratio = (4/3)/(ratioX/ratioY);
	-- print('aspect_ratio', aspect_ratio)

    patchAspectRatio()

   	print(string.format('\31\200[\31\05AspectRatio\31\200] \31\130Set Aspect Ratio to: \30\02%s (%.4f)', config['ratio'], aspect_ratio));

    return true;
end


ashita.register_event('load', function()
	config = ashita.settings.load_merged(_addon.path .. '/settings/aspectratio.json', default_config);
	changeRatio(config['ratio']);
end);

ashita.register_event('command', function(command)
    -- Get the arguments of the command..
    local args = command:args();
    if (args[1] ~= '/ar') then
        return false;
    end

    if not args[2] or args[2] == 'help' then
    	print('\31\200[\31\05AspectRatio\31\200]\30\01 ' .. '\30\68Syntax:\30\02 /ar set [ratio (x:y)]\30\71 - sets the aspect ratio to the one provided.');
    	return true;
    end

    if args[2] == 'set' and args[3] then
    	changeRatio(args[3])
    	return true;
    end;

    return false;
end);

ashita.register_event('outgoing_packet', function(id, size, packet)
	-- Zone Change
	if (id == 0x0C) then
		patchAspectRatio()
	end
	return false;
end);