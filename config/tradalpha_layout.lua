-- Layout configuration for the TradeAlpha workspace
--
-- This file can be extended in future to describe pane geometry, tab titles,
-- and command lists programmatically. For now it simply exposes constants that
-- other modules may import for consistency.
--
-- Example structure (not yet used by creation code):
--   return {
--     workspace = "trade-alpha",
--     tabs = {
--       { title = "TradeAlpha1", panes = {{direction="Bottom", size=0.6, cwd=M.project_root, command=
--         commands.wrap(M.opencode_command)}} },
--       …
--     }
--   }

local M = {}

M.workspace_name = "trade-alpha"
M.display_name  = "TradeAlpha"
M.port          = 11434 -- default Ollama port

return M
