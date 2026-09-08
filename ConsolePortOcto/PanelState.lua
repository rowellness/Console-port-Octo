-- Detect supported Blizzard panels.
-- Detection changes ConsolePortOcto's displayed state only.
-- It does NOT remap 1-7 or any other keys.

local CPO = ConsolePortOcto
if not CPO then return end

local PanelState = {}
CPO.PanelState = PanelState
CPO:RegisterModule("PanelState", PanelState)

PanelState.activePanel = nil

local function Visible(globalName)
    local f = getglobal(globalName)
    return f and f.IsVisible and f:IsVisible()
end

function PanelState:FindOpenPanel()
    if Visible("CharacterFrame") then
        return "CHARACTER"
    end
    if Visible("SpellBookFrame") then
        return "SPELLBOOK"
    end
    if Visible("TalentFrame") then
        return "TALENTS"
    end

    local i
    for i = 1, 12 do
        if Visible("ContainerFrame" .. tostring(i)) then
            return "BAGS"
        end
    end

    return nil
end

function PanelState:Update()
    if CPO.MouseMode and CPO.MouseMode.enabled then
        return
    end

    local panel = self:FindOpenPanel()

    if panel and self.activePanel ~= panel then
        self.activePanel = panel
        CPO:SetState(CPO.STATE_UI, panel .. " opened")

    elseif not panel and self.activePanel then
        self.activePanel = nil
        CPO:SetState(CPO.STATE_GAMEPLAY, "supported panel closed")
    end
end
