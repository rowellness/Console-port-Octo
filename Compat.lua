local CPO = ConsolePortOcto
if not CPO then return end

CPO.compat = CPO.compat or {}

function CPO:DetectCompatibility()
    CPO.compat.superWoW = (getglobal("SUPERWOW_VERSION") ~= nil)

    -- Nampower versions/forks do not all expose one canonical version global.
    -- Detect a small set of documented Nampower-added functions without
    -- depending on any one version string.
    if type(getglobal("GetSpellIdCooldown")) == "function"
        or type(getglobal("GetCurrentCastingInfo")) == "function"
        or type(getglobal("PlayerIsMoving")) == "function" then
        CPO.compat.nampower = true
    else
        CPO.compat.nampower = false
    end

    if ConsolePortOctoDB and ConsolePortOctoDB.debug then
        CPO:Print("SuperWoW: " .. (CPO.compat.superWoW and "detected" or "not detected"))
        CPO:Print("Nampower: " .. (CPO.compat.nampower and "detected" or "not detected"))
    end
end
