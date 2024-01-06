include('lib/output')

MidiOutput = {
  devices = {}
}

setmetatable(MidiOutput, { __index = Output })

function MidiOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MidiOutput:init()
  for id, device in pairs(parameters.midi_devices) do
    print(id, device.name)
  end
end

function MidiOutput:play_note(note)
  local note_number = parameters.quantizer_note_snap and note:get('quantized_note_number') or note:get('initial_note_number')

  for id, device in pairs(parameters.midi_devices) do
    if device.enabled and device.connection then
      local connection, ch = device.connection, params:get('midi_device_'..id..'_output_channel')

      clock.run(
        function()
          print(note_number, ch, connection.note_on, id, device.name)
          connection:note_on(note_number, 127, ch)
          clock.sleep(self.pulse_time)
          connection:note_off(note_number, 127, ch)
        end
      )
    end
  end
end

