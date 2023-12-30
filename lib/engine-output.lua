include('lib/output')
engine.name = 'PolyPerc'

EngineOutput = Output:new()

function EngineOutput:play_note(note)
  local hz = m_util.note_num_to_freq(note:get('quantized_note_number') or note:get('raw_note_number'))

  engine.amp(1) -- TODO: velocity options
  engine.hz(hz)
end

