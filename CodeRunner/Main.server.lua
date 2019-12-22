-- Paths
local PluginFolder = script.Parent
-- UIs
local CoreUI = game:GetService("StarterGui").CodeRunner.Core:Clone()
local ListUI = CoreUI.FunctionList
local TopUI = CoreUI.TopBar
local PromptUI = CoreUI.Prompt
local DoneUI = CoreUI.Done

local Entry = PluginFolder.FunctionEntry

-- Init the plugin
plugin:CreatePluginMenu(math.random(), "Code Runner", "")
local UI = plugin:CreateDockWidgetPluginGui(math.random(), DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, false, 200, 360))

CoreUI.Position = UDim2.fromScale(0, 0)
CoreUI.Size = UDim2.fromScale(1, 1)
CoreUI.Parent = UI
-- Running variables
local SavedFunctions = plugin:GetSetting("SavedFunctions") or {}
local Functions = {}

local CurrentScript = nil
local CurrentResponse = nil
local IsEditing = false

function AddEntry(FunctionName)
    local Frame = Entry:Clone()
    local Buttons = Frame.Buttons
    Frame.Name = FunctionName
    Frame.FunctionName.Text = FunctionName
    Frame.Parent = ListUI

    Frame.MouseEnter:Connect(function()
        Buttons.Edit.Visible = true 
        Buttons.Trash.Visible = true
        Buttons.Run.Visible = true
    end)

    Frame.MouseLeave:Connect(function()
        Buttons.Edit.Visible = false 
        Buttons.Trash.Visible = false
        Buttons.Run.Visible = false
    end)

    Buttons.Run.Activated:Connect(function()
        local Selection = game.Selection:Get()

        for _,Object in pairs(Selection) do
            Functions[FunctionName](Object)
        end
    end)

    Buttons.Edit.Activated:Connect(function()
        if IsEditing then return end
        EditScript(FunctionName)
    end)

    Buttons.Trash.Activated:Connect(function()
        Functions[FunctionName] = nil
        SavedFunctions[FunctionName] = nil
        Frame:Destroy()

        plugin:SetSetting("SavedFunctions", SavedFunctions)
    end)

    -- Adjust size of the scrolling frame 
    ListUI.CanvasSize = UDim2.fromOffset(0, #ListUI:GetChildren()-1 * Entry.Size.Y.Offset)
end


function Edit(FunctionName)
    IsEditing = true
    DoneUI.Visible = true
    ListUI.Visible = false

    CurrentScript.Name = FunctionName
    plugin:OpenScript(CurrentScript)
end
-- Returns true if yes was clicked
function Prompt(Message)
    ListUI.Visible = false
    PromptUI.Visible = true

    PromptUI.Message.Text = Message

    Response = nil
    print("Waiting")
    repeat wait() until Response ~= nil -- Will wait until one of the buttons is pressed

    PromptUI.Visible = false
    ListUI.Visible = true

    return Response
end

function NewScript()
    if IsEditing then return end
    CurrentScript = PluginFolder.Template:Clone()
    Edit("YourFunction")
end

function LoadScript(Source, Parse)
    CurrentScript = Instance.new("ModuleScript")
    CurrentScript.Source = Source..(Parse and "\n\n"..PluginFolder.Parser.Source or "")
    return Parse and require(CurrentScript)
end

function EditScript(FunctionName)
    LoadScript(SavedFunctions[FunctionName])
    Edit(FunctionName)
end

function SaveScript()
    if not DoneUI.Visible then return end

    DoneUI.Visible = false
    -- Close the script
    local Source = CurrentScript.Source
    CurrentScript:Destroy()
    -- Load the script
    local Result = LoadScript(Source, true)
    local Exists = SavedFunctions[FunctionName] == nil
    -- If there was no function written
    if not Result then warn("No function was found!"); IsEditing = false return end

    FunctionName, Function = unpack(Result)
    -- If we're about to overwrite a function
    if Exists and not Prompt("Overwrite "..FunctionName.."?") then IsEditing = false return end
    
    SavedFunctions[FunctionName] = Source
    Functions[FunctionName] = Function

    if not Exists then
        AddEntry(FunctionName)
    end
    -- Save the script in storage
    plugin:SetSetting("SavedFunctions", SavedFunctions)

    ListUI.Visible = true
    IsEditing = false
end

-- Load in functions from storage
for FunctionName,Source in pairs(SavedFunctions) do
    Functions[FunctionName] = LoadScript(Source, true)[2]
    AddEntry(FunctionName)
end

PromptUI.Yes.Activated:Connect(function() Response = true end)
PromptUI.No.Activated:Connect(function() Response = false end)

DoneUI.Activated:Connect(SaveScript)
CoreUI.Done.Activated:Connect(SaveScript)
TopUI.Add.Activated:Connect(NewScript)