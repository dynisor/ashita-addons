_addon.author   = 'dynu';
_addon.name     = 'speedchecker';
_addon.version  = '1.0.1';

require 'common'

local default_config =
{
    font =
    {
        family      = 'Arial',
        size        = 12,
        color_argb  = { 255, 255, 0, 0 },
        position    = { -10, 1 }
    },
    format = '%d%%'
};
local sc_config = default_config;

----------------------------------------------------------------------------------------------------
-- SC Variables
----------------------------------------------------------------------------------------------------
local sc = { };
sc.speed = 0;
sc.show  = true;

ashita.register_event('load', function()
    -- Load the configuration file..
    sc_config = ashita.settings.load_merged(_addon.path .. '/settings/sc.json', sc_config);

    -- Create the font object..
    local f = AshitaCore:GetFontManager():Create('__sc_addon');
    f:SetColor(math.d3dcolor(unpack(sc_config.font.color_argb)));
    f:SetFontFamily(sc_config.font.family);
    f:SetFontHeight(sc_config.font.size);
    f:SetPositionX(sc_config.font.position[1]);
    f:SetPositionY(sc_config.font.position[2]);
    f:SetRightJustified(true);
    f:SetText('');
    f:SetVisibility(sc.show);
end);

ashita.register_event('render', function()
    -- Get the font object..
    local f = AshitaCore:GetFontManager():Get('__sc_addon');
    if (f == nil) then return; end

    -- Set the font visibility..
    f:SetVisibility(sc.show);

    -- Skip calculations if font is disabled..
    if (sc.show == false) then return; end

    -- Calculate the current sc..
    local me = GetPlayerEntity()
    sc.speed = 100 * me.Speed / 5 - 100

    -- Update the sc font..
    f:SetText(string.format(sc_config.format, sc.speed));
end);