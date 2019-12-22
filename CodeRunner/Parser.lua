local PluginFolder = script.Parent
local ENV = getfenv()

for Name,Block in pairs(ENV) do
	if typeof(Block) == "function" then
		return Name,Block
	end
end