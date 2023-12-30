Output = {}

function Output:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Output:get(k)
  return self[k]
end

function Output:set(k, v)
  self[k] = v
end

function Output:play_note(note)
  print('Quantized Note number '.. note:get('quantized_note_number'))
end
