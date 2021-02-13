Switcher = LibStub("AceAddon-3.0"):NewAddon("Switcher",
"AceConsole-3.0",
"AceEvent-3.0")

local strmatch = _G.string.match
local AceConsole = LibStub("AceConsole-3.0")

-- Binding Variables
local originalbind
SWITCHERHEADER = "Toggle Switcher Frame"

function Switcher:OnInitialize()
    local Switcher_Frame = CreateFrame("Frame", nil, UIParent)
    Switcher_Frame:SetWidth(300)
    Switcher_Frame:SetHeight(300)
    Switcher_Frame:SetFrameStrata("BACKGROUND")
    Switcher_Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.SwitcherFrame = Switcher_Frame

    local tex = Switcher_Frame:CreateTexture("ARTWORK")
    tex:SetAllPoints()
    tex:SetColorTexture(0, 0, 0, 0.5)
    tex:Hide()
    self.SwitcherFrame.bg = tex

    self:RegisterEvent("PLAYER_LOGIN")
end

function Switcher:ToggleSwitcherFrame()
    if self.SwitcherFrame:IsShown() then
        self.SwitcherFrame:Hide()
    else
        self.SwitcherFrame:Show()
    end
end

function Switcher:OnEnable()
    -- Register Events
    -- self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED") -> TODO: Update all Talent data
    -- self:RegisterEvent("PLAYER_REGEN_DISABLED") Entering Combat -> TODO: Disable Mouse
    -- self:RegisterEvent("PLAYER_REGEN_ENABLED") Leaving Combat -> TODO: Enable Mouse
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end


function Switcher:PLAYER_LOGIN()
    originalbind = GetBindingKey("TOGGLETALENTS")
    SetBinding("N")
    SetBinding(originalbind, "SWITCHER_TOGGLE_FRAME")
end


function Switcher:OnDisable()
    SetBinding(originalbind, "TOGGLETALENTS")
end




-- TODO: Warmode Enable/Disable Button
-- TODO: Spec Change Button: Immediatly start spec change. Interrupt if next spec is chosen.
-- TODO: Soulbind Buttons
-- TODO: Change Based on Player Level
-- TODO: Use Book if not in combat and not rested on scroll. Black overlay Texture with Text "Scroll to use book"


function Switcher:CanChangeTalents(data)
    if (InCombatLockdown()) then return false end

    if data then
        local spellid
        for _,j in ipairs(data) do
            if j.selected then
                spellid = j.spellID
            end
        end
        if spellid then
            local currentCharges, _, _, cooldownDuration, _ = GetSpellCharges(spellid);
            if currentCharges then
                if currentCharges == 0 and cooldownDuration > 0 then
                    return false
                end
            else
                local start, duration, enabled = GetSpellCooldown(spellid)
                if duration > 0 then
                    return false
                end
            end
        end
    end

    if (IsResting()) then return true end
    local buffs = {
        32727, -- Arena Preparation
        44521, -- Preperation
        228128, -- Dungeon Preperation
        227041, -- Tome of the Tranquil Mind
        226234, -- Codex of the Tranquil Mind
        256231, -- Tome of the Quiet Mind
        256230, -- Codex of the Quiet Mind
        321923, -- Tome of the Still Mind
        324028, -- Codex of the Still Mind
        325012, -- Time to Reflect (Kyrian)
    }
    for _, id in ipairs(buffs) do
        local name = GetSpellInfo(id)
        if AuraUtil.FindAuraByName(name, "player") then
            return true
        end
    end
end

