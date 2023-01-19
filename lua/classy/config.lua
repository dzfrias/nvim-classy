local M = {}

local defaults = {
  conceal_char = ".",
  conceal_hl_group = "",
  min_length = 0,
  auto_start = true,
  filetypes = {
    html = [[ ((attribute_name) @attr_name (#eq? @attr_name "class") (quoted_attribute_value (attribute_value) @attr_value)) ]],
    javascript = [[
      ;; jsx
      ((property_identifier) @attr_name (#eq? @attr_name "class") [(jsx_expression (_)?) (string)] @attr_value) ]],
    svelte = [[ ((attribute_name) @attr_name (#eq? @attr_name "class") (quoted_attribute_value (attribute_value) @attr_value)) ]],
  },
}

local config = vim.deepcopy(defaults)

M.validate = function(user_config)
  local to_validate, validated = {}, {}
  for key in pairs(user_config) do
    to_validate[key] = { user_config[key], type(defaults[key]) }
    validated[key] = user_config[key]
  end

  vim.validate(to_validate)
  return validated
end

M.get = function()
  return config
end

M.setup = function(user_config)
  user_config = user_config or {}
  local validated = M.validate(user_config)
  config = vim.tbl_extend("force", config, validated)
end

return M
