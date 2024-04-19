local logger = {}
logger._firstwrite = true

local writeline = function(type, message)
  local filemode = 'a'

  if (logger._firstwrite) then
    filemode = 'w'
    logger._firstwrite = false
  end

  local file = io.open('run.log', filemode)
  io.output(file)
  io.write(string.format('[%s][%s] %s\n', os.date('%c'), type, message))
  io.close()
end

logger.log = function(message) writeline('log', message) end
logger.warn = function(message) writeline('warn', message) end
logger.error = function(message) writeline('error', message) end

return logger
