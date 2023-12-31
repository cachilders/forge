Oscilloscope = {
  current_event = 1,
  cycles = {{}, {}},
  height_offset = 5,
  frame_height = 50,
  frame_width = 64,
}

function Oscilloscope:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Oscilloscope:init()
  for i = 1, params:get('hz') do
    self.cycles[1][i] = nil
    self.cycles[2][i] = nil
  end
end

function Oscilloscope:get(k)
  return self[k]
end

function Oscilloscope:set(k, v)
  self[k] = v
end

function Oscilloscope:_take_step()
  self.current_event = self.current_event < params:get('hz') and self.current_event + 1 or 1
end

function Oscilloscope:record_inputs(inputs)
  if inputs then
    local input_values = inputs:poll()

    if input_values then
      for i = 1, #input_values do
        self.cycles[i][self.current_event] = input_values[i]
      end

      self:_take_step()
    end
  end
end

function Oscilloscope:_map_cycle_sample_to_pixel(i)
  local cycle_sample = math.floor(i/(self.frame_width/params:get('hz')))

  if cycle_sample < 1 then
    cycle_sample = 1
  elseif cycle_sample > params:get('hz') then
    cycle_sample = params:get('hz')
  end
  
  return cycle_sample
end

function Oscilloscope:act_on_intersections(callback)
  for i = 1, self.frame_width do
    local sample = self:_map_cycle_sample_to_pixel(i)
    local intersection = nil

    if self.cycles[1][sample] then
      local ax = self:_map_cycle_sample_to_pixel(i > 1 and i - 1 or self.frame_width)
      local bx = self:_map_cycle_sample_to_pixel(i < self.frame_width and i + 1 or 1)

      intersection = find_line_segment_overlap(ax, self.cycles[1][ax], bx, self.cycles[1][bx], ax, self.cycles[2][ax], bx, self.cycles[2][bx])

      if intersection then
        callback(i, intersection.y)
      end
    end
  end
end

function Oscilloscope:calculate_cycle_to_screen_proportions(v)
  return calculate_cycle_to_screen_proportions(v, self.frame_height, self.height_offset, params:get('cycle_min'), params:get('cycle_max'))
end

function Oscilloscope:_draw_cycle_step(step)
  local sample = self:_map_cycle_sample_to_pixel(step)

  for i = 1, #self.cycles do
    local cycle = self.cycles[i]

    if cycle[sample] then
      local scaled_sample = self:calculate_cycle_to_screen_proportions(cycle[sample]) 
      screen.pixel(step, scaled_sample)
    end
  end
end

function Oscilloscope:draw_cycles()
  for i = 1, self.frame_width do
    self:_draw_cycle_step(i)
  end
end
