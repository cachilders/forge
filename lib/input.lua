Input = {
  dirty = false,
  id = '',
  name = '',
  source = nil,
  type = '',
  value = nil
}

function Input:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Input:get(k)
  return self[k]
end

function Input:set(k, v)
  self[k] = v
end

function Input:update(v)
  self.value = v
  self.dirty = true
end
