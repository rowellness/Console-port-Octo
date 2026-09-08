-- ConsolePortOcto v0.2.0-alpha
-- WoW 1.12 / Lua 5.0-oriented code.
--
-- HARD RULE:
-- ConsolePortOcto never modifies persistent WoW keybindings.
-- Binding state is read-only.

ConsolePortOcto = ConsolePortOcto or {}
local CPO = ConsolePortOcto

CPO.name = "ConsolePortOcto"
CPO.version = "0.2.0-alpha"

CPO.STATE_GAMEPLAY = "GAMEPLAY"
CPO.STATE_UI = "UI"
CPO.STATE_MOUSE = "MOUSE"

CPO.state = CPO.STATE_GAMEPLAY
CPO.previousState = nil
CPO.modules = CPO.modules or {}
CPO.elapsed = 0

local frame = CreateFrame("Frame", "ConsolePortOctoCoreFrame")
CPO.frame = frame

function CPO:Print(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF33CCFFConsolePortOcto:|r " .. tostring(message))
    end
end

function CPO:RegisterModule(name, module)
    if name and module then
        self.modules[name] = module
    end
end

function CPO:EnsureDB()
    if type(ConsolePortOctoDB) ~= "table" then
        ConsolePortOctoDB = {}
    end

    if ConsolePortOctoDB.debug == nil then
        ConsolePortOctoDB.debug = false
    end
    if ConsolePortOctoDB.visible == nil then
        ConsolePortOctoDB.visible = true
    end
    if ConsolePortOctoDB.locked == nil then
        ConsolePortOctoDB.locked = true
    end
    if ConsolePortOctoDB.scale == nil then
        ConsolePortOctoDB.scale = 1.0
    end
end

function CPO:SetState(newState, reason)
    if newState ~= self.STATE_GAMEPLAY
        and newState ~= self.STATE_UI
        and newState ~= self.STATE_MOUSE then
        return
    end

    if self.state == newState then
        return
    end

    local oldState = self.state
    self.previousState = oldState
    self.state = newState

    local name, module
    for name, module in pairs(self.modules) do
        if module and module.OnStateChanged then
            module:OnStateChanged(oldState, newState, reason)
        end
    end

    if ConsolePortOctoDB and ConsolePortOctoDB.debug then
        self:Print(oldState .. " -> " .. newState ..
            (reason and (" (" .. tostring(reason) .. ")") or ""))
    end
end

function CPO:GetState()
    return self.state
end

local function OnEvent()
    if event == "VARIABLES_LOADED" then
        CPO:EnsureDB()

    elseif event == "PLAYER_LOGIN" then
        if CPO.DetectCompatibility then
            CPO:DetectCompatibility()
        end
        if CPO.HUD and CPO.HUD.Initialize then
            CPO.HUD:Initialize()
        end
        CPO:Print("Loaded v" .. CPO.version .. " — read-only bindings policy active.")

    elseif event == "ACTIONBAR_SLOT_CHANGED"
        or event == "ACTIONBAR_PAGE_CHANGED"
        or event == "UPDATE_BINDINGS"
        or event == "PLAYER_ENTERING_WORLD"
        or event == "SPELL_UPDATE_COOLDOWN"
        or event == "BAG_UPDATE" then
        if CPO.HUD and CPO.HUD.RefreshAll then
            CPO.HUD:RefreshAll()
        end
    end
end

local function OnUpdate()
    CPO.elapsed = CPO.elapsed + arg1
    if CPO.elapsed < 0.08 then
        return
    end
    CPO.elapsed = 0

    if CPO.HUD and CPO.HUD.Update then
        CPO.HUD:Update()
    end

    if CPO.PanelState and CPO.PanelState.Update then
        CPO.PanelState:Update()
    end
end

frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
frame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
frame:RegisterEvent("UPDATE_BINDINGS")
frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", OnEvent)
frame:SetScript("OnUpdate", OnUpdate)
