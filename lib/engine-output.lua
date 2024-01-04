include('lib/output')

engine.name = 'PolyPerc'

EngineOutput = {}

setmetatable(EngineOutput, { __index = Output })

function EngineOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function EngineOutput:play_note(note)
  local hz = musicutil.note_num_to_freq(note:get('quantized_note_number') or note:get('initial_note_number'))

  engine.amp(1) -- TODO: velocity options
  engine.hz(hz)
end

