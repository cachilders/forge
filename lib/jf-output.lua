include('lib/output')

JFOutput = {}

setmetatable(JFOutput, { __index = Output })

function JFOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function JFOutput:play_note(note)
  print('Playing note '..note:get('quantized_note_number')..' on Just Friends')
end

