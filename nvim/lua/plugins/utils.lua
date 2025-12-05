return {
	{
		"akinsho/toggleterm.nvim",
		config = true
	},
	--[[
	{
		"vyfor/cord.nvim",
		build = ":Cord update",
		config = function()
			require("cord").setup({
				timestamp = {
					enabled = true
				},
				buttons = {
					label = function(opts)
						return opts.repo_url and "View Repository" or nil
					end,
					url = function(opts)
						return opts.repo_url
					end
				}
			})
		end
	},
	]]--
	{
		"nvim-lua/plenary.nvim"
	},

	{
		"jonstoler/lua-toml",
		name = "toml",
		lazy = false,
	}
}
