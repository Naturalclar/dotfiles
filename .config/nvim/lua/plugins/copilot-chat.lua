return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    opts = {
      model = "claude-3.7-sonnet-thought",
      -- See Configuration section for options
      window = {
        layout = "vertical",
        width = 0.3, -- fractional width of parent, or absolute width in columns when > 1
        height = 1, -- fractional height of parent, or absolute height in rows when > 1
      },
      prompts = {
        Explain = {
          prompt = "> /COPILOT_EXPLAIN\n\nWrite an explanation for the selected code as paragraphs of text.",
        },
        Review = {
          prompt = "> /COPILOT_REVIEW\n\nReview the selected code.",
        },
        Fix = {
          prompt = "> /COPILOT_GENERATE\n\nThere is a problem in this code. Rewrite the code to show it with the bug fixed.",
        },
        Optimize = {
          prompt = "> /COPILOT_GENERATE\n\nOptimize the selected code to improve performance and readability.",
        },
        Docs = {
          prompt = "> /COPILOT_GENERATE\n\nPlease add documentation comments to the selected code.",
        },
        Tests = {
          prompt = "> /COPILOT_GENERATE\n\nPlease generate tests for my code.",
        },
        Commit = {
          prompt = "> #git:staged\n\nWrite commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
        },
      },
    },
    agents = { -- agent-specific configurations
      perplexityai = {
        model = "llama-3.1-sonar-huge-128k-online", -- agent-specific model
      },
    }, -- See Commands section for default commands if you want to lazy load on them
    keys = {
      {
        "<leader>cca",
        ":CopilotChatAgents<CR>",
        { noremap = true, silent = true },
        desc = "CopilotChat - list agents",
      },
      { "<leader>cco", ":CopilotChatOpen<CR>", { noremap = true, silent = true }, desc = "CopilotChat - Open" },
      {
        "<leader>ccm",
        ":CopilotChatModel<CR>",
        { noremap = true, silent = true },
        desc = "CopilotChat - Select Models",
      },
      {
        "<leader>ccp",
        ":CopilotChatPrompts<CR>",
        { noremap = true, silent = true },
        desc = "CopilotChat - Prompt actions",
      },
    },
  },
}
