Switcher = LibStub("AceAddon-3.0"):NewAddon("Switcher", "AceConsole-3.0")


-- Switcher:RegisterChatCommand("Toggle", "ToggleMainFrame")

-- function Switcher:ToggleMainFrame(input)
--     print(input)
-- end

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
    tex:Show()
end


local function CreateNewButton(name, type)
    local Button = CreateFrame("Button", name, Switcher.SwitcherFrame)
    Button:SetSize(60,60)
    Button:SetPoint("CENTER", Switcher.SwitcherFrame, "CENTER", 0, 0)
    Button:EnableMouseWheel(1)

    local Icon = Button:CreateTexture("ARTWORK") -- TODO: Create 1px Border and SetTextCoords for 30% Zoom
    Icon:SetTexture(627487)
    Icon:SetAllPoints()
    Button:SetNormalTexture(Icon)

    Button:SetScript("OnMouseWheel", function(self, click)
        if click == 1 then
            Icon:SetTexture(574575)
        else
            Icon:SetTexture(574575)
        end
    end)
end


CreateNewButton("Test", 1)
