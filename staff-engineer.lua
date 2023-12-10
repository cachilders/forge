-- Staff Engineer
-- Crow 16bit [-5V,10V] range
--
-- MVP:
-- [x] events_per_second = 1000 (resolution of oscilloscope)
-- [x] cycles[1] and cycles[2] (arrays of length == events_per_second for each channel)
-- [x] plot cycles to screen
-- [] where path between points of cycles[1] overlaps path between points of cycles[2] place note on staff
-- [] where x is some kind of array consisting of rests and notes of some sort of frequency abstracted from the point of intersection
-- [] playhead runs across staff
-- [] tempo managed by system
-- [] c major scale, quant
-- [] k3 == transport start/pause
-- [] k1+k3 == transport reset
-- BELOW THE LINE:
-- [x] adjustable sample frequency

EPS_MIN = 10
EPS_MAX = 1200
STAFF_WIDTH = 125

events_per_second = STAFF_WIDTH
plot_position_modifier = 1
time_arg = 1 / events_per_second
event = 1
cycle_1_dirty = false
cycle_2_dirty = false
octaves = 2
y_pixels = 50
staff_lines = octaves * 5
staff_line_offset = y_pixels / staff_lines

function init()
  init_cycles()
  init_notes()
  crow.input[1].stream = record_cycle_1
  crow.input[2].stream = record_cycle_2
  adjust_sample_frequency(events_per_second)
end

function init_cycles()
  cycles = {{}, {}}
  
  for i=1, events_per_second do
    cycles[1][i] = nil
    cycles[2][i] = nil
  end
end

function init_notes()
  raw_points_of_intersection = {}
  
  for i=1, STAFF_WIDTH do
    raw_points_of_intersection[i] = nil
  end
end

function adjust_sample_frequency()
  local time_arg = 1 / events_per_second
  plot_position_modifier = STAFF_WIDTH / events_per_second
  crow.input[1].mode('stream', time_arg)
  crow.input[2].mode('stream', time_arg)
end

function record_cycle(i, v)
  if cycle_1_dirty and cycle_2_dirty then
    event = event < events_per_second and event + 1 or 1
    cycle_1_dirty = false
    cycle_2_dirty = false
  end
  
  cycles[i][event] = v
  dirty = true
end

function record_cycle_1(v)
  record_cycle(1, v)
  cycle_1_dirty = true
end

function record_cycle_2(v)
  record_cycle(2, v)
  cycle_2_dirty = true
end

-- This math is not precise enough to be trusted
-- and is only accomplishing aesthetic so far
function calculate_cycle_to_screen_proportions(v)
  return ((v+4.8) * 4.2)
end

function map_cycle_sample_to_pixel(i)
  local cycle_sample = math.floor(i/plot_position_modifier)

  if cycle_sample < 1 then
    cycle_sample = 1
  elseif cycle_sample > events_per_second then
    cycle_sample = events_per_second
  end
  
  return cycle_sample
end

function draw_cycles()
  screen.level(5)
  
  for i=1, STAFF_WIDTH do
    for j=1, #cycles do
      local cycle = cycles[j]
      local sample = map_cycle_sample_to_pixel(i)

      if cycle[sample] then
        local scaled_sample = calculate_cycle_to_screen_proportions(cycle[sample]) 
        
        screen.pixel(i, scaled_sample)
      end
    end
  end
end

function draw_staff()
  screen.level(5)
  
  for i=1, staff_lines do
    local y = i * staff_line_offset
    screen.move(0, y)
    screen.line(128, y)
  end
end

function enc(e, d)
  if e == 1 then
    events_per_second = util.clamp(events_per_second + d, EPS_MIN, EPS_MAX)
    adjust_sample_frequency()
  end
end

function redraw()
  screen.clear()
  
  draw_staff()
  draw_cycles()
  
  screen.move(1, 60)
  screen.text(''..events_per_second..' Hz')
  
  screen.stroke()
  screen.update()
  dirty = false
end

function refresh()
  if dirty then
    redraw()
  end
end
