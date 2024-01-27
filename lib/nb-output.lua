include('lib/output')

NBOutput = {
  player = nil
}

setmetatable(NBOutput, {__index = Output})

function NBOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function NBOutput:play_note(note, v, opt)
  local note_number = parameters.quantizer_note_snap and note:get('quantized_note_number') or note:get('initial_note_number')
  local player = params:lookup_param('nb_voice'):get_player()

  clock.run(
    function()
      player:note_on(note_number, v or 100, opt)
      clock.sleep(self.pulse_time)
      player:note_off(note_number)
    end
  )
end