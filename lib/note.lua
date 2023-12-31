local ANIMATION_FRAMES_MAX = 3
-- Note creation will animate (draw a circle growing and shrinking) from 1 to
-- ANIMATION_FRAMES_MAX frames then count back to 0 in the oscilloscope window
-- where the animation_frame value describes the size of the circle to be drawn

Note = {
  x_pos = nil,
  scaled_y_pos = nil,
  raw_volts = nil,
  quantized_volts = nil,
  initial_note_number = nil,
  quantized_note_number = nil,
  animating = true,
  animation_addend = 1,
  animation_frame = 1
}

function Note:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Note:get(k)
  return self[k]
end

function Note:set(k, v)
  self[k] = v
end

function Note:take_step(step_by)
  if self.animating then
    self:_animate()
  else
    self.x_pos = self.x_pos + (step_by or 1)
  end
end

function Note:_animate()
  if self.animating and self.animation_frame < ANIMATION_FRAMES_MAX and self.animation_frame > 0 then
    self.animation_frame = self.animation_frame + self.animation_addend
  elseif self.animating and self.animation_frame == ANIMATION_FRAMES_MAX then
    self.animation_addend = -1
    self.animation_frame = self.animation_frame + self.animation_addend
  elseif self.animating and self.animation_frame == 0 then
    self.animation_addend = 1
    self.animation_frame = 1
    self.animating = false
    self:take_step()
  end
end
