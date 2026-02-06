local function get_jdtls()
  -- Mason typically installs to ~/.local/share/nvim/mason
  -- It's safer to use the data path if $MASON isn't explicitly set in your shell
  local mason_path = vim.fn.stdpath 'data' .. '/mason'
  local jdtls_path = mason_path .. '/packages/jdtls'

  -- Find the launcher JAR
  local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

  -- Detect OS
  local SYSTEM
  if vim.fn.has 'mac' == 1 then
    SYSTEM = 'mac'
  elseif vim.fn.has 'unix' == 1 then
    SYSTEM = 'linux'
  else
    SYSTEM = 'win'
  end

  local config = jdtls_path .. '/config_' .. SYSTEM
  local lombok = jdtls_path .. '/lombok.jar'

  return launcher, config, lombok
end

local function get_bundles()
  local mason_path = vim.fn.stdpath 'data' .. '/mason'
  -- Note: Fixed the typo 'adpter' to 'adapter'
  local debug_path = mason_path .. '/packages/java-debug-adapter'
  
  local bundles = {
    vim.fn.glob(debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', 1),
  }
  
  -- Add Java Test bundles if you have 'java-test' installed via Mason
  local test_path = mason_path .. '/packages/java-test'
  vim.list_extend(bundles, vim.split(vim.fn.glob(test_path .. '/extension/server/*.jar', 1), "\n"))
  
  return bundles
end

-- IMPORTANT: This must return a table for Lazy.nvim
return {
  'mfussenegger/nvim-jdtls',
  ft = 'java',
  config = function()
    local launcher, config, lombok = get_jdtls()
    local bundles = get_bundles()
    
    -- Workspace directory (jdtls needs a place to store project data)
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = vim.fn.stdpath('data') .. '/site/java/workspace-root/' .. project_name

    local jdtls_config = {
      cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-javaagent:' .. lombok,
        '-jar', launcher,
        '-configuration', config,
        '-data', workspace_dir,
      },
      root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
      init_options = {
        bundles = bundles,
      },
    }
    
    -- Start the server
    require('jdtls').start_or_attach(jdtls_config)
  end
}
