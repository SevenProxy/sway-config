local M = {}

function M.deep_merge(target, source)
	if source == nil then
		return
	end

	for key, value in pairs(source) do
		if type(value) == "table" and type(target[key]) == "table" then
			M.deep_merge(target[key], value)
		else
			target[key] = value
		end
	end
end

function M.merge_replace(target, source)
	if source == nil then
		return
	end

	for key, value in pairs(source) do
		target[key] = value
	end
end

return M
