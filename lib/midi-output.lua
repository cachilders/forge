include('lib/output')

MidiOutput = {
  connections = {}
}

setmetatable(MidiOutput, { __index = Output })

function MidiOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MidiOutput:init()
  for id, device_name in pairs(parameters.midi_device_identifiers) do
    table.insert(self.connections, midi.connect(id))
  end
end

function MidiOutput:_connect_midi_device(id, device)
  self.connection = midi.connect(id)
end

function MidiOutput:play_note(note)
  local note_number = parameters.quantizer_note_snap and note:get('quantized_note_number') or note:get('initial_note_number')

  for i = 1, #self.connections do
    local connection = self.connections[i]
    if parameters.outputs.midi[connection.device.port] then
      ch = params:get('midi_device_'..connection.device.port..'_output_channel')
      clock.run(
        function()
          connection:note_on(note_number, 127, ch)
          clock.sleep(self.pulse_time)
          connection:note_off(note_number, 127, ch)
        end
      )
    end
  end
end

