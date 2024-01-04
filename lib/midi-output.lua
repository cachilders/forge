include('lib/output')

MidiOutput = {
  name = '',
  reference = nil -- the connection
}

setmetatable(MidiOutput, { __index = Output })

function MidiOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MidiOutput:play_note(note)
  print('Playing note '..note:get('quantized_note_number')..' on MIDI device: '..self.name)
end

