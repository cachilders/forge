local SCREEN_WIDTH = 128

Notes = {
  max_step = SCREEN_WIDTH,
  next_notes = nil, -- optional loop to transfer to when max_step is reached
  notes = {}
}

function Notes:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Notes:add(note)
  table.insert(self.notes, 1, note)
end

function Notes:_remove(i)
  table.remove(self.notes, i)
end

function Notes:take_steps(next_notes_active)
  for i, note in ipairs(self.notes) do
    if note.x_pos < self.max_step then
      note:take_step()
    elseif self.next_notes and next_notes_active == true then
      self.next_notes:add(note)
      self:_remove(i)
    else
      self:_remove(i)
    end
  end
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
