local PluginFolder = script.Parent
local ENV = getfenv()

for Name,Block in pairs(ENV) do
    print(Name, Block)
	if typeof(Block) == "function" then
		return {Name, Block}
	end
end

return nil