local function CreateModuleButton(name, type, data)
    local Button = CreateFrame("Button", name, Switcher.SwitcherFrame)
    Button:SetSize(50, 50)

    local icon
    local yoffset
    if type == "Spec" then
        icon = select(4, GetSpecializationInfo(GetSpecialization()))
        yoffset = 2.5
    elseif type == "Warmode" then
        icon = 1455894 -- Use Atlas here: "pvptalents-warmode-swords-disabled"; "pvptalents-warmode-swords"
        yoffset = 102.5
    elseif type == "Soulbind" then
            -- Atlas for Covenants:
            -- "covenantchoice-offering-portrait-kyrian-kleia"
            -- "covenantchoice-offering-portrait-kyrian-mikanikos"
            -- "covenantchoice-offering-portrait-kyrian-pelagos"
            -- "covenantchoice-offering-portrait-necrolord-emeni"
            -- "covenantchoice-offering-portrait-necrolord-heirmir"
            -- "covenantchoice-offering-portrait-necrolord-marileth"
            -- "covenantchoice-offering-portrait-nightfae-korayn"
            -- "covenantchoice-offering-portrait-nightfae-niya"
            -- "covenantchoice-offering-portrait-nightfae-dreamweaver"
            -- "covenantchoice-offering-portrait-venthyr-draven"
            -- "covenantchoice-offering-portrait-venthyr-nadjia"
            -- "covenantchoice-offering-portrait-venthyr-theotar"

    end

    Button:SetPoint("TOPRIGHT", Switcher.SwitcherFrame, "TOPLEFT", -2.5, -yoffset)

    local Icon = Button:CreateTexture("ARTWORK")
    Icon:SetTexture(icon)
    Icon:SetTexCoord(0.075, 1 - 0.075, 0.075, 1 - 0.075)
    Icon:SetAllPoints()
    Button:SetNormalTexture(Icon)


    Button.bottom = Button:CreateTexture()
    Button.bottom:SetColorTexture(0, 0, 0, 1)
    Button.bottom:SetPoint("TOPLEFT", Icon, "BOTTOMLEFT", -1, 0)
    Button.bottom:SetPoint("TOPRIGHT", Icon, "BOTTOMRIGHT", 1, 0)
    Button.bottom:SetHeight(1)
    Button.bottom:SetDrawLayer("BACKGROUND")

    Button.top = Button:CreateTexture()
    Button.top:SetColorTexture(0, 0, 0, 1)
    Button.top:SetPoint("BOTTOMLEFT", Icon, "TOPLEFT", -1, 0)
    Button.top:SetPoint("BOTTOMRIGHT", Icon, "TOPRIGHT", 1, 0)
    Button.top:SetHeight(1)
    Button.top:SetDrawLayer("BACKGROUND")

    Button.left = Button:CreateTexture()
    Button.left:SetColorTexture(0, 0, 0, 1)
    Button.left:SetPoint("TOPLEFT", Icon, "BOTTOMLEFT", -1, 0)
    Button.left:SetPoint("BOTTOMRIGHT", Icon, "TOPRIGHT", 1, 0)
    Button.left:SetWidth(1)
    Button.left:SetDrawLayer("BACKGROUND")

    Button.right = Button:CreateTexture()
    Button.right:SetColorTexture(0, 0, 0, 1)
    Button.right:SetPoint("TOPLEFT", Icon, "BOTTOMLEFT", -1, 0)
    Button.right:SetPoint("BOTTOMRIGHT", Icon, "TOPRIGHT", 1, 0)
    Button.right:SetWidth(1)
    Button.right:SetDrawLayer("BACKGROUND")

    local FlyoutIndicator = Button:CreateTexture("ARTWORK")
    FlyoutIndicator:SetAtlas("common-icon-forwardarrow")
    FlyoutIndicator:SetPoint("CENTER", Button, "RIGHT", 0, 0)
    FlyoutIndicator:SetSize(13, 13)
    FlyoutIndicator:Hide()
    Button.flyoutindicator = FlyoutIndicator


    Button:SetScript("OnEnter", function(self)
        self.flyoutindicator:Show()
    end)

    Button:SetScript("OnLeave", function(self)
        self.flyoutindicator:Hide()
    end)

    -- local anim = Button:CreateAnimationGroup()
    -- anim:SetLooping("NONE")
    -- anim.translation = anim:CreateAnimation("Rotation")
    -- anim.translation:SetDegrees(360)
    -- anim.translation:SetDuration(3)
    -- anim.translation:SetSmoothing("OUT")

    -- Button:SetScript("OnEnter", function()
    --     anim:Play()
    -- end)



