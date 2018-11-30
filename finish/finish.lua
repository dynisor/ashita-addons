_addon.author   = 'dynu';
_addon.name     = 'finish';
_addon.version  = '1.0.0';

require 'common'

local default_config =
{
    font =
    {
        family      = 'Arial',
        size        = 12,
        color_argb  = { 255, 255, 0, 0 },
        position    = { -10, 1 },
        bold        = false
    },
    background = 
    {
        color_argb  = { 255, 0, 0, 0 },
        visible     = true
    }
};
local fm_config = default_config;

----------------------------------------------------------------------------------------------------
-- Finish Variables
----------------------------------------------------------------------------------------------------
local fm = { };
fm.moves = 0;
fm.show  = true;

local moveStatus = {
    [381] = "1",
    [382] = "2",
    [383] = "3",
    [384] = "4",
    [385] = "5",
    [588] = "6+"
}

ashita.register_event('load', function()
    -- Load the configuration file..
    fm_config = ashita.settings.load_merged(_addon.path .. '/settings/fm.json', fm_config);

    -- Create the font object..
    local f = AshitaCore:GetFontManager():Create('__fm_addon');
    f:GetBackground():SetColor(math.d3dcolor(unpack(fm_config.background.color_argb)));
    f:GetBackground():SetVisibility(fm_config.background.visible);
    f:SetColor(math.d3dcolor(unpack(fm_config.font.color_argb)));
    f:SetFontFamily(fm_config.font.family);
    f:SetFontHeight(fm_config.font.size);
    f:SetPositionX(fm_config.font.position[1]);
    f:SetPositionY(fm_config.font.position[2]);
    f:SetBold(fm_config.font.bold);
    f:SetRightJustified(true);
    f:SetText('');
    f:SetVisibility(fm.show);

end);

ashita.register_event('unload', function()
    AshitaCore:GetFontManager():Delete('__fm_addon')
end)

ashita.register_event('render', function()
    -- Get the font object..
    local f = AshitaCore:GetFontManager():Get('__fm_addon');
    if (f == nil) then return; end

    local me = AshitaCore:GetDataManager():GetPlayer()
    if (me == nil) then return; end

    if not me:GetMainJob() == 19 and not me:GetSubJob() == 19 then
        f:SetVisibility(false)
        return;
    end

    -- Set the font visibility..
    f:SetVisibility(fm.show);

    -- Skip calculations if font is disabled..
    if (fm.show == false) then return; end

    -- Calculate the current fm..

    local buffs = me:GetBuffs()
    
    fm.moves = 0;
    for _, buff in pairs(buffs) do
        if moveStatus[buff] ~= nil then
            fm.moves = moveStatus[buff]
        end
    end
    -- Update the fm font..
    f:SetText(' Finishing Moves: ' .. fm.moves .. ' ');
end);