local M = {}

local Dbg = require("utils.is_debug")

--- @class Logger
--- @field debug fun(self: Logger, messsage: string)
--- @field info fun(self: Logger, messsage: string)
--- @field error fun(self: Logger, messsage: string)
--- @field warn fun(self: Logger, messsage: string)

--- Sends an nvim log with the set module name.
---
--- @param message string
--- @param level string?
--- @return nil
function M:log(message, level)
	local log_spec = ""

	if self.module_name ~= nil then
		log_spec = log_spec .. "[" .. self.module_name .. "] "
	end

	local sanitized_level = string.upper(level or "INFO")

	if sanitized_level == "DEBUG" and not Dbg.is_debug() then
		return
	end

	vim.notify(
		log_spec .. message,
		vim.log.levels[sanitized_level]
	)
end

--- Calls log with with info as a level.
---
--- @param message string
function M:info(message)
	self:log(message, "INFO")
end

--- Calls log with with error as a level.
---
--- @param message string
function M:error(message)
	self:log(message, "ERROR")
end

--- Calls log with with warning as a level.
---
--- @param message string
function M:warning(message)
	self:log(message, "WARN")
end

--- Calls log with with debug as a level.
---
--- @param message string
function M:debug(message)
	self:log(message, "DEBUG")
end

--- Sets the current module name,
--- may be unsanitized, set explicitly.
---
--- @param name string
--- @return Logger
local function for_module(name)
	return setmetatable({ module_name = name }, { __index = M })
end

return {
	for_module = for_module
}
