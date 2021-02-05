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
    -- self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED") -> TODO: Update all Talents
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
-- TODO: Spec Change Button
-- TODO: CanChangeTalent(TalentID) opt. arg. TalentID checking. Rested, not on cooldown
-- TODO: Soulbind Buttons



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
    Button:SetScript("OnMouseWheel", function(self, click)
        -- TODO: Throttle Change talent
        if type == "Talent" or type == "PvPTalent" then
            iterator = iterator + click
            if iterator == numchoice + 1 then
                iterator = 1
            elseif iterator == 0 then
                iterator = numchoice
            end
            local table = self.data[iterator]
            Icon:SetTexture(table.texture)
            if type == "Talent" then
                LearnTalent(table.talentID)
            elseif type == "PvPTalent" then
                LearnPvpTalent(table.talentID, index);
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
            -- TODO: exclude selected talent in other button
            if talentID == pvptalentinfo.selectedTalentID then
                pvptalentdata.selected = true
            end
            table.insert(data, pvptalentdata)
        end
        CreateNewButton("SwitcherPvPTalentButton".. k, "PvPTalent", k, data)
    end
    -- Soulbind
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
