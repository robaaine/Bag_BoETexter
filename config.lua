local panel = CreateFrame("Frame")
panel.name = "Test"
InterfaceOptions_AddCategory(panel)

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Test Addon Settings")