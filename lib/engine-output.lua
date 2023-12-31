include('lib/output')
engine.name = 'PolyPerc'

EngineOutput = Output:new()

function EngineOutput:play_note(note)
  local hz = musicutil.note_num_to_freq(note:get('quantized_note_number') or note:get('initial_note_number'))

  engine.amp(1) -- TODO: velocity options
  engine.hz(hz)
end

