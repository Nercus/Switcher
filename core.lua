Switcher = LibStub("AceAddon-3.0"):NewAddon("Switcher",
"AceConsole-3.0",
"AceEvent-3.0")

local strmatch = _G.string.match
local AceConsole = LibStub("AceConsole-3.0")

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
end

function Switcher:OnEnable()
    -- Register Events
    -- self:RegisterEvent("PLAYER_TALENT_UPDATE")
    -- self:RegisterEvent("PLAYER_PVP_TALENT_UPDATE")
    -- self:RegisterEvent("WAR_MODE_STATUS_UPDATE")
    -- self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    -- self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- self:RegisterEvent("PLAYER_LOGIN")
end


local function CreateNewButton(name, type, index, data)
    local Button = CreateFrame("Button", name, Switcher.SwitcherFrame)
    Button:SetSize(45, 45)
    Button:SetPoint("LEFT", Switcher.SwitcherFrame, "RIGHT", 50*index, 0)
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

    local Icon = Button:CreateTexture("ARTWORK") -- TODO: Create 1px Border and SetTextCoords for 30% Zoom
    Icon:SetTexture(selectedTexture)
    Icon:SetTexCoord(0.075, 1 - 0.075, 0.075, 1 - 0.075)
    Icon:SetAllPoints()
    Button:SetNormalTexture(Icon)

    Button.bottom = Button:CreateTexture()
    Button.bottom:SetColorTexture(0, 0, 0, 1)
    Button.bottom:SetPoint("TOPLEFT", Icon, "BOTTOMLEFT", -1, 0)
    Button.bottom:SetPoint("TOPRIGHT", Icon, "BOTTOMRIGHT", 1, 0)
    Button.bottom:SetHeight(1)

    Button.top = Button:CreateTexture()
    Button.top:SetColorTexture(0, 0, 0, 1)
    Button.top:SetPoint("BOTTOMLEFT", Icon, "TOPLEFT", -1, 0)
    Button.top:SetPoint("BOTTOMRIGHT", Icon, "TOPRIGHT", 1, 0)
    Button.top:SetHeight(1)

    Button.left = Button:CreateTexture()
    Button.left:SetColorTexture(0, 0, 0, 1)
    Button.left:SetPoint("TOPLEFT", Icon, "BOTTOMLEFT", -1, 0)
    Button.left:SetPoint("BOTTOMRIGHT", Icon, "TOPRIGHT", 1, 0)
    Button.left:SetWidth(1)

    Button.right = Button:CreateTexture()
    Button.right:SetColorTexture(0, 0, 0, 1)
    Button.right:SetPoint("TOPLEFT", Icon, "BOTTOMLEFT", -1, 0)
    Button.right:SetPoint("BOTTOMRIGHT", Icon, "TOPRIGHT", 1, 0)
    Button.right:SetWidth(1)

    local iterator = selectedindex
    Button:SetScript("OnMouseWheel", function(self, click)
        if type == "Talent" then
            iterator = iterator + click
            if iterator == 4 then
                iterator = 1
            elseif iterator == 0 then
                iterator = 3
            end
            local table = self.data[iterator]
            Icon:SetTexture(table.texture)
            LearnTalent(table.talentID)
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
        CreateNewButton("TalentButton".. i, "Talent", i, data)
    end
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
