local CPO = ConsolePortOcto
if not CPO then return end

local HUD = {}
CPO.HUD = HUD
CPO:RegisterModule("HUD", HUD)

HUD.buttons = {}
HUD.initialized = false
HUD.currentModifier = "BASE"

local BUTTON_SIZE = 44
local SMALL_GAP = 8

local layout = {
    -- face diamond
    { id="Y", key="2", x=112, y=38, label="Y" },
    { id="B", key="3", x=158, y=0,  label="B" },
    { id="A", key=nil, x=112, y=-38, label="A", jump=true },
    { id="X", key="1", x=66,  y=0,   label="X" },

    -- d-pad diamond
    { id="DU", key="4", x=-112, y=38,  label="▲" },
    { id="DR", key="5", x=-66,  y=0,   label="▶" },
    { id="DD", key="6", x=-112, y=-38, label="▼" },
    { id="DL", key="7", x=-158, y=0,   label="◀" },
}

local function MakeTexture(frame, layer, texture)
    local t = frame:CreateTexture(nil, layer)
    t:SetAllPoints(frame)
    if texture then
        t:SetTexture(texture)
    end
    return t
end

local function ShortCommand(command)
    if not command or command == "" then
        return "UNBOUND"
    end

    if string.find(command, "^ACTIONBUTTON") then
        return "ACTION"
    end
    if string.find(command, "^MULTIACTIONBAR") then
        return "ACTION"
    end

    local text = command
    if string.len(text) > 12 then
        text = string.sub(text, 1, 12)
    end
    return text
end

function HUD:CreateButton(parent, data)
    local b = CreateFrame("Frame", "ConsolePortOctoButton" .. data.id, parent)
    b:SetWidth(BUTTON_SIZE)
    b:SetHeight(BUTTON_SIZE)
    b:SetPoint("CENTER", parent, "CENTER", data.x, data.y)

    b.bg = MakeTexture(b, "BACKGROUND")
    b.bg:SetTexture(0.04, 0.04, 0.04, 0.88)

    b.icon = MakeTexture(b, "ARTWORK")
    b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    b.icon:Hide()

    b.border = MakeTexture(b, "OVERLAY", "Interface\\Buttons\\UI-Quickslot2")

    b.buttonLabel = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.buttonLabel:SetPoint("TOPLEFT", b, "TOPLEFT", 3, -3)
    b.buttonLabel:SetText(data.label)

    b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    b.count:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -3, 3)

    b.cooldown = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.cooldown:SetPoint("CENTER", b, "CENTER", 0, 0)
    b.cooldown:SetText("")

    b.command = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.command:SetPoint("BOTTOM", b, "BOTTOM", 0, 3)
    b.command:SetWidth(BUTTON_SIZE - 4)
    b.command:SetJustifyH("CENTER")
    b.command:SetText("")

    b.data = data
    return b
end

function HUD:Initialize()
    if self.initialized then
        return
    end

    local f = CreateFrame("Frame", "ConsolePortOctoHUD", UIParent)
    self.frame = f
    f:SetWidth(390)
    f:SetHeight(150)
    f:SetFrameStrata("MEDIUM")
    f:SetMovable(true)
    f:EnableMouse(false)
    f:RegisterForDrag("LeftButton")

    f.bg = MakeTexture(f, "BACKGROUND")
    f.bg:SetTexture(0, 0, 0, 0.48)

    f.header = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.header:SetPoint("TOP", f, "TOP", 0, -8)
    f.header:SetText("ConsolePortOcto")

    f.layerText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.layerText:SetPoint("TOP", f.header, "BOTTOM", 0, -3)
    f.layerText:SetText("BASE")

    f.stateText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.stateText:SetPoint("BOTTOM", f, "BOTTOM", 0, 6)
    f.stateText:SetText("GAMEPLAY")

    f:SetScript("OnDragStart", function()
        if ConsolePortOctoDB and not ConsolePortOctoDB.locked then
            this:StartMoving()
        end
    end)

    f:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        HUD:SavePosition()
    end)

    local i, data
    for i = 1, table.getn(layout) do
        data = layout[i]
        self.buttons[data.id] = self:CreateButton(f, data)
    end

    self:RestorePosition()
    self:SetLocked(ConsolePortOctoDB.locked)

    if ConsolePortOctoDB.visible then
        f:Show()
    else
        f:Hide()
    end

    self.initialized = true
    self:RefreshAll()
end

function HUD:SetLocked(locked)
    if not self.frame then return end

    ConsolePortOctoDB.locked = locked and true or false
    if ConsolePortOctoDB.locked then
        self.frame:EnableMouse(false)
    else
        self.frame:EnableMouse(true)
    end
end

function HUD:SavePosition()
    if not self.frame then return end

    local point, relativeTo, relativePoint, x, y = self.frame:GetPoint(1)
    ConsolePortOctoDB.point = point
    ConsolePortOctoDB.relativePoint = relativePoint
    ConsolePortOctoDB.x = x
    ConsolePortOctoDB.y = y
end

