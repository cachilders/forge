-- root_num integer MIDI note number (0-127) defining the key.
-- scale_type string String defining scale type. Not all scales are supported; valid values are "Major" (or "Ionian"), "Natural Minor" (or "Minor" or "Aeolian"), "Harmonic Minor", "Melodic Minor", "Dorian", "Phrygian", "Lydian", "Mixolydian", or "Locrian".

Quantizer = {
  note_snap = true,
  root = 60,
  scale = {},
  scale_type = 'Major',
  snap_to = 4,
  step_snap = true
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

function Quantizer:generate_scale(octaves)
  self.scale = m_util.generate_scale(self.root, self.scale_type, octaves)
end

function Quantizer:snap_note(note)
  if self.note_snap then
    local quantized_note_number = m_util.snap_note_to_array(note:get('raw_note_number'), self.scale)
    note:set('quantized_note_number', quantized_note_number)
  end
  
  if self.step_snap then
    note:set('x_pos', note:get('x_pos') + (note:get('x_pos') % self.snap_to))
  end
end
