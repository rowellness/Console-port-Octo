-- Logical mouse-mode state.
--
-- Hardware mapping remains Steam Input's responsibility.
-- This module never modifies WoW bindings.

local CPO = ConsolePortOcto
if not CPO then return end

local MouseMode = {}
CPO.MouseMode = MouseMode
CPO:RegisterModule("MouseMode", MouseMode)

MouseMode.enabled = false

function MouseMode:Enable()
    if self.enabled then return end
    self.enabled = true
    CPO:SetState(CPO.STATE_MOUSE, "mouse mode enabled")
end

function MouseMode:Disable()
    if not self.enabled then return end
    self.enabled = false

    if CPO.PanelState then
        local panel = CPO.PanelState:FindOpenPanel()
        if panel then
            CPO.PanelState.activePanel = panel
            CPO:SetState(CPO.STATE_UI, "mouse mode disabled over panel")
            return
        end
    end

    CPO:SetState(CPO.STATE_GAMEPLAY, "mouse mode disabled")
end

function MouseMode:Toggle()
    if self.enabled then
        self:Disable()
    else
        self:Enable()
    end
end
