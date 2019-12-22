-- Paths
local PluginFolder = script.Parent
-- UIs
local CoreUI = game:GetService("StarterGui").CodeRunner.Core
local ListUI = CoreUI.FunctionList
local TopUI = CoreUI.TopBar
local PromptUI = CoreUI.Prompt

local Entry = PluginFolder.FunctionEntry

-- Init the plugin
plugin:CreatePluginMenu(math.random(), "Code Runner", "")
plugin:CreateDockWidgetPluginGui(math.random(), DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, false, 200, 360))

-- Running variables
local SavedFunctions = plugin:GetSetting("SavedFunctions") or {}
local Functions = {}

local CurrentScript = nil
local CurrentResponse = nil
local IsEditing = false

function AddEntry(FunctionName)
    local Frame = Entry:Clone()
    Frame.Name = FunctionName
    Frame.FunctionName.Text = FunctionName
    Frame.Parent = ListUI

    Frame.MouseEnter:Connect(function()
        Frame.Edit.Visible = true 
        Frame.Trash.Visible = true
        Frame.Run.Visible = true
    end)

    Frame.MouseLeave:Connect(function()
        Frame.Edit.Visible = false 
        Frame.Trash.Visible = false
        Frame.Run.Visible = true
    end)

    Frame.Run.Activated:Connect(function()
        for _,Object in pairs(game.Selection:Get()) do
            Functions[FunctionName](Object)
        end
    end)

    -- Adjust size of the scrolling frame 
    ListUI.CanvasSize = UDim2.fromOffset(0, #ListUI:GetChildren()-1 * Entry.Size.Y.Offset)
end

-- Returns true if yes was clicked
function Prompt(Message)
    ListUI.Visible = false
    PromptUI.Visible = false

    PromptUI.Message.Text = Message

    Response = nil
    repeat wait() until Response ~= nil -- Will wait until one of the buttons is pressed

    PromptUI.Visible = false
    ListUI.Visible = true

    return Response
end

function NewScript()
    if IsEditing then return end

    IsEditing = true
    CurrentScript = PluginFolder.Template:Clone()
    plugin:OpenScript(Script)
end

function SaveScript()
    -- Close the script
    local Source = CurrentScript.Source
    CurrentScript:Destroy()
    -- Load the script
    local FunctionName, Function = require(Source.."\n\n"..PluginFolder.Parser.Source)
    local Exists = Functions[FunctionName]
    -- If there was no function written
    if not Function then warn("No function was found!")
    -- If we're about to overwrite a function
    if Exists and not Prompt("Overwrite "..FunctionName.."?") then return end
    
    SavedFunctions[FunctionName] = Source
    Functions[FunctionName] = Function

    if not Exists then
        AddEntry(FunctionName)
    end
    -- Save the script in storage
    plugin:SetSetting("SavedFunctions", SavedFunctions)

    IsEditing = false
end

PromptUI.Yes.Activated:Connect(function() Response = true end)
PromptUI.No.Activated:Connect(function() Response = false end)

CoreUI.Done.Activated:Connect(SaveScript)
TopUI.Add.Activated:Connect(NewScript)