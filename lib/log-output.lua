include('lib/output')

LogOutput = {}

setmetatable(LogOutput, { __index = Output })

function LogOutput:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function LogOutput:play_note(note)
  local note_number = parameters.quantizer_note_snap and note:get('quantized_note_number') or note:get('initial_note_number')
  local note_name = musicutil.note_num_to_name(note_number)
  local extents = screen.text_extents(note_name)

  screen.move(SCREEN_WIDTH - extents, FRAME_HEIGHT + (HEIGHT_OFFSET * 2))
  screen.text(note_name)
  screen.update()
end
