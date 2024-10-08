local maxAuras = 40
local aurasPerRow = 5
local targetDebuffs = {}
local targetBuffs = {}

local rarityUnits = {
    rare = {label = "Rare", rgb = {0.5, 0.32, 0.55}},
    elite = {label = "Elite", rgb = {1, 1, 1}},
    rareelite = {label = "Rare Elite", rgb = {1.00, 0.96, 0.41}},
    minus = {label = "Minus", rgb = {0, 0.82, 1.00}},
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
healthBar:Hide()

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
    healthBar:Hide()
    local name =  UnitName("target")
    if not name then
        return
    end
    local health = UnitHealth("target")
    local maxHealth = UnitHealthMax("target")
    local percent = health / maxHealth * 100
    local unitClass = UnitClassification("target")

    healthBar:SetMinMaxValues(0, maxHealth)
    healthBar:SetValue(health)

    healthTextLeft:SetText(health .. " / " .. maxHealth)
    healthTextCenter:SetText(name)
    healthTextRight:SetText(string.format("%.1f", percent))
    unitClassText:SetText(UnitCreatureType("target"))

    healthBarBorder:SetBackdropBorderColor(1.00, 0, 0)
    if rarityUnits[unitClass] then
        unitClassText:SetText(rarityUnits[unitClass].label .. " - " .. UnitCreatureType("target"))
        healthBarBorder:SetBackdropBorderColor(unpack(rarityUnits[unitClass].rgb))
    end

    healthBar:Show()
end


local powerBar = CreateFrame("StatusBar")
powerBar:SetSize(225, 10)
powerBar:SetPoint("CENTER", 0, 325)
powerBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
powerBar:GetStatusBarTexture():SetHorizTile(false)
powerBar:SetMinMaxValues(0, UnitHealthMax("target"))
powerBar:SetValue(UnitHealth("target"))
powerBar:Hide()

local powerBarBG = powerBar:CreateTexture(nil, "BACKGROUND")
powerBarBG:SetAllPoints(true)
powerBarBG:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
powerBarBG:SetVertexColor(1, 0.25, 0.25, 0.1)

local powerTextLeft = powerBar:CreateFontString(nil, "OVERLAY")
powerTextLeft:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
powerTextLeft:SetPoint("LEFT", powerBar, "LEFT", 0, 0)

local powerTextCenter = powerBar:CreateFontString(nil, "OVERLAY")
powerTextCenter:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
powerTextCenter:SetPoint("CENTER", powerBar, "CENTER", 0, 0)

local powerTextRight = powerBar:CreateFontString(nil, "OVERLAY")
powerTextRight:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
powerTextRight:SetPoint("RIGHT", powerBar, "RIGHT", 0, 0)

local shieldBar = CreateFrame("StatusBar", nil, healthBar)
shieldBar:SetSize(healthBar:GetSize())
shieldBar:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
shieldBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
shieldBar:GetStatusBarTexture():SetHorizTile(false)
shieldBar:SetStatusBarColor(1, 1, 1)
shieldBar:Hide()

local shieldBarBG = shieldBar:CreateTexture(nil, "BACKGROUND")
shieldBarBG:SetAllPoints(true)
shieldBarBG:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")

local shieldBarText = shieldBar:CreateFontString(nil, "OVERLAY")
shieldBarText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
shieldBarText:SetPoint("CENTER", shieldBar, "CENTER", 0, 0)

local function UpdateShield()
    shieldBar:Hide()
    local shield = UnitGetTotalAbsorbs("target")
    if shield > 0 then
        shieldBarText:SetText("Shield - " .. shield)
        shieldBar:Show()
    end
end


local function UpdatePower()
    powerType, powerToken, _, _, _ = UnitPowerType("target")
    if not powerToken then
        powerBar:Hide()
        return
    end
    local power = UnitPower("target")
    local maxPower = UnitPowerMax("target")
    local percent = power / maxPower * 100
    powerBar:SetMinMaxValues(0, maxPower)
    powerBar:SetValue(power)
    powerTextLeft:SetText(power .. " / " .. maxPower)
    powerTextRight:SetText(string.format("%.1f", percent))

    powerInfo = PowerBarColor[powerToken]
    if powerInfo then
        powerBar:SetStatusBarColor(powerInfo.r, powerInfo.g, powerInfo.b)
        powerTextCenter:SetText(powerInfo.atlasElementName)
    end
    powerBar:Show()
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

    local aura = auraFunc("target", index)
    if not aura then
        return
    end

    if aura.name then
        local yOffSet = 0
        local w, h = auras[index]:GetSize()
        if (index -1) % aurasPerRow == 0 then
            lastAuraIcon = anchorDefault
            local row = math.floor((index - 1) / aurasPerRow)
            yOffSet = h * row * -1
        end

        auras[index]:SetPoint("CENTER", lastAuraIcon, direction, (w - 3) * directionModifier[direction], yOffSet)
        auras[index].texture:SetTexture(aura.icon)
        auras[index]:Show()
        auras[index]:SetScript("OnEnter", tooltipFunc)
    end
    if aura.count and aura.count > 0 then
        local label = auras[index]:CreateFontString(nil, "OVERLAY")
        label:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
        label:SetPoint("CENTER", auras[index], "BOTTOMRIGHT", 0, 0)
        label:SetText(count)
    end
end


local function UpdateAura()
    local lastDebuff, lastBuff = anchorDebuff, anchorBuff
    for i = 1, maxAuras do
        ShowAura(i, targetDebuffs, "LEFT", anchorDebuff, C_UnitAuras.GetDebuffDataByIndex, function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnitDebuff("target", i)
            GameTooltip:Show()
        end)

        ShowAura(i, targetBuffs, "RIGHT", anchorBuff, C_UnitAuras.GetBuffDataByIndex, function(self)
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

local castBarFrameTick = castBarFrame:CreateTexture(nil, "OVERLAY")
castBarFrameTick:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
castBarFrameTick:SetVertexColor(1, 0, 0, 1)
castBarFrameTick:SetWidth(2)
castBarFrameTick:SetHeight(castBarFrame:GetHeight())

local castBarFrameSpellText = castBarFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
castBarFrameSpellText:SetPoint("CENTER", castBarFrame)
castBarFrameSpellText:SetText("")
local castBarFrameSpellTimerText = castBarFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
castBarFrameSpellTimerText:SetFont("Fonts\\FRIZQT__.TTF", 5, "OUTLINE")
castBarFrameSpellTimerText:SetPoint("RIGHT", castBarFrame)
local castStartTime, castEndTime

local function UpdateCastBar()
    castBarFrame:Hide()

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

        local _, _, _, lagWorld = GetNetStats()
        local latencyOffSet = lagWorld / 1000 / (castEndTime - castStartTime)
        castBarFrameTick:ClearAllPoints()
        castBarFrameTick:SetPoint("CENTER", castBarFrame, "RIGHT", castBarFrame:GetWidth() * latencyOffSet * -1, 0)
        castBarFrameTick:Show()
    end
end

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("UNIT_TARGET")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
frame:RegisterEvent("UNIT_SPELLCAST_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
frame:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_TARGET_CHANGED" then
        UpdateHealth()
        UpdatePower()
        UpdateAura()
        UpdateShield()
    end
    if event == "UNIT_HEALTH" then
        UpdateHealth()
    end
    if event == "UNIT_POWER_UPDATE"then
        UpdatePower()
    end
    if event == "UNIT_AURA" then
        UpdateAura()
    end
    if event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        UpdateShield()
    end
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_DELAYED" then
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
            return
        end
        castBarFrame:SetValue(currentTime)
        local castTime = currentTime - castEndTime
        castBarFrameSpellTimerText:SetText(string.format("%.1f", castTime))
    end
end)


