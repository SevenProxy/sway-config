local package_path_str = "/home/proxy/.luarocks/share/lua/5.4/?.lua;/home/proxy/.luarocks/share/lua/5.4/?/init.lua;/usr/share/lua/5.4/?.lua;/usr/share/lua/5.4/?/init.lua"
local package_cpath_str = "/home/proxy/.luarocks/lib/lua/5.4/?.so;/usr/lib/lua/5.4/?.so"

if not string.find(package.path, package_path_str, 1, true) then
	package.path = package.path .. ";" .. package_path_str
end

if not string.find(package.cpath, package_cpath_str, 1, true) then
	package.cpath = package.cpath .. ";" .. package_cpath_str
end

vim.cmd [[
	filetype plugin indent on
]]

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
