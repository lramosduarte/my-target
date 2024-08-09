local maxAuras = 40
local targetDebuffs = {}
local targetBuffs = {}

local rarityUnits = {
    rare = {label = "Rare", rgb = {177, 159, 247}},
    elite = {label = "Elite", rgb = {192, 192, 192}},
    rareelite = {label = "Rare Elite", rgb = {247, 245, 159}},
    minus = {label = "Minus", rgb = {204, 255, 229}},
}

local spellTypes = {
    curse = {rgb = {242, 144, 229}},
    poison = {rgb = {92, 255, 92}},
    magic = {rgb = {90, 200, 255}},
    disease  = {rgb = {255, 255, 83}},
}

local directionModifier = {
    LEFT = -1,
    RIGHT = 1,
}

local frame = CreateFrame("Frame", "MyTargetFrame", UiParent)
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MyTarget" then
        print("My Health Bar Addon Loaded")
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

local healthBar = CreateFrame("StatusBar")
healthBar:SetSize(450, 20)
healthBar:SetPoint("CENTER", 0, 300)
healthBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
healthBar:GetStatusBarTexture():SetHorizTile(false)
healthBar:SetMinMaxValues(0, UnitHealthMax("target"))
healthBar:SetValue(UnitHealth("target"))
healthBar:SetStatusBarColor(1, 0, 0)

local healthBarBg = healthBar:CreateTexture(nil, "BACKGROUND")
healthBarBg:SetAllPoints(true)
healthBarBg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
healthBarBg:SetVertexColor(1, 0.25, 0.25, 0.1)

local healthBarBorder = CreateFrame("Frame", nil, healthBar, BackdropTemplateMixin and "BackdropTemplate")
healthBarBorder:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -5, 6)
healthBarBorder:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 5, -6)
healthBarBorder:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
})


local unitClassText = healthBar:CreateFontString(nil, "OVERLAY")
unitClassText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
unitClassText:SetPoint("CENTER", healthBar, "CENTER", 0, -40)

local healthTextLeft = healthBar:CreateFontString(nil, "OVERLAY")
healthTextLeft:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
healthTextLeft:SetPoint("LEFT", healthBar, "LEFT", 0, 0)

local healthTextCenter = healthBar:CreateFontString(nil, "OVERLAY")
healthTextCenter:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
healthTextCenter:SetPoint("CENTER", healthBar, "CENTER", 0, -20)

local unitClassText = healthBar:CreateFontString(nil, "OVERLAY")
unitClassText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
unitClassText:SetPoint("CENTER", healthTextCenter, "CENTER", 0, -10)

local healthTextRight = healthBar:CreateFontString(nil, "OVERLAY")
healthTextRight:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
healthTextRight:SetPoint("RIGHT", healthBar, "RIGHT", 0, 0)


local function UpdateHealth()
    local health = UnitHealth("target")
    local maxHealth = UnitHealthMax("target")
    local percent = health / maxHealth * 100
    local unitClass = UnitClassification("target")

    healthBar:SetMinMaxValues(0, maxHealth)
    healthBar:SetValue(health)

    healthTextLeft:SetText(health .. " / " .. maxHealth)
    healthTextCenter:SetText(UnitName("target"))
    healthTextRight:SetText(string.format("%.1f", percent))
    unitClassText:SetText(UnitCreatureType("target"))

    healthBarBorder:SetBackdropBorderColor(1,0,0)
    if rarityUnits[unitClass] then
        unitClassText:SetText(rarityUnits[unitClass].label .. " - " .. UnitCreatureType("target"))
        healthBarBorder:SetBackdropBorderColor(unpack(rarityUnits[unitClass].rgb))
    end
end


local powerBar = CreateFrame("StatusBar")
powerBar:SetSize(225, 10)
powerBar:SetPoint("CENTER", 0, 325)
powerBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
powerBar:GetStatusBarTexture():SetHorizTile(false)
powerBar:SetMinMaxValues(0, UnitHealthMax("target"))
powerBar:SetValue(UnitHealth("target"))

local powerBarBG = healthBar:CreateTexture(nil, "BACKGROUND")
powerBarBG:SetAllPoints(true)
powerBarBG:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
powerBarBG:SetVertexColor(1, 0.25, 0.25, 0.1)

-- local healthBarBorder = CreateFrame("Frame", nil, healthBar, BackdropTemplateMixin and "BackdropTemplate")
-- healthBarBorder:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -5, 6)
-- healthBarBorder:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 5, -6)
-- healthBarBorder:SetBackdrop({
--     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
--     edgeSize = 16,
-- })

local powerTextLeft = powerBar:CreateFontString(nil, "OVERLAY")
powerTextLeft:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
powerTextLeft:SetPoint("LEFT", powerBar, "LEFT", 0, 0)

local powerTextCenter = powerBar:CreateFontString(nil, "OVERLAY")
powerTextCenter:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
powerTextCenter:SetPoint("CENTER", powerBar, "CENTER", 0, 0)

local powerTextRight = powerBar:CreateFontString(nil, "OVERLAY")
powerTextRight:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
powerTextRight:SetPoint("RIGHT", powerBar, "RIGHT", 0, 0)

