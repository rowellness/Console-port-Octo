-- Read-only binding/action resolver.
-- No binding-write APIs belong in this module.

local CPO = ConsolePortOcto
if not CPO then return end

local Reader = {}
CPO.BindingsReader = Reader
CPO:RegisterModule("BindingsReader", Reader)

local function NumberFromEnd(text)
    if not text then return nil end
    return tonumber(string.match(text, "(%d+)$"))
end

function Reader:GetModifier()
    -- LT+RT is configured in Steam Input to emit ALT, not literal SHIFT+CTRL.
    if IsAltKeyDown and IsAltKeyDown() then
        return "ALT"
    elseif IsControlKeyDown and IsControlKeyDown() then
        return "CTRL"
    elseif IsShiftKeyDown and IsShiftKeyDown() then
        return "SHIFT"
    end
    return "BASE"
end

function Reader:BuildKey(modifier, key)
    if modifier == "BASE" then
        return key
    end
    return modifier .. "-" .. key
end

function Reader:GetBindingCommand(modifier, key)
    local bindingKey = self:BuildKey(modifier, key)
    local command = GetBindingAction(bindingKey)
    if command == nil then
        command = ""
    end
    return command, bindingKey
end

function Reader:ResolveMainActionButton(buttonNumber)
    local button = getglobal("ActionButton" .. tostring(buttonNumber))
    if button and button.action then
        return button.action
    end

    -- Fallback if Blizzard ActionButton frames are unavailable for any reason.
    local page = 1
    if GetActionBarPage then
        page = GetActionBarPage() or 1
    end
    return ((page - 1) * 12) + buttonNumber
end

function Reader:CommandToActionSlot(command)
    local n

    if not command or command == "" then
        return nil
    end

    if string.find(command, "^ACTIONBUTTON%d+$") then
        n = NumberFromEnd(command)
        if n then
            return self:ResolveMainActionButton(n)
        end
    end

    -- Vanilla Blizzard multi-bar slot mapping:
    -- MultiActionBar1 = lower-left  (61-72)
    -- MultiActionBar2 = lower-right (49-60)
    -- MultiActionBar3 = right       (25-36)
    -- MultiActionBar4 = right-2     (37-48)
    if string.find(command, "^MULTIACTIONBAR1BUTTON%d+$") then
        n = NumberFromEnd(command)
        if n then return 60 + n end
    elseif string.find(command, "^MULTIACTIONBAR2BUTTON%d+$") then
        n = NumberFromEnd(command)
        if n then return 48 + n end
    elseif string.find(command, "^MULTIACTIONBAR3BUTTON%d+$") then
        n = NumberFromEnd(command)
        if n then return 24 + n end
    elseif string.find(command, "^MULTIACTIONBAR4BUTTON%d+$") then
        n = NumberFromEnd(command)
        if n then return 36 + n end
    end

    return nil
end

function Reader:GetActionInfoForControllerKey(modifier, key)
    local command, bindingKey = self:GetBindingCommand(modifier, key)
    local slot = self:CommandToActionSlot(command)

    local info = {}
    info.modifier = modifier
    info.key = key
    info.bindingKey = bindingKey
    info.command = command
    info.slot = slot

    if slot and HasAction(slot) then
        info.hasAction = true
        info.texture = GetActionTexture(slot)
        info.count = GetActionCount(slot) or 0

        local start, duration, enable = GetActionCooldown(slot)
        info.cooldownStart = start or 0
        info.cooldownDuration = duration or 0
        info.cooldownEnable = enable

        local usable, noMana = IsUsableAction(slot)
        info.usable = usable
        info.noMana = noMana

        if IsActionInRange then
            info.inRange = IsActionInRange(slot)
        end
    else
        info.hasAction = false
    end

    return info
end
