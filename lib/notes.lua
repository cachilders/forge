local SCREEN_WIDTH = 128

Notes = {
  connection = nil,
  exit_action = function() end,
  max_step = SCREEN_WIDTH,
  step_by = 1,
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

function Notes:_replace(t)
  self.notes = t
end

function Notes:take_steps(connection_active)
  local refreshed_notes = {}

  for i, note in ipairs(self.notes) do
    if note:get('x_pos') < self.max_step - 1 - self.step_by then
      note:take_step(self.step_by)
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

function Notes:flush()
  self:_replace({})
end

function Notes:draw_notes()
  for i, note in ipairs(self.notes) do
    if note:get('animating') then
      screen.circle(note:get('x_pos'), note:get('scaled_y_pos'), note:get('animation_frame'))
    else
      screen.pixel(note:get('x_pos'), note:get('scaled_y_pos'))
    end
  end
end
