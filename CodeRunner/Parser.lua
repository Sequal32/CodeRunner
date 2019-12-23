local PluginFolder = script.Parent
local ENV = getfenv()

local EmptyFunction = function() end
local FoundFunctions = {Setup = EmptyFunction, Teardown = EmptyFunction, Main = nil, FName = nil}

for Name, Block in pairs(ENV) do
    if typeof(Block) == "function" then
        if Name == "Setup" then 
            FoundFunctions.Setup = Block
        elseif Name == "Teardown" then 
            FoundFunctions.Teardown = Block
        else
            FoundFunctions.FName = Name
            FoundFunctions.Main = Block
        end
	end
end

return FoundFunctions