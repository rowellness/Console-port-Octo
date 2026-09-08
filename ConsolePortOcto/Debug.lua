local CPO = ConsolePortOcto
if not CPO then return end

local function Help()
    CPO:Print("/cpo status")
    CPO:Print("/cpo show | hide")
    CPO:Print("/cpo unlock | lock")
    CPO:Print("/cpo reset")
    CPO:Print("/cpo scale 0.6-1.6")
    CPO:Print("/cpo mouse")
    CPO:Print("/cpo debug")
end

local function Status()
    CPO:Print("Version: " .. CPO.version)
    CPO:Print("State: " .. CPO:GetState())

    if CPO.BindingsReader then
        CPO:Print("Layer: " .. CPO.BindingsReader:GetModifier())
    end

    if CPO.compat then
        CPO:Print("SuperWoW: " .. (CPO.compat.superWoW and "YES" or "NO"))
        CPO:Print("Nampower: " .. (CPO.compat.nampower and "YES" or "NO"))
    end

    CPO:Print("Persistent binding writes: PROHIBITED")
end

local function Handler(msg)
    msg = msg or ""
    local lower = string.lower(msg)

    if lower == "" or lower == "help" then
        Help()

    elseif lower == "status" then
        Status()

    elseif lower == "show" then
        ConsolePortOctoDB.visible = true
        if CPO.HUD and CPO.HUD.frame then CPO.HUD.frame:Show() end

    elseif lower == "hide" then
        ConsolePortOctoDB.visible = false
        if CPO.HUD and CPO.HUD.frame then CPO.HUD.frame:Hide() end

    elseif lower == "unlock" then
        if CPO.HUD then
            CPO.HUD:SetLocked(false)
            CPO:Print("HUD unlocked. Drag with left mouse button.")
        end

    elseif lower == "lock" then
        if CPO.HUD then
            CPO.HUD:SetLocked(true)
            CPO:Print("HUD locked.")
        end

    elseif lower == "reset" then
        if CPO.HUD then
            CPO.HUD:ResetPosition()
            CPO:Print("HUD position/scale reset.")
        end

    elseif string.find(lower, "^scale%s+") then
        local value = tonumber(string.match(lower, "^scale%s+([%d%.]+)"))
        if value and CPO.HUD then
            CPO.HUD:SetScale(value)
            CPO:Print("HUD scale: " .. tostring(value))
        else
            CPO:Print("Usage: /cpo scale 0.6-1.6")
        end

    elseif lower == "mouse" then
        if CPO.MouseMode then
            CPO.MouseMode:Toggle()
        end

    elseif lower == "debug" then
        ConsolePortOctoDB.debug = not ConsolePortOctoDB.debug
        CPO:Print("Debug: " .. (ConsolePortOctoDB.debug and "ON" or "OFF"))

    else
        Help()
    end
end

SLASH_CONSOLEPORTOCTO1 = "/cpo"
SLASH_CONSOLEPORTOCTO2 = "/consoleportocto"
SlashCmdList["CONSOLEPORTOCTO"] = Handler
