Output = {
  pulse_time = .5
}

function Output:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Output:config(pulse_time)
  self.pulse_time = pulse_time
end

function Output:get(k)
  return self[k]
end

function Output:set(k, v)
  self[k] = v
end

function Output:play_note(note)
  if parameters.quantizer_note_snap and note:get('quantized_note_number') then
    print('Quantized Note number '.. note:get('quantized_note_number'))
  else
    print('Unquantized Note number '.. note:get('initial_note_number'))
  end
end
