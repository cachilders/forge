include('lib/output')

JFOutput = {
  pulse_time = .25
}

setmetatable(JFOutput, { __index = Output })

function JFOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function JFOutput:init()
  crow.ii.jf.mode(1)
end

function JFOutput:play_note(note)
  if parameters.quantizer_note_snap == true then 
    crow.ii.jf.play_note((note:get('quantized_note_number') - params:get('root')) / 12, 5)
  else
    crow.ii.jf.play_note((note:get('initial_note_number') - params:get('root')) / 12, 5)
  end
end