end

local function CreateNewButton(name, type, index, data)
    local Button = CreateFrame("Button", name, Switcher.SwitcherFrame)
    Button:SetSize(45, 45)
    local yoffset
    if type == "Talent" then -- offset for types
        yoffset = 5
    elseif type == "Soulbind" then
        yoffset = 55
    elseif type == "PvPTalent" then
        yoffset = 105
    end
    Button:SetPoint("TOPRIGHT", Switcher.SwitcherFrame, "TOPLEFT", (45+5)*index, -yoffset)
    Button:EnableMouseWheel(1)
    Button.data = data

    local selectedTexture
    local selectedindex
    for i, j in ipairs(data) do
        if j.selected then
            selectedTexture = j.texture
            selectedindex = j.index
        end
    end
    local numchoice = #data
    local Icon = Button:CreateTexture("ARTWORK")
    Icon:SetTexture(selectedTexture)
    Icon:SetTexCoord(0.075, 1 - 0.075, 0.075, 1 - 0.075)
    Icon:SetAllPoints()
    Button:SetNormalTexture(Icon)


    Button.bottom = Button:CreateTexture()
    Button.bottom:SetColorTexture(0, 0, 0, 1)
    Button.bottom:SetPoint("TOPLEFT", Icon, "BOTTOMLEFT", -1, 0)
    Button.bottom:SetPoint("TOPRIGHT", Icon, "BOTTOMRIGHT", 1, 0)
    Button.bottom:SetHeight(1)
    Button.bottom:SetDrawLayer("BACKGROUND")

    Button.top = Button:CreateTexture()
    Button.top:SetColorTexture(0, 0, 0, 1)
    Button.top:SetPoint("BOTTOMLEFT", Icon, "TOPLEFT", -1, 0)
    Button.top:SetPoint("BOTTOMRIGHT", Icon, "TOPRIGHT", 1, 0)
    Button.top:SetHeight(1)
    Button.top:SetDrawLayer("BACKGROUND")

    Button.left = Button:CreateTexture()
    Button.left:SetColorTexture(0, 0, 0, 1)
    Button.left:SetPoint("TOPLEFT", Icon, "BOTTOMLEFT", -1, 0)
    Button.left:SetPoint("BOTTOMRIGHT", Icon, "TOPRIGHT", 1, 0)
    Button.left:SetWidth(1)
    Button.left:SetDrawLayer("BACKGROUND")

    Button.right = Button:CreateTexture()
    Button.right:SetColorTexture(0, 0, 0, 1)
    Button.right:SetPoint("TOPLEFT", Icon, "BOTTOMLEFT", -1, 0)
    Button.right:SetPoint("BOTTOMRIGHT", Icon, "TOPRIGHT", 1, 0)
    Button.right:SetWidth(1)
    Button.right:SetDrawLayer("BACKGROUND")

    local iterator
    if selectedindex then
        iterator = selectedindex
    else
        iterator = 1
    end
    local last
    local previter
    Button:SetScript("OnMouseWheel", function(self, click)
        if not last or last < GetTime() - 0.1 then
            last = GetTime()
            if (type == "Talent" or type == "PvPTalent") then
                local last
                iterator = iterator + click
                if iterator == numchoice + 1 then
                    iterator = 1
                elseif iterator == 0 then
                    iterator = numchoice
                end
                if type == "PvPTalent" then
                    local selectedpvptalents = {}
                    for i = 1, 3 do
                        local slotinfo = C_SpecializationInfo.GetPvpTalentSlotInfo(i)
                        if (slotinfo.selectedTalentID) then
                            selectedpvptalents[slotinfo.selectedTalentID] = true
                        end
                    end
                    while selectedpvptalents[self.data[iterator].talentID] do
                        iterator = iterator + click
                        if iterator == numchoice + 1 then
                            iterator = 1
                        elseif iterator == 0 then
                            iterator = numchoice
                        end
                    end
                end

                local info = self.data[iterator]
                if info then
                    if Switcher:CanChangeTalents(self.data) then
                        Icon:SetTexture(info.texture)
                        info.selected = true
                        if previter then
                            self.data[previter].selected = false
                        end
                        if type == "Talent" then
                            LearnTalent(info.talentID)
                        elseif type == "PvPTalent" then
                            LearnPvpTalent(info.talentID, index);
                        end
                    else
                    end
                end
                previter = iterator
            end
        end
    end)
    Button:SetScript("OnEnter", function(self)
        self.bottom:SetColorTexture(1, 1, 1)
        self.top:SetColorTexture(1, 1, 1)
        self.left:SetColorTexture(1, 1, 1)
        self.right:SetColorTexture(1, 1, 1)
    end)
    Button:SetScript("OnLeave", function(self)
        self.bottom:SetColorTexture(0, 0, 0)
        self.top:SetColorTexture(0, 0, 0)
        self.left:SetColorTexture(0, 0, 0)
        self.right:SetColorTexture(0, 0, 0)
    end)
    Button:Show()
