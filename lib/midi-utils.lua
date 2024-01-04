function init_midi_connections()
  for i=1, #parameters.midi_devices do
    connect__midi_device(i)
  end
end

function refresh_midi_connections()
  for i=1, #parameters.midi_devices do
    if parameters.midi_devices[i].connection == nil then 
      connect__midi_device(i)
    end
  end
end

function connect__midi_device(i)
  parameters.midi_devices[i].connection = midi.connect(parameters.midi_devices[i].id)
end

function midi_panic()
  for note = 0, 127 do
    for ch = 1, 16 do
      for i = 1, #parameters.midi_devices do
        parameters.midi_devices[i].connection:note_off(note, 0, ch)
      end
    end
  end
end
