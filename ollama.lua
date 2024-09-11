local cmp = require "cmp"
local job = require "plenary.job"

local ollama_src = {}

function ollama_src:get_debug_name()
	return "Ollama"
end

function ollama_src:complete(params, callback)
	local cursor = params.context.cursor
	local prev_lines = vim.api.nvim_buf_get_lines(params.context.bufnr, 0, cursor.line, true)
	local current_line = params.context.cursor_line
	local ends_with_space = current_line:match("%s$") ~= nil
	local src = table.concat(prev_lines, "\n") .. (current_line):gsub("%s$", "")

	job:new({
		command = "curl",
		args = {
			"http://127.0.0.1:11434/api/generate",
			"-d",
			vim.fn.json_encode({
				model = "deepseek-coder:6.7b",
				prompt = src,
				stream = false,
				raw = true,
				options = { stop = { "\n" } },
			}),
		},
		on_exit = vim.schedule_wrap(function(response)
			local response_text = table.concat(response:result(), "\n")
			local response_json = vim.fn.json_decode(response_text)
			local code = response_json["response"]
			if ends_with_space then
				code = code:gsub("^%s+", "")
			end
			callback({ { label = code } })
		end),
	}):start()
end

cmp.register_source("ollama", ollama_src)