end


function Switcher:PLAYER_ENTERING_WORLD()

    CreateModuleButton("Spec", "Spec")
    CreateModuleButton("Warmode", "Warmode")
    -- Talents
    local activeSpec = GetActiveSpecGroup()
    for i = 1, MAX_TALENT_TIERS do
        local data = {}
        for j = 1, NUM_TALENT_COLUMNS do
            local talentID, name, texture, selected, available, spellID = GetTalentInfo(i, j, activeSpec)
            local talentdata = {
                ["talentID"] = talentID,
                ["name"] = name,
                ["texture"] = texture,
                ["selected"] = selected,
                ["available"] = available,
                ["spellID"] = spellID,
                ["index"] = j
            }
            table.insert(data, talentdata)
        end
        CreateNewButton("SwitcherTalentButton".. i, "Talent", i, data)
    end
    -- Honor Talents
    for k = 1, 3 do
        local data = {}
        local pvptalentdata
        local pvptalentinfo = C_SpecializationInfo.GetPvpTalentSlotInfo(k)
        for _, l in ipairs(pvptalentinfo.availableTalentIDs) do
            local talentID, name, texture, selected, available, spellID = GetPvpTalentInfoByID(l)
            pvptalentdata = {
                ["talentID"] = talentID,
                ["name"] = name,
                ["texture"] = texture,
                ["selected"] = selected,
                ["available"] = available,
                ["spellID"] = spellID,
                ["index"] = k
            }

            if talentID == pvptalentinfo.selectedTalentID then
                pvptalentdata.selected = true
            end
            table.insert(data, pvptalentdata)
        end
        CreateNewButton("SwitcherPvPTalentButton".. k, "PvPTalent", k, data)
    end
    -- Soulbind


    Switcher:ToggleSwitcherFrame()
end




AceConsole:RegisterChatCommand("switcher", function(msg)
    if strmatch(msg, "move") then
        if Switcher.SwitcherFrame:IsMovable() then
            Switcher.SwitcherFrame:SetMovable(false)
            Switcher.SwitcherFrame:EnableMouse(false)
            Switcher.SwitcherFrame.bg:Hide()
        else
            Switcher.SwitcherFrame:SetMovable(true)
            Switcher.SwitcherFrame:EnableMouse(true)
            Switcher.SwitcherFrame:RegisterForDrag("LeftButton")
            Switcher.SwitcherFrame:SetScript("OnDragStart", Switcher.SwitcherFrame.StartMoving)
            Switcher.SwitcherFrame:SetScript("OnDragStop", Switcher.SwitcherFrame.StopMovingOrSizing)
            Switcher.SwitcherFrame.bg:Show()
        end
    end
end, true)
