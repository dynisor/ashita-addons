_addon.name = 'TRIBPLZ (Ashita Port)'
_addon.author = 'dynu (orig. TRIBULENS)'
_addon.version = '1.0'

require 'common'

local starts_with = function(str, start)
    return str:sub(1, #start) == start
end

local send_message = function(message) 
    ashita.timer.once(2, function() AshitaCore:GetChatManager():QueueCommand(message, 1) end)
end
        
ashita.register_event('incoming_text', function(mode, original, modifiedMode, modified)
    if original:contains("tribplz") then
        local chatmode
		if starts_with(original, '[1]') then
            chatmode = 'l'
        elseif starts_with(original, '[2]') then
            chatmode = 'l2'
        elseif starts_with(original, '(') then
            chatmode = 'p'
        end

        if chatmode then
            local me = AshitaCore:GetDataManager():GetPlayer()
            if (me == nil) then return; end

            if me:HasKeyItem(2894) then 
                send_message('/'..chatmode..' I have tribulens.')
            elseif me:HasKeyItem(3031) then 
                send_message('/'..chatmode..' I have radialens.')
            else 
                send_message('/'..chatmode..' I am worthless.') 
            end
        end
    end
    
    return false
end)