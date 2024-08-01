local M

local XDG_CONFIG_HOME = os.getenv("XDG_CONFIG_HOME") ~= nil
    and os.getenv("XDG_CONFIG_HOME")
  or (os.getenv("HOME") ~= nil and os.getenv("HOME") .. "/.config" or nil)

local XDG_DATA_HOME = os.getenv("XDG_DATA_HOME") ~= nil
    and os.getenv("XDG_DATA_HOME")
  or (os.getenv("HOME") ~= nil and os.getenv("HOME") .. "/.local/share" or nil)

---@param type string
M.get_xdg_home = function(type)
  if type == "config" then
    return XDG_CONFIG_HOME
  end

  if type == "data" then
    return XDG_DATA_HOME
  end
end

return M
