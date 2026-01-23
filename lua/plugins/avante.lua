return {
  "yetone/avante.nvim",
  opts = {
    provider = "ark",
    providers = {
      ark = {
        __inherited_from = "openai",
        api_key_name = "ARK_API_KEY",
        endpoint = "https://ark.cn-beijing.volces.com/api/coding/v3",
        model = "ark-code-latest",
        max_tokens = 224000,
      },
      openrouter = {
        __inherited_from = "openai",
        api_key_name = "OPENROUTER_API_KEY",
        endpoint = "https://openrouter.ai/api/v1",
        model = "google/gemini-2.5-flash",
        max_tokens = 64000,
      },
      deepseek = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        -- model = "deepseek-reasoner",
        model = "deepseek-chat",
        max_tokens = 64000,
      },
    },
    web_search_engine = {
      provider = "google", -- tavily, serpapi, google, kagi, brave, or searxng
      -- proxy = nil, -- proxy support, e.g., http://127.0.0.1:7890
    },
  },
}