function HUD:RestorePosition()
    if not self.frame then return end

    self.frame:ClearAllPoints()

    if ConsolePortOctoDB.point then
        self.frame:SetPoint(
            ConsolePortOctoDB.point,
            UIParent,
            ConsolePortOctoDB.relativePoint or ConsolePortOctoDB.point,
            ConsolePortOctoDB.x or 0,
            ConsolePortOctoDB.y or 0
        )
    else
        self.frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 115)
    end

    self.frame:SetScale(ConsolePortOctoDB.scale or 1.0)
end

function HUD:ResetPosition()
    if not self.frame then return end

    ConsolePortOctoDB.point = nil
    ConsolePortOctoDB.relativePoint = nil
    ConsolePortOctoDB.x = nil
    ConsolePortOctoDB.y = nil
    ConsolePortOctoDB.scale = 1.0

    self.frame:SetScale(1.0)
    self.frame:ClearAllPoints()
    self.frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 115)
end

function HUD:SetScale(value)
    if not self.frame then return end
    if value < 0.6 then value = 0.6 end
    if value > 1.6 then value = 1.6 end

    ConsolePortOctoDB.scale = value
    self.frame:SetScale(value)
end

function HUD:GetCooldownRemaining(info)
    if not info or not info.cooldownStart or not info.cooldownDuration then
        return 0
    end
    if info.cooldownDuration <= 1.5 then
        -- Hide most global-cooldown noise.
        return 0
    end

    local remaining = (info.cooldownStart + info.cooldownDuration) - GetTime()
    if remaining < 0 then remaining = 0 end
    return remaining
end

function HUD:RefreshButton(button, modifier)
    local data = button.data

    if data.jump then
        button.icon:Hide()
        button.count:SetText("")
        button.cooldown:SetText("")

        if modifier == "BASE" then
            button.command:SetText("JUMP")
            button.bg:SetTexture(0.08, 0.08, 0.08, 0.92)
            button.buttonLabel:SetTextColor(1, 0.82, 0)
        else
            button.command:SetText("FREE")
            button.bg:SetTexture(0.03, 0.03, 0.03, 0.72)
            button.buttonLabel:SetTextColor(0.65, 0.65, 0.65)
        end
        return
    end

    local info = CPO.BindingsReader:GetActionInfoForControllerKey(modifier, data.key)
    button.info = info

    if info.hasAction and info.texture then
        button.icon:SetTexture(info.texture)
        button.icon:Show()
        button.command:SetText("")

        if info.count and info.count > 1 then
            button.count:SetText(tostring(info.count))
        else
            button.count:SetText("")
        end

        if info.inRange == 0 then
            button.icon:SetVertexColor(1.0, 0.25, 0.25)
        elseif not info.usable then
            if info.noMana then
                button.icon:SetVertexColor(0.35, 0.45, 1.0)
            else
                button.icon:SetVertexColor(0.45, 0.45, 0.45)
            end
        else
            button.icon:SetVertexColor(1, 1, 1)
        end
    else
        button.icon:Hide()
        button.count:SetText("")
        button.command:SetText(ShortCommand(info.command))
    end

    button.buttonLabel:SetTextColor(1, 1, 1)
end

function HUD:RefreshAll()
    if not self.initialized then return end

    self.currentModifier = CPO.BindingsReader:GetModifier()
    self.frame.layerText:SetText(self.currentModifier)

    local i, data, b
    for i = 1, table.getn(layout) do
        data = layout[i]
        b = self.buttons[data.id]
        self:RefreshButton(b, self.currentModifier)
    end
end

function HUD:UpdateCooldowns()
    local id, button, remaining
    for id, button in pairs(self.buttons) do
        if button.info and button.info.hasAction then
            -- Refresh cooldown data frequently without rebuilding the whole button.
            local start, duration, enable = GetActionCooldown(button.info.slot)
            button.info.cooldownStart = start or 0
            button.info.cooldownDuration = duration or 0
            remaining = self:GetCooldownRemaining(button.info)

            if remaining >= 60 then
                button.cooldown:SetText(tostring(math.floor(remaining / 60) + 1) .. "m")
            elseif remaining >= 10 then
                button.cooldown:SetText(tostring(math.ceil(remaining)))
            elseif remaining > 0 then
                button.cooldown:SetText(string.format("%.1f", remaining))
            else
                button.cooldown:SetText("")
            end
        else
            button.cooldown:SetText("")
        end
    end
end

function HUD:Update()
    if not self.initialized or not self.frame:IsVisible() then
        return
    end

    local modifier = CPO.BindingsReader:GetModifier()
    if modifier ~= self.currentModifier then
        self.currentModifier = modifier
        self:RefreshAll()
    else
        -- Range/usability/count can change without slot-change events.
        self:RefreshAll()
    end

    self:UpdateCooldowns()

    local state = CPO:GetState()
    if state == CPO.STATE_MOUSE then
        self.frame.stateText:SetText("MOUSE MODE")
    elseif state == CPO.STATE_UI then
        local panel = ""
        if CPO.PanelState and CPO.PanelState.activePanel then
            panel = " • " .. CPO.PanelState.activePanel
        end
        self.frame.stateText:SetText("UI NAV" .. panel)
    else
        self.frame.stateText:SetText("GAMEPLAY")
    end
end

function HUD:OnStateChanged(oldState, newState, reason)
    if self.initialized then
        self:Update()
    end
end
