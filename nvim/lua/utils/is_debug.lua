local M = {}

function M.is_debug()
	local dbg = vim.env.NVIM_DEBUG
	return dbg == "1" or dbg == "true"
end

return M
