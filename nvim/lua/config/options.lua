local merge = require("utils.deep_merge")

-- VIM OPTIONS

local vim_options = {
  opt = {
    expandtab = false,
    tabstop = 4,
    shiftwidth = 4,
    softtabstop = 4,
  },

  g = {
    autoformat = false,
    mapleader = ",",

    did_ident_on = 1,
    did_load_filetypes = 1,
  },
}

merge.deep_merge(vim, vim_options)

-- MODULE OPTIONS

-- NOTE: refer to each module documentation.

require("config.modules.workspace_lsp_config").setup({
	rust_analyzer = {
		resolver_config = {
			aliases = { "rust" },
		},
	},

	-- ADEED GO LANGUAGE
	gopls = {
		resolver_config = {
			aliases = { "go" },
		},
		client_config = {
			settings = {
				gopls = {
					gofumpt = true,
					analyses = {
						unusedparams = true,
					}
				}
			}
		}
	},

	just = {},
	dockerls = {},
	terraformls = {
		client_config = {
			cmd = { "terraform-ls", "serve" },
			filetypes = { "terraform", "terraform-vars", "tfvars", "tf", "hcl" },
		},
	},
})
