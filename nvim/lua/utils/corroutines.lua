
local M = {}

--- Stops a coroutine for ms milliseconds.
---
--- This doesn't work outside a corroutine and
--- will be skipped if called from outside.
---
--- @param ms integer
--- @return nil
function M.sleep(ms)
	local co = coroutine.running()

	if co == nil then
		return
	end

	vim.defer_fn(function()
		coroutine.resume(co)
	end, ms)
	coroutine.yield()
end

return M
