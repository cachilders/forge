Quantizer = {
  octaves = 3,
  root = 48,
  scale = {},
  scale_type = 'Major',
  snap_to = 4,
}

function Quantizer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Quantizer:get(k)
  return self[k]
end

function Quantizer:set(k, v)
  self[k] = v
end

function Quantizer:generate_scale()
  self.scale = musicutil.generate_scale(self.root, self.scale_type, self.octaves)
end

function Quantizer:snap_note(note)
  if parameters.quantizer_note_snap then
    local quantized_note_number = musicutil.snap_note_to_array(note:get('initial_note_number'), self.scale)
    note:set('quantized_note_number', quantized_note_number)
  end
  
  if parameters.quantizer_step_snap then
    note:set('x_pos', note:get('x_pos') + (note:get('x_pos') % self.snap_to))
  end
end
