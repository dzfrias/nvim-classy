if vim.fn.has "nvim-0.7.0" ~= 1 then
  vim.api.nvim_err_writeln "nvim-classy requires at least nvim-0.7.0."
  return
end

if vim.g.loaded_classy == 1 then
  return
end
vim.g.loaded_classy = 1

local classy = require "classy"
local ns_id = vim.api.nvim_create_namespace "nvim-classy"
vim.api.nvim_create_user_command("ClassyConceal", function()
  classy.conceal_classes(ns_id)
end, {})
vim.api.nvim_create_user_command("ClassyUnconceal", function()
  classy.unconceal_classes(ns_id)
end, {})
