
--[[
	This module enables per-project lsp configuration.

	It looks for the <lang-or-alias>-lsp-config.toml pattern in
	your current open project at CWD and overrides the configuration,
	translating the TOML to a LUA table.

	The configuration change is triggered when saving a file or
	opening the project.

	To configure a specific LSP client, use the `set_client_config`
	function, which supports a global object just like lsp-config.

	```lua
		{
			["rust_analyzer"] = { -- the lsp-config client name.
				client_config = {} -- the client raw lsp-config configuration for this client.
				resolver_config = { -- the config for this module.
					aliases = {} -- An array of aliases for the file-name prefixes.
				}
			}
		}
	```

	After you set the config, do use the provided `reload_config` method,
	which finds all the files and reloads them, this should only be used
	by a start script, never to reload a single file.
--]]

local M = {}

local Path = require("plenary.path")
local Toml = require("toml")
local ScanDir = require("plenary.scandir")
local Merge = require("utils.deep_merge")
local Log = require("utils.logs").for_module("workspace-lsp-config")
local Coroutines = require("utils.corroutines")


--- @class ResolverConfig
--- @field aliases string[]

--- @class ClientConfig
--- @field client_config table?
--- @field resolver_config ResolverConfig?

--- @type table<string, ClientConfig>
local client_config = {}
--- @type table<string, integer[]>
local lsp_buffers = {}


--- @param target_alias string
--- @return string?
local function match_client_ident(target_alias)
	local fallback_base_name = nil

	for name, config in pairs(client_config) do
		if target_alias == name then
			fallback_base_name = name
		end

		local aliases = config.resolver_config and config.resolver_config.aliases or nil

		if aliases == nil then
			goto continue
		end

		for _, alias in ipairs(aliases) do
			if alias == target_alias then
				return name
			end
		end

	    ::continue::
	end

	if fallback_base_name ~= nil then
		return fallback_base_name
	end


	for client in vim.lsp.get_clients() do
		if client.name == target_alias then
			return client.name
		end
	end

	return nil
end


--- @param file string
--- @param setup boolean
--- @return string? -- returns the lsp name if successful.
local function reload_lsp_config(file, setup)
	local LspConfig = require('lspconfig')

	local base = Path:new(file)
	local base_string = tostring(base)
	local lang = base:make_relative():match("^(.-)%-lsp%-config%.toml$")

	if not lang then
		Log:error("Could not infer language from: " .. base_string)
		return
	end

	local lsp_name = match_client_ident(lang)
	if lsp_name == nil then
		Log:error("No matching client alias for: " .. lang)
		return
	end

	local ok, parsed = pcall(function()
		return Toml.parse(base:read(), {})
	end)
	if not ok then
		Log:error("Failed to parse: " .. base_string)
		return
	end

	local config_with_setup = vim.deepcopy(parsed)
	Merge.deep_merge(config_with_setup, client_config[lsp_name].client_config)
	Log:debug("Config for '" .. lsp_name .. "' inferred as " .. vim.inspect(config_with_setup))

	if setup then
		LspConfig[lsp_name].setup(config_with_setup)
		Log:info(
			"Overriden LSP setup for '" .. lsp_name .. "' with file " .. base_string
		)
		return lsp_name
	end

	for _, client in ipairs(vim.lsp.get_clients({ name = lsp_name })) do
		local attached_buffers = {}
		for bufnr, _ in pairs(client.attached_buffers or {}) do
			vim.lsp.buf_detach_client(bufnr, client.id)
			table.insert(attached_buffers, bufnr)
		end

		client:stop(false)
		Log:debug("'" .. lsp_name .. "' has stopped.")

		local replaced_client_config = vim.deepcopy(client.config)
		replaced_client_config.root_dir = vim.fn.getcwd()
		Merge.merge_replace(replaced_client_config, config_with_setup)

		local new_client_id = vim.lsp.start(replaced_client_config)

		--- @param client_id integer
		--- @param bufnrs integer[]
		local function attach_buffers(client_id, bufnrs)
			local new_client = vim.lsp.get_client_by_id(client_id)

			if new_client == nil then
				Log:error("Started client could not be found, start halted.")
				return
			end

			while not new_client.initialized do
				Coroutines.sleep(100)
			end

			for _, bufnr in ipairs(bufnrs) do
				if vim.api.nvim_buf_is_loaded(bufnr) then
					vim.lsp.buf_attach_client(bufnr, new_client.id)
				end
			end
		end

		vim.defer_fn(function ()
			-- NOTE: pass as parameters because it's a corroutine
			coroutine.wrap(attach_buffers)(new_client_id, attached_buffers)
		end, 100)
	end

	Log:info(
		"Overriden LSP config for '" .. lsp_name .. "' with file " .. base_string
	)

	return lsp_name
end


vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*-lsp-config.toml",
	desc = "Reload LSP config on saving lsp-config.toml files",

	callback = function(args)
		local file_path = args.file or args.match
		if file_path ~= nil then
			Log:debug("Detected save for " .. file_path)
			reload_lsp_config(file_path, false)
		end
	end
})


vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client ~= nil then
			Log:debug(
				"'"
				.. client.name
				.. "' attached to buffer "
				.. args.buf
				.. " with config "
				.. vim.inspect(client.config)
			)
		end
	end
})

--- @param config table<string, ClientConfig>?
--- @return nil
function M.setup(config)
	client_config = config or {}
	-- TODO: refactor to be config and file oriented at same time
	local loaded_file_langs = {}

	local files = ScanDir.scan_dir(vim.fn.getcwd(), {
		search_pattern = ".*%-lsp%-config%.toml$",
		depth = 1
	})

	vim.schedule(function ()
		for _, file in ipairs(files) do
			local lang = reload_lsp_config(file, true)

			if lang ~= nil then
				table.insert(loaded_file_langs, lang)
			end
		end


		local LspConfig = require('lspconfig')

		for name, client in pairs(client_config) do
			for _, already_loaded in ipairs(loaded_file_langs) do
				if name == already_loaded then
					goto continue_outer
				end
			end

			LspConfig[name].setup(client.client_config or {})

			::continue_outer::
		end
	end)
end

return M
