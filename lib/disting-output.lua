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
  clock.run(
    function()
      local id = note:get('quantized_note_number') or note:get('initial_note_number')

      if parameters.quantizer_note_snap == true  and note:get('quantized_note_number') then 
        crow.ii.disting.note_pitch(id, (note:get('quantized_note_number') - params:get('root')) / 12)
      else
        crow.ii.disting.note_pitch(id, (note:get('initial_note_number') - params:get('root')) / 12)
      end
    
      crow.ii.disting.note_velocity(id, 5)
      clock.sleep(self.pulse_time)
      crow.ii.disting.note_off(id)
    end
  )
end

