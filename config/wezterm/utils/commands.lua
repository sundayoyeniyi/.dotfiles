local M = {}

function M.zsh(command)
  return { "/bin/zsh", "-lc", command }
end

function M.wrap(command)
  return command
    .. "\n"
    .. "status=$?\n"
    .. "if [ $status -ne 0 ]; then\n"
    .. "  echo\n"
    .. "  echo \"Command failed with exit code: $status\"\n"
    .. "fi\n"
    .. "exec ${SHELL:-/bin/zsh} -l\n"
end

function M.ollama_serve()
  return [[
if ! command -v ollama >/dev/null 2>&1; then
  echo "ollama is not installed."
  exec ${SHELL:-/bin/zsh} -l
fi

if command -v curl >/dev/null 2>&1 && curl --silent --fail http://127.0.0.1:11434/api/tags >/dev/null; then
  echo "Ollama is already running on port 11434."
  exec ${SHELL:-/bin/zsh} -l
fi

exec ollama serve
]]
end

return M
