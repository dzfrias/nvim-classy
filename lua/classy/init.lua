local M = {}

local config = require "classy.config"
local ts_utils = require "nvim-treesitter.ts_utils"

local opts = config.get()
local extmarks = {}
local ns_id = vim.api.nvim_create_namespace "nvim-classy"

local function execute_query(lang)
  local query_string = opts.filetypes[lang]
  if query_string == nil then
    vim.api.nvim_err_writeln "nvim-classy: invalid filetype"
    return nil
  end
  local query = vim.treesitter.query.parse(lang, query_string)
  return query
end

local function get_classes(bufnr)
  bufnr = bufnr or 0
  local lang = vim.bo.filetype
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local syntax_tree = parser:parse()[1]
  local root = syntax_tree:root()

  local matches = execute_query(lang)
  if matches == nil then
    return nil
  end
  local classes = {}
  for _, captures, metadata in matches:iter_matches(root, bufnr) do
    local idx = vim.fn.index(matches.captures, "attr_value")
    if idx == -1 then
      vim.api.nvim_err_writeln "nvim-classy: no @attr_value capture supplied"
      goto continue
    end
    local start_line, start_col
    local end_line, end_col

    local attr_metadata = metadata[idx + 1]
    if attr_metadata ~= nil then
      start_line, start_col, end_line, end_col = unpack(attr_metadata.range)
    else
      start_line, start_col, _ = captures[idx + 1]:start()
      end_line, end_col, _ = captures[idx + 1]:end_()
    end
    if start_line == end_line and end_col - start_col < opts.min_length then
      goto continue
    end
    table.insert(classes, {
      col = { start_col, end_col },
      line = { start_line, end_line },
      id = captures[idx + 1]:id(),
    })
    ::continue::
  end

  return classes
end

local function set_conceal_extmark(bufnr, location)
  return vim.api.nvim_buf_set_extmark(
    bufnr,
    ns_id,
    location.line[1],
    location.col[1],
    {
      conceal = opts.conceal_char,
      hl_group = opts.hl_group,
      end_row = location.line[2],
      end_col = location.col[2],
    }
  )
end

function M.toggle_class_hide()
  local node = ts_utils.get_node_at_cursor()
  if node == nil then
    return
  end
  local node_id = node:id()
  if extmarks[node_id] == nil then
    local classes = get_classes()
    if classes == nil then
      return nil
    end
    for _, class in ipairs(classes) do
      if class.id == node_id then
        extmarks[class.id] = set_conceal_extmark(0, class)
        return
      end
    end
  else
    vim.api.nvim_buf_del_extmark(0, ns_id, extmarks[node_id])
    extmarks[node_id] = nil
    return
  end
  vim.api.nvim_err_writeln "nvim-classy: no node at cursor found"
end

function M.conceal_classes()
  local bufnr = vim.fn.bufnr()
  local classes = get_classes()
  if classes == nil then
    return
  end

  M.unconceal_classes()
  for _, class in ipairs(classes) do
    extmarks[class.id] = set_conceal_extmark(bufnr, class)
  end
end

function M.unconceal_classes()
  -- Clear all conceals in buffer
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  extmarks = {}
end

function M.setup(user_config)
  config.setup(user_config)
  opts = config.get()
end

M.opts = opts

return M
