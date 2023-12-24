-- Staff Engineer
-- Crow
-- 16bit [-5V,10V] range


include('lib/note')
include('lib/notes')

EPS_MIN = 10
EPS_MAX = 1200
STAFF_WIDTH = 64

events_per_second = 120
bpm = events_per_second
plot_position_modifier = 1
time_arg = 1 / events_per_second
event = 1
cycle_1_dirty = false
cycle_2_dirty = false
octaves = 2
y_pixels = 50
volt_min = -3 
volt_max = 6.5
staff_lines = octaves * 5
staff_line_offset = y_pixels / staff_lines
player_step = 1
player_run = true

function init()
  init_cycles()
  init_notes()
  counter = metro.init(player_loop, get_time())
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
  player_roll_notes = Notes:new()
  cycle_window_notes = Notes:new({max_step = STAFF_WIDTH, next_notes = player_roll_notes})
  print(player_roll_notes.max_step)
end

function get_time()
  return 60 / bpm
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

function calculate_cycle_to_screen_proportions(v)
  -- y values are inverted to paint to to bottom
  local inverted_v = v * -1
  local scaled_volts = (inverted_v - (volt_min * -1))/((volt_max * -1) - (volt_min * -1))*(y_pixels - staff_line_offset) + staff_line_offset
  return scaled_volts
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

function step_cycle_loop()
  for i=1, STAFF_WIDTH do
    draw_cycle_step(i)
    cycle_window_notes:take_steps(player_run)
  end
end

function player_loop()
  counter.time = get_time()
  player_step = (player_step < 64) and player_step + 1 or 1
  player_roll_notes:take_steps(player_run)
end

function draw_staff()
  screen.level(1)
  
  for i=1, staff_lines do
    screen.level(1)
    local y = i * staff_line_offset
    screen.move(0, y)
    screen.line(STAFF_WIDTH, y)
  end
end

-- temp, naive crossing. need line segment intersect
function create_note_if_crossing(step)
  if cycles[1][step] == cycles[2][step] then
    
  end
end

function draw_cycle_step(step)
  screen.level(5)
  local points = {nil,nil}
  local sample = map_cycle_sample_to_pixel(step)
  
  for i=1, #cycles do
    local cycle = cycles[i]

    if cycle[sample] then
      local scaled_sample = calculate_cycle_to_screen_proportions(cycle[sample]) 
      points[i] = math.floor(scaled_sample)
      screen.pixel(step, scaled_sample)
    end
  end
  if points[1] and points[1] == points[2] then
    screen.level(10)
    cycle_window_notes:add(Note:new({x_pos = step, scaled_y_pos = points[1], raw_volts = cycles[1][step]}))
  end
end

function enc(e, d)
  if e == 1 then
    events_per_second = util.clamp(events_per_second + d, EPS_MIN, EPS_MAX)
    bpm = events_per_second
    adjust_sample_frequency()
  end
end

function key(k, z)
  if k == 1 and z == 1 then
    shift = true
  elseif k == 1 and z == 0 then
    shift = false
  end

  if k == 2 and z == 0 then
    print('K2')
  elseif k == 3 and z == 0 and player_run == false then
    player_run = true
    counter:start()
  elseif k == 3 and z == 0 and player_run then
    player_run = false
    counter:stop()
  elseif k == 3 and z == 1 and player_run then
    player_run = false
    counter:stop()
    player_step = 0
  end
end

function draw_notes()
  cycle_window_notes:draw_notes()
  player_roll_notes:draw_notes()
end

function redraw()
  screen.clear()
  
  draw_staff()
  step_cycle_loop()
  draw_notes()
  
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
