local function get_jdtls()
  -- Define base path for Mason packages
  local mason_path = vim.fn.expand '$MASON'
  local jdtls_path = mason_path .. '/packages/jdtls'

  -- Get the JAR file that launches the language server
  local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

  local SYSTEM = 'linux'

  -- Get the config and lombok paths
  local config = jdtls_path .. '/config_' .. SYSTEM
  local lombok = jdtls_path .. '/lombok.jar'

  return launcher, config, lombok
end

local function get_bundles()
  local mason_path = vim.fn.expand '$MASON'
  local jdtls_path = mason_path .. '/packages/java-debug-adpter'

  local bundles = {
    vim.fn.glob(jdtls_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', true),
  }

  local java_test = mason_path .. '/packages/java-test'
  vim.list_extend(bundles, vim.split(vim.fn.glob(java_test .. '/extension/server/*.jar', true), '\n'))

  return bundles
end

local function get_workspace()
  local home = os.getenv 'HOME'
  local workspace_path = home .. '/Projects'

  local project_name = vim.fn.fnamemodify(vim.fn.getcw(), ':p:h:t')
  local workspace_dir = workspace_path .. project_name
  return workspace_dir
end

local function java_keymaps()
  vim.cmd "command! -buffer -nargs=? -complete=custom;v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)"
  vim.cmd "command! = buffer JdtUpdateConfig lua require('jdtls').update_project_config()"
end

return {}
