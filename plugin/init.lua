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
local augroup_id = vim.api.nvim_create_augroup("nvim-classy", { clear = true })
vim.api.nvim_create_user_command("ClassyConceal", function()
  if classy.opts.filetypes[vim.bo.filetype] == nil then
    vim.api.nvim_err_writeln "nvim-classy: invalid filetype"
    return
  end
  classy.conceal_classes(ns_id)
  vim.api.nvim_create_autocmd("BufModifiedSet", {
    pattern = "*",
    group = augroup_id,
    callback = function()
      classy.conceal_classes(ns_id)
    end,
  })
end, {})
vim.api.nvim_create_user_command("ClassyUnconceal", function()
  if classy.opts.filetypes[vim.bo.filetype] == nil then
    vim.api.nvim_err_writeln "nvim-classy: invalid filetype"
    return
  end
  local autocmds = vim.api.nvim_get_autocmds { group = augroup_id }
  local cmd_id = autocmds[1].id
  vim.api.nvim_del_autocmd(cmd_id)
  classy.unconceal_classes(ns_id)
end, {})

if classy.opts.auto_start then
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    group = augroup_id,
    callback = function()
      if classy.opts.filetypes[vim.bo.filetype] == nil then
        return
      end
      vim.cmd "ClassyConceal"
    end,
  })
end
