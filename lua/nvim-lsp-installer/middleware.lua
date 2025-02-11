local util = require "lspconfig.util"
local servers = require "nvim-lsp-installer.servers"
local settings = require "nvim-lsp-installer.settings"

local M = {}

---@param t1 table
---@param t2 table
local function merge_in_place(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k]) == "table" and not vim.tbl_islist(t1[k]) then
                merge_in_place(t1[k], v)
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function M.register_lspconfig_hook()
    util.on_setup = util.add_hook_before(util.on_setup, function(config)
        local ok, server = servers.get_server(config.name)
        if ok then
            if server:is_installed() then
                merge_in_place(config, server._default_options)
            end
            if settings.current.automatic_installation and not settings.current.avoid_installation[config.name] and not server:is_installed() then
                server:install()
            end
        end
    end)
end

return M
