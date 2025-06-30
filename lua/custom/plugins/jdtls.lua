local function get_jdtls()
  -- Define base path for Mason packages
  local mason_path = vim.fn.expand '$MASON'
  local jdtls_path = mason_path .. '/packages/jdtls'

  -- Get the JAR file that launches the language server
  local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

  -- Declare OS (adjust automatically if needed)
  local SYSTEM
  local uname = vim.loop.os_uname().sysname
  if uname == 'Linux' then
    SYSTEM = 'linux'
  else
    SYSTEM = 'win'
  end

  -- Get the config and lombok paths
  local config = jdtls_path .. '/config_' .. SYSTEM
  local lombok = jdtls_path .. '/lombok.jar'

  return launcher, config, lombok
end

local function get_bundles()
  local mason_path = vim.fn.expand '$MASON'
  local jdtls_path = mason_path .. '/packages/java-debug-adpter'

  local bundles = {
    vim.fn.glob(jdtls_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', 1),
  }
end
