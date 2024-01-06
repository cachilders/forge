Outputs = {
  outputs = {}
}

function Outputs:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Outputs:get(k)
  return self[k]
end

function Outputs:set(k, v)
  self[k] = v
end

function Outputs:add(output)
  table.insert(self.outputs, output)
end

function Outputs:play_note(note)
  for i = 1, #self.outputs do
    local output = self.outputs[i]
    output:play_note(note)
  end
end
