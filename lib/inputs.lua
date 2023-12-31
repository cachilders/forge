Inputs = {
  inputs = {}
}

function Inputs:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Inputs:add(input)
  table.insert(self.inputs, input)
end

function Inputs:dirty()
  local dirty = true
  for i = 1, #self.inputs do
    if dirty and self.inputs[i]:get('dirty') == false then
      dirty = false
    end
  end

  return dirty
end

function Inputs:_reset_dirty()
  for i = 1, #self.inputs do
    self.inputs[i]:set('dirty', false)
  end
end

function Inputs:poll()
  if self:dirty() then
    local input_values = {}

    for i = 1, #self.inputs do
      input_values[i] = self.inputs[i].value
    end

    self:_reset_dirty()

    return input_values
  end

  return nil
end
