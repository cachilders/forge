include('lib/output')

CrowOutput = {}

setmetatable(CrowOutput, { __index = Output })

function CrowOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CrowOutput:config(pulse_time)
  for i = 2, 4, 2 do
    crow.output[i].action = 'pulse('..pulse_time..', 5)'
  end
end

function CrowOutput:play_note(note)
  if parameters.quantizer_note_snap == true then 
    crow.output[1].volts = (note:get('quantized_note_number') - params:get('root')) / 12
  else
    crow.output[1].volts = (note:get('initial_note_number') - params:get('root')) / 12
  end

  if parameters.crow_raw_out_unipolar == true then
    crow.output[3].volts = note.raw_volts + params:get('cycle_min')
  else
    crow.output[3].volts = note.raw_volts
  end

  crow.output[2]()
  crow.output[4]()
end
