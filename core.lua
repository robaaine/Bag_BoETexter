print("Hello World, BoE Loaded") -- Debugging

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN") -- Körs när man loggar in
f:RegisterEvent("BAG_UPDATE")   -- Körs när något i väskorna ändras
f:RegisterEvent("ADDON_LOADED") -- Checkar addon

local scanner = CreateFrame("GameTooltip", "BoECheckerTooltip", nil, "GameTooltipTemplate")
scanner:SetOwner(UIParent, "ANCHOR_NONE")


local overlayCache = {} -- begränsning

local usingBagnon = true

local function UpdateBagnonFlag()
    if IsAddOnLoaded and IsAddOnLoaded("Bagnon") then
        usingBagnon = true
    else
        usingBagnon = false
    end
end

-- Hämtar vilken typ item:et är, returnerar "BoE", "BoP", "SB" eller nil
local function GetBindType(bag, slot)
    scanner:ClearLines()
    scanner:SetBagItem(bag, slot)   -- läs tooltip på item i (bag, slot)

    for i = 1, scanner:NumLines() do
        local text = _G["BoECheckerTooltipTextLeft"..i]:GetText()
        if text then
            text = text:lower()
            if text:find("binds when equipped") then
                return "BoE"
            elseif text:find("binds when picked up") then
                return "BoP"
            elseif text:find("soulbound") then
                return "BoP"
            end
        end
    end

    return nil
end

-- Hämtar UI-knappen för ett item i (bag, slot)
local function GetBagButton(bag, slot)
    local totalSlots = GetContainerNumSlots(bag)
    if not totalSlots or totalSlots == 0 then return nil end

    local uiSlot
    if usingBagnon then
        uiSlot = slot
    else
        uiSlot = totalSlots - slot + 1
    end

    local frameIndex = bag + 1
    local name = "ContainerFrame"..frameIndex.."Item"..uiSlot
    return _G[name]
end

-- Sätter en label på item:et
local function SetOverlay(bag, slot, bindType)
    local button = GetBagButton(bag, slot)
    if not button or not button:IsShown() then return end

    -- Skapa fontsträngen första gången
    if not overlayCache[button] then
        local fs = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        fs:SetTextColor(1, 0, 0)   -- röd text
        fs:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
        overlayCache[button] = fs
    end

    overlayCache[button]:SetText(bindType or "")
end

-- Scannar alla bags och uppdaterar overlay
local function ScanBags()
    for button, fs in pairs(overlayCache) do -- Nollställer gammal text
        fs:SetText("")
    end

    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        for slot = 1, slots do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local bindType = GetBindType(bag, slot)
                if bindType then
                    SetOverlay(bag, slot, bindType)
                end
            end
        end
    end
end

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_LOGIN" then
        UpdateBagnonFlag()
        ScanBags()
    elseif event == "ADDON_LOADED" and arg1 == "Bagnon" then
        UpdateBagnonFlag()
        ScanBags()
    elseif event == "BAG_UPDATE" then
        ScanBags()
    end
end)