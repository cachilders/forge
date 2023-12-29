local SCREEN_WIDTH = 128

Notes = {
  connection = nil,
  exit_action = function() end,
  max_step = SCREEN_WIDTH,
  notes = {}
}

function Notes:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Notes:add(note)
  table.insert(self.notes, note)
end

function Notes:_remove(i)
  table.remove(self.notes, i)
end

function Notes:_replace(t)
  self.notes = t
end

function Notes:take_steps(connection_active)
  local refreshed_notes = {}

  for i, note in ipairs(self.notes) do
    if note.x_pos < self.max_step then
      note:take_step()
      table.insert(refreshed_notes, note)
    else
      if self.connection and connection_active == true then
        self.connection:add(note)
      end

      self.exit_action(note)
    end
  end

  self:_replace(refreshed_notes)
end

function Notes:draw_notes()
  for i, note in ipairs(self.notes) do
    if note.animating then
      screen.circle(note.x_pos, note.scaled_y_pos, note.animation_frame)
    else
      screen.pixel(note.x_pos, note.scaled_y_pos)
    end
  end
end

return Notes
