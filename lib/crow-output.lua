include('lib/output')

CrowOutput = {}

setmetatable(CrowOutput, { __index = Output })

function CrowOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CrowOutput:play_note(note)
  print('Playing note '..note:get('quantized_note_number')..' on Crow')
end

