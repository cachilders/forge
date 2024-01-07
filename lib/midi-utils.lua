function midi_panic()
  for note = 0, 127 do
    for ch = 1, 16 do
      for id, connection in pairs(midi_output:get('connections')) do
        connection:note_off(note, 0, ch)
      end
    end
  end
end
