local M = {}

local language_extensions = {
  python = "py",
  julia = "jl",
  r = "r",
  R = "r",
  bash = "sh",
}

local language_names = {
  python3 = "python",
}

-- Locations to look for the language string, ordered by priority.
local language_locations = {
  { path = { "kernelspec", "language" } },
  { path = { "kernelspec", "name" }, map = language_names },
  { path = { "jupytext", "main_language" } },
  { path = { "language_info", "name" } },
}

local function dig(tbl, path)
  local node = tbl
  for _, key in ipairs(path) do
    if type(node) ~= "table" then
      return nil
    end
    node = node[key]
  end
  return node
end

M.get_ipynb_metadata = function(filename, metadata_language_fields)
  local metadata = vim.json.decode(io.open(filename, "r"):read "a")["metadata"]

  -- User-supplied fields are appended at the end (least priority).
  local locations = vim.deepcopy(language_locations)
  for _, path in ipairs(metadata_language_fields or {}) do
    table.insert(locations, { path = path })
  end

  local language
  for _, loc in ipairs(locations) do
    local value = dig(metadata, loc.path)
    if value ~= nil and loc.map then
      value = loc.map[value]
    end
    if value then
      language = value
      break
    end
  end

  local extension = language_extensions[language]

  return { language = language, extension = extension }
end

M.get_jupytext_file = function(filename, extension)
  if extension == nil then
    error("Could not determine a jupytext file extension for " .. filename)
  end
  local fileroot = vim.fn.fnamemodify(filename, ":r")
  return fileroot .. "." .. extension
end

M.get_ipynb_file = function(filename)
  local fileroot = vim.fn.fnamemodify(filename, ":r")
  return fileroot .. ".ipynb"
end

M.check_key = function(tbl, key)
  for tbl_key, _ in pairs(tbl) do
    if tbl_key == key then
      return true
    end
  end

  return false
end

return M
