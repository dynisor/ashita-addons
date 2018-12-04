_addon.author   = 'Ivaar'
_addon.name     = 'AllWarps'
_addon.version  = '1.0'

require 'common';

local destinations = {
    hp = string.char(0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xF7,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x03),
    sg = string.char(0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x03,0x00,0x00,0x00),
    wp = string.char(0xFF,0x81,0xFF,0x00,0x00,0xFF,0xFF,0xFF,0xCF,0x03,0x00,0x00,0xDF,0x0F,0x00,0x00,0xCF,0x07,0x00,0x00,0xCF,0x07)
};

ashita.register_event('incoming_packet', function(id, size, packet, packet_modified, blocked)
    local incoming = false;

    if id == 0x34 then
        local menu_id = packet:byte(45)+packet:byte(46)*256;

        if menu_id >= 8700 and menu_id <= 8704 then     -- Homepoint
            incoming = (packet:sub(1,12)..destinations.hp..packet:sub(29)):totable();
        elseif menu_id >= 8500 and menu_id <= 8501 then -- Survival Guide
            incoming = (packet:sub(1,20)..destinations.sg..packet:sub(37)):totable();
        elseif menu_id >= 5000 and menu_id <= 5009 then -- Waypoint
            incoming = (packet:sub(1,12)..destinations.wp..packet:sub(35)):totable();
        end
    end

    return incoming;
end);

