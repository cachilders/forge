include('lib/input')

CrowInput = {
  type = 'crow'
}

setmetatable(CrowInput, { __index = Input })

function CrowInput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CrowInput:init()
  if self.source then
    self.source.stream = function(v) self:update(v) end
  end
end
