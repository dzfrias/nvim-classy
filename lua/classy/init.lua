local M = {}

local config = require "classy.config"
local opts = config.get()

local function execute_query(lang)
  local query_string = opts.filetypes[lang]
  if query_string == nil then
    vim.api.nvim_err_writeln "nvim-classy: invalid filetype"
    return nil
  end
  local query = vim.treesitter.query.parse_query(lang, query_string)
  return query
end

local function get_classes(bufnr, lang)
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local syntax_tree = parser:parse()[1]
  local root = syntax_tree:root()
  local matches = execute_query(lang)
  if matches == nil then
    return nil
  end

  local classes = {}
  for _, captures, _ in matches:iter_matches(root, bufnr) do
    local idx = vim.fn.index(matches.captures, "attr_value")
    if idx == -1 then
      vim.api.nvim_err_writeln "nvim-classy: no @attr_value capture supplied"
      return nil
    end
    local start_line, start_col, _ = captures[idx + 1]:start()
    local end_line, end_col, _ = captures[idx + 1]:end_()
    table.insert(
      classes,
      { col = { start_col, end_col }, line = { start_line, end_line } }
    )
  end

  return classes
end

local function set_conceal_extmarks(bufnr, ns_id, location)
  vim.api.nvim_buf_set_extmark(
    bufnr,
    ns_id,
    location.line[1],
    location.col[1],
    { conceal = ".", end_row = location.line[2], end_col = location.col[2] }
  )
end

function M.conceal_classes(ns_id)
  local bufnr = vim.fn.bufnr()
  local classes = get_classes(bufnr, vim.bo.filetype)
  if classes == nil then
    return
  end

  for _, class in ipairs(classes) do
    set_conceal_extmarks(bufnr, ns_id, class)
  end
end

function M.unconceal_classes(ns_id)
  -- Clear all conceals in buffer
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

function M.setup(user_config)
  config.setup(user_config)
  opts = config.get()
end

return M
