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
  -- DO NOTE STUFF
end
