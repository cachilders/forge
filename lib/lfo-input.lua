include('lib/input')

LFOInput = {
  baseline = 'center',
  enabled = 1,
  depth = 1,
  mode = 'free',
  min = -5,
  max = 10,
  period = 1,
  phase = 0,
  ppqn = 96,
  offset = 0,
  reset_target = 'center',
  shape = 'sine'
}

setmetatable(LFOInput, { __index = Input })

function LFOInput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function LFOInput:init()
  self.source = LFO:add{
    action = function(scaled) self:update(scaled) end,
    baseline = self.baseline,
    enabled = self.enabled,
    depth = self.depth,
    max = self.max,
    min = self.min,
    mode = self.mode,
    offset = self.offset,
    period = 1,
    phase = self.phase,
    ppqn = self.ppqn,
    reset_target = self.reset_target,
    shape = self.shape
  }

  self.source:add_params(self.id, self.name, self.name)
  
  self.source:start()
end