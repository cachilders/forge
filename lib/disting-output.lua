include('lib/output')

DistingOutput = {}

setmetatable(DistingOutput, { __index = Output })

function DistingOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function DistingOutput:play_note(note)
  print('Playing note '..note:get('quantized_note_number')..' on Disting')
end

