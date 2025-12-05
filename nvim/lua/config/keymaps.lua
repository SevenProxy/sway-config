local ToggleTerm_Terminal = require("toggleterm.terminal").Terminal

for i = 1, 9 do
	local terminal = ToggleTerm_Terminal:new({
		count = i,
		direction = "horizontal",
		hidden = true
	})

	vim.keymap.set(
		{ "n", "t" },
		"<C-t>" .. i,
		function()
			terminal:toggle()
		end,
		{ desc = "Toggle Terminal " .. i }
	)
end

vim.keymap.set(
	{ "n", "t" },
	-- CTRL + E (Open Workspace)
	"<C-e>",
	"<cmd>Neotree toggle<CR>",
	{ desc = "Toggle Explorer" }
)
