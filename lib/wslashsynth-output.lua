include('lib/output')

WSlashSynthOutput = {}

setmetatable(WSlashSynthOutput, { __index = Output })

function WSlashSynthOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WSlashSynthOutput:init()
  crow.ii.wsyn.ar_mode(1)
end

function WSlashSynthOutput:play_note(note)
  if parameters.quantizer_note_snap == true then 
    crow.ii.wsyn.play_note((note:get('quantized_note_number')  - params:get('root'))/ 12, 5)
  else
    crow.ii.wsyn.play_note((note:get('initial_note_number')  - params:get('root'))/ 12, 5)
  end
end
