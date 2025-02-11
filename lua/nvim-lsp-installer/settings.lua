local path = require "nvim-lsp-installer.path"

local M = {}

---@class LspInstallerSettings
local DEFAULT_SETTINGS = {
    -- A list of servers to automatically install. Example: { "rust_analyzer", "sumneko_lua" }
    ensure_installed = {},
    -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
    automatic_installation = false,
    -- To use along automatic_installation list of servers to ignore if automatically installating servers.
    avoid_installation = {},
    ui = {
        icons = {
            -- The list icon to use for installed servers.
            server_installed = "◍",
            -- The list icon to use for servers that are pending installation.
            server_pending = "◍",
            -- The list icon to use for servers that are not installed.
            server_uninstalled = "◍",
        },
        keymaps = {
            -- Keymap to expand a server in the UI
            toggle_server_expand = "<CR>",
            -- Keymap to install the server under the current cursor position
            install_server = "i",
            -- Keymap to reinstall/update the server under the current cursor position
            update_server = "u",
            -- Keymap to check for new version for the server under the current cursor position
            check_server_version = "c",
            -- Keymap to update all installed servers
            update_all_servers = "U",
            -- Keymap to check which installed servers are outdated
            check_outdated_servers = "C",
            -- Keymap to uninstall a server
            uninstall_server = "X",
        },
    },

    -- The directory in which to install all servers.
    install_root_dir = path.concat { vim.fn.stdpath "data", "lsp_servers" },

    pip = {
        -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
        -- and is not recommended.
        --
        -- Example: { "--proxy", "https://proxyserver" }
        install_args = {},
    },

    -- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
    -- debugging issues with server installations.
    log_level = vim.log.levels.INFO,

    -- Limit for the maximum amount of servers to be installed at the same time. Once this limit is reached, any further
    -- servers that are requested to be installed will be put in a queue.
    max_concurrent_installers = 4,
}

M._DEFAULT_SETTINGS = DEFAULT_SETTINGS
M.current = M._DEFAULT_SETTINGS

---@param opts LspInstallerSettings
function M.set(opts)
    M.current = vim.tbl_deep_extend("force", M.current, opts)
    M.setup_avoid()
end

-- Transforms avoid server list into a table for better access in middleware
function M.setup_avoid()
    if #M.current.avoid_installation > 0 then
        local avoid_tbl = {}
        for _, value in ipairs(M.current.avoid_installation) do
            avoid_tbl[value] = true
        end
        M.current.avoid_installation = avoid_tbl
    end
end

-- Whether the new .setup() function has been called.
-- This will temporarily be used as a flag to toggle certain behavior.
M.uses_new_setup = false

return M
