include('lib/output')

WSlashSynthOutput = {}

setmetatable(WSlashSynthOutput, { __index = Output })

function WSlashSynthOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WSlashSynthOutput:play_note(note)
  print('Playing note '..note:get('quantized_note_number')..' on W/ Syn')
end

