-- Forge
-- you know, for Crow
-- 16bit [-5V,10V] range

include('lib/crow-input')
include('lib/engine-output')
include('lib/find-line-segment-overlap')
include('lib/inputs')
include('lib/lfo-input')
include('lib/note')
include('lib/notes')
include('lib/output')
include('lib/outputs')
include('lib/oscilloscope')
include('lib/params')
include('lib/quantizer')
include('lib/utils')

LFO = require('lfo')
musicutil = require('musicutil')

EPS_MIN = 100
EPS_MAX = 600
FRAME_HEIGHT = 50
FRAME_WIDTH = 64
QUANT_WIDTH = 24
SCREEN_WIDTH = 128
HEIGHT_OFFSET = 5

events_per_second = 120
player_clock_div = 1
generator_clock_div = 2
time_arg = 1 / events_per_second
event = 1
octaves = 3
volt_min = -3 
volt_max = 6.5
player_step = 1
player_run = false

function init()
  init_params()
  init_oscilloscope()
  init_counters()
  init_inputs()
  init_notes()
  init_outputs()
  init_quantizer()
  adjust_sample_frequency(events_per_second)
end

function init_counters()
  player_counter = metro.init(player_loop, get_player_time()/player_clock_div)
  generator_counter = metro.init(generator_loop, get_player_time()/generator_clock_div)
  oscilloscope_counter = metro.init(record_inputs_to_oscilloscope, time_arg)
  generator_counter:start()
  oscilloscope_counter:start()
end

function init_inputs()
  inputs = Inputs:new()
  crow_inputs = {
    CrowInput:new({ source = crow.input[1] }),
    CrowInput:new({ source = crow.input[2] })
  }
  lfo_inputs = {
    LFOInput:new({ name = 'LFO Input 1', id = 'lfo_input_1', min = oscilloscope:get('volt_min'), max = oscilloscope:get('volt_max'), depth = .75 }),
    LFOInput:new({ name = 'LFO Input 2', id = 'lfo_input_2', min = oscilloscope:get('volt_min'), max = oscilloscope:get('volt_max'), depth = .5, period = .5, phase = .5 })
  }

  for i = 1, #parameters.inputs do
    if parameters.inputs[i] == parameters.input_sources[1] then
      inputs:add(crow_inputs[i])
      crow_inputs[i]:init()
    elseif parameters.inputs[i] == parameters.input_sources[2] then
      inputs:add(lfo_inputs[i])
      lfo_inputs[i]:init()
    end
  end
end

function init_notes()
  player_segment_notes = Notes:new({max_step = SCREEN_WIDTH - 1, exit_action = play_note, step_by = 4})
  quantizer_segment_notes = Notes:new({max_step = FRAME_WIDTH + QUANT_WIDTH, connection = player_segment_notes, exit_action = quantize_note, step_by = 2})
  cycle_window_notes = Notes:new({max_step = FRAME_WIDTH, connection = quantizer_segment_notes})
end

function init_oscilloscope()
  oscilloscope = Oscilloscope:new({hz = events_per_second, frame_height = FRAME_HEIGHT, height_offset = HEIGHT_OFFSET, frame_width = FRAME_WIDTH, volt_min = volt_min, volt_max = volt_max})
  oscilloscope:init()
end

function init_outputs()
  outputs = Outputs:new()
  log_output = Output:new()
  engine_output = EngineOutput:new()
  outputs:add(log_output)
  outputs:add(engine_output)
end

function init_quantizer()
  quantizer = Quantizer:new()
  quantizer:generate_scale(octaves)
end

function get_player_time()
  return 60 / params:get('clock_tempo')
end

function record_inputs_to_oscilloscope()
  oscilloscope:record_inputs(inputs)
end

function quantize_note(note)
  quantizer:snap_note(note)
end

function play_note(note)
  outputs:play_note(note)
end

function adjust_sample_frequency()
  local time_arg = 1 / events_per_second
  oscilloscope:set('hz', events_per_second)
  if crow_input_1 and crow_input_2 then
    crow_input_1:get('source').mode('stream', time_arg)
    crow_input_2:get('source').mode('stream', time_arg)
  end
end

function convert_raw_voltage_to_note_number(v)
  -- temp
  local negative_offset = math.abs(volt_min)
  local volt_range = negative_offset + volt_max
  local midi_range = octaves * 12
  local multiplier = midi_range / volt_range
  local volt_abs = v + negative_offset
  local midi_floor = quantizer:get('root')
  local initial_note_number = midi_floor + math.floor(volt_abs * multiplier)
  return initial_note_number
end

function place_note_on_intersection(x, y)
  cycle_window_notes:add(Note:new({x_pos = x, scaled_y_pos = oscilloscope:calculate_cycle_to_screen_proportions(y), raw_volts = y, initial_note_number = convert_raw_voltage_to_note_number(y)}))
end

function generator_loop()
  if player_step % 6 == 0 then -- TODO This gate should be variable
    oscilloscope:act_on_intersections(place_note_on_intersection)
  end
  
  cycle_window_notes:take_steps(player_run)
end

function player_loop()
  player_step = (player_step < FRAME_WIDTH) and player_step + 1 or 1
  
  if player_run then
    quantizer_segment_notes:take_steps(player_run)
    player_segment_notes:take_steps()
  end
end

function draw_generator_barrier()
  screen.move(FRAME_WIDTH + 1, HEIGHT_OFFSET)
  screen.line_rel(0, FRAME_HEIGHT - HEIGHT_OFFSET)
end

function draw_quant_barrier()
  screen.move(FRAME_WIDTH + QUANT_WIDTH - 1, HEIGHT_OFFSET)
  screen.line_rel(0, FRAME_HEIGHT - HEIGHT_OFFSET)
  screen.move(FRAME_WIDTH + QUANT_WIDTH + 1, HEIGHT_OFFSET)
  screen.line_rel(0, FRAME_HEIGHT - HEIGHT_OFFSET)
end

function draw_x_boundaries()
  screen.move(1, HEIGHT_OFFSET)
  screen.line_rel(0, FRAME_HEIGHT - HEIGHT_OFFSET)
  screen.move(SCREEN_WIDTH, HEIGHT_OFFSET)
  screen.line_rel(0, FRAME_HEIGHT - HEIGHT_OFFSET)
end

function draw_y_boundaries()
  screen.move(1, HEIGHT_OFFSET)
  screen.line_rel(SCREEN_WIDTH, 0)
  screen.move(1, FRAME_HEIGHT)
  screen.line_rel(SCREEN_WIDTH, 0)
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
    player_counter:start()
  elseif k == 3 and z == 0 and player_run == true and shift ~= true  then
    player_run = false
    player_counter:stop()
  elseif k == 3 and z == 0 and player_run == true and shift == true  then
    player_run = false
    player_counter:stop()
    player_step = 1
  end
end

function draw_stuff()
  cycle_window_notes:draw_notes()
  quantizer_segment_notes:draw_notes()
  player_segment_notes:draw_notes()
  oscilloscope:draw_cycles()
  draw_generator_barrier()
  draw_quant_barrier()
  draw_x_boundaries()
  draw_y_boundaries()
end

function redraw()
  screen.clear()
  
  draw_stuff()
  
  screen.move(1, 60)
  screen.text(''..oscilloscope:get('hz')..' Hz')
  screen.move(FRAME_WIDTH + QUANT_WIDTH, 60)
  screen.text(''..params:get('clock_tempo')..' BPM')
  
  screen.stroke()
  screen.update()
end

function refresh()
    redraw()
end