for k, _ in pairs(PowerBarColor) do
    print(k)
end

local function UpdatePower()
    powerType, powerToken, _, _, _ = UnitPowerType("target")
    if not powerToken then
        return
    end
    local power = UnitPower("target")
    local maxPower = UnitPowerMax("target")
    local percent = power / maxPower * 100
    powerInfo = PowerBarColor[powerToken]

    powerBar:SetMinMaxValues(0, maxPower)
    powerBar:SetValue(power)
    powerBar:SetStatusBarColor(powerInfo.r, powerInfo.g, powerInfo.b)

    powerTextLeft:SetText(power .. " / " .. maxPower)
    powerTextCenter:SetText(powerInfo.atlasElementName)
    powerTextRight:SetText(string.format("%.1f", percent))
end

local function CreateIconFrame(w, h)
    local icon = CreateFrame("Frame", nil, UIParent)
    icon:SetSize(w, h)
    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    icon.texture:SetAllPoints()
    icon:Hide()
    return icon
end

local anchorDebuff = CreateIconFrame(16, 16)
anchorDebuff:SetPoint("CENTER", healthBar, "BOTTOMRIGHT", 18, -20)

local anchorBuff = CreateIconFrame(16, 16)
anchorBuff:SetPoint("CENTER", healthBar, "BOTTOMLEFT", -18, -20)

for i = 1, maxAuras do
    table.insert(targetBuffs, CreateIconFrame(16, 16))
    table.insert(targetDebuffs, CreateIconFrame(16, 16))
end


local function ShowAura(index, auras, direction, anchorDefault, auraFunc, tooltipFunc)
    auras[index]:Hide()
    local lastAuraIcon = auras[index - 1] or anchorDefault

    local name, icon, count, magicType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, _ = auraFunc("target", index)
    if name then
        local w, _ = auras[index]:GetSize()
        auras[index]:SetPoint("CENTER", lastAuraIcon, direction, w * directionModifier[direction], 0)
        auras[index].texture:SetTexture(icon)
        auras[index]:Show()
        auras[index]:SetScript("OnEnter", tooltipFunc)
    end
end


local function UpdateAura()
    local lastDebuff, lastBuff = anchorDebuff, anchorBuff
    for i = 1, maxAuras do
        ShowAura(i, targetDebuffs, "LEFT", anchorDebuff, UnitDebuff, function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnitDebuff("target", i)
            GameTooltip:Show()
        end)

        ShowAura(i, targetBuffs, "RIGHT", anchorBuff, UnitBuff, function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnitBuff("target", i)
            GameTooltip:Show()
        end)
    end
end

local castBarFrame = CreateFrame("StatusBar", "TargetCastBarFrame", healthBar)
castBarFrame:SetSize(200, 20)
castBarFrame:SetPoint("CENTER", healthBar, "CENTER", 0, -80)
castBarFrame:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
castBarFrame:GetStatusBarTexture():SetHorizTile(false)
castBarFrame:GetStatusBarTexture():SetVertTile(false)
castBarFrame:SetMinMaxValues(0, 1)
castBarFrame:SetValue(0)
castBarFrame:Hide()

local castBarFrameBG = castBarFrame:CreateTexture(nil, "BACKGROUND")
castBarFrameBG:SetAllPoints(true)
castBarFrameBG:SetColorTexture(0, 0, 0, 0.5)

local castBarFrameSpellText = castBarFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
castBarFrameSpellText:SetPoint("CENTER", castBarFrame)
castBarFrameSpellText:SetText("")
local castStartTime, castEndTime

local function UpdateCastBar()
    local name, _, _, startTime, endTime, _, _, notInterruptible = UnitCastingInfo("target")
    if not name then
        name, _, _, startTime, endTime, _, notInterruptible = UnitChannelInfo("target")
    end
    if name then
        castStartTime = startTime / 1000
        castEndTime = endTime / 1000
        castBarFrame:SetStatusBarColor(1, 1, 0, 1)
        if notInterruptible then
            castBarFrame:SetStatusBarColor(1, 1, 1, 1)
        end
        castBarFrame:SetMinMaxValues(castStartTime, castEndTime)
        castBarFrame:SetValue(GetTime())
        castBarFrameSpellText:SetText(name)
        castBarFrame:Show()
    else
        castBarFrame:Hide()
    end
end

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("UNIT_TARGET")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
frame:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_HEALTH" and unit == "target") then
        UpdateHealth()
    end
    if event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_POWER_UPDATE" and unit == "target") then
        UpdatePower()
    end
    if event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_AURA" and unit == "target") then
        UpdateAura()
    end

    if unit ~= "target" then
        return
    end

    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        UpdateCastBar()
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        castBarFrame:Hide()
    elseif event == "UNIT_TARGET" then
        UpdateCastBar()
    end
end)
castBarFrame:SetScript("OnUpdate", function(self, elapsed)
    if castBarFrame:IsShown() then
        local currentTime = GetTime()
        if castEndTime == nil or currentTime >= castEndTime then
            castBarFrame:Hide()
        else
            castBarFrame:SetValue(currentTime)
        end
    end
end)


