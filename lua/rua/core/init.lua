require("rua.core.options")
require("rua.core.keymaps")
require("rua.core.usercmd")
require("rua.core.autocmd")

if vim.g.neovide then
  require("rua.core.neovide")
end

-- To appropriately highlight codefences returned from denols, you will
-- need to augment vim.g.markdown_fenced languages in your init.lua. Example:
vim.g.markdown_fenced_languages = {
  "ts=typescript",
}
