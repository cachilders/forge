function init_midi_connections()
  for id, device in pairs(parameters.midi_devices) do
    if device ~= nil then
      connect__midi_device(id, device)
    end
  end
end

function refresh_midi_connections()
  for id, device in pairs(parameters.midi_devices) do
    if device ~= nil and device.connection == nil then 
      connect__midi_device(id, device)
    end
  end
end

function connect__midi_device(id, device)
  device.connection = midi.connect(id)
end

function midi_panic()
  for note = 0, 127 do
    for ch = 1, 16 do
      for id, device in pairs(parameters.midi_devices) do
        device.connection:note_off(note, 0, ch)
      end
    end
  end
end
