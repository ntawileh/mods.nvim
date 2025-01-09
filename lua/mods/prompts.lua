local M = {}

---@type mods.Prompt[]
M.prompts = {
    {
        name = "Explain",
        prompt = [[
Can you explain the provided code in detail?
Specifically:
1. What is the purpose of this section?
2. How does it work step-by-step?
3. Are there any potential issues or limitations with this approach?
        ]],
    },
    {
        name = "Code Review",
        prompt = [[
Please review the provided code.
Consider:
1. Code quality and adherence to best practices
2. Potential bugs or edge cases
3. Performance optimizations
4. Readability and maintainability
5. Any security concerns
Suggest improvements and explain your reasoning for each suggestion.
        ]],
    },
    {
        name = "Optimize",
        prompt = [[
            The provided piece of code needs optimization.
Please suggest optimizations to improve its performance. For each suggestion, explain the expected improvement and any trade-offs.
]],
    },
    {
        name = "Unit Test",
        prompt = [[
Generate unit tests for the provided code:
Include tests for:
1. Normal expected inputs
2. Edge cases
3. Invalid inputs
]],
    },
    {
        name = "Summarize",
        prompt = [[
Can you summarize the content provided?

Answer in bullet points.
If the content is code, provide a brief explanation of what it does.
        ]],
    },
}

return M
