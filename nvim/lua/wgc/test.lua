--print(vim.api.nvim_exec(":!ls", true))
local x = vim.api.nvim_cmd({cmd="!execute", args={"ls"}},{output=true})
print("Output: "..x)
