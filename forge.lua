-- Forge
-- A playable oscilloscope for
-- Crow [-5v - 10v]
--
-- Also, it Works without Crow
-- Default ins are internal LFOs
-- Default out is PolyPerc
--
-- K3: Play/Pause the Player
--     Roll + init the Forge
-- K1 + K3: Stop/Clear Player Roll
-- K1 + ENC1: Adjust Scope frquency
-- K1 + ENC2: Trim the cycle floor
-- K1 + ENC3: Trim the cycle roof
-- Params: Inputs, Outputs,
--         and Kitchen Sinks


include('lib/utils')
include('lib/test/utils')
include('lib/midi-utils')
include('lib/crow-input')
include('lib/crow-output')
include('lib/disting-output')
include('lib/engine-output')
include('lib/jf-output')
include('lib/inputs')
include('lib/lfo-input')
include('lib/log-output')
include('lib/midi-output')
include('lib/nb-output')
include('lib/note')
include('lib/notes')
include('lib/outputs')
include('lib/oscilloscope')
include('lib/params')
include('lib/quantizer')
include('lib/wslashsynth-output')

LFO = require('lfo')
musicutil = require('musicutil')
UI = require('ui')
nb = require('forge/lib/nb/lib/nb')

FRAME_HEIGHT = 50
FRAME_WIDTH = 64
QUANT_WIDTH = 24
SCREEN_WIDTH = 128
HEIGHT_OFFSET = 5

player_step = 1
player_run = false

function init()
  nb:init()
  init_tests()
  init_params()
  init_oscilloscope()
  init_counters()
  init_inputs()
  init_notes()
  init_outputs()
  init_quantizer()
  init_transport_status()
end

function init_tests()
  test_calculate_cycle_to_screen_proportions()
  test_scale_to_unipolar_output_range()
end

function init_counters()
  player_counter = metro.init(player_loop, get_time(parameters.play_clock_mod_operator, params:get('play_clock_operand')))
  generator_counter = metro.init(generator_loop, get_time(parameters.gen_clock_mod_operator, params:get('gen_clock_operand')))
  oscilloscope_counter = metro.init(record_inputs_to_oscilloscope, 1 / params:get('hz'))
  generator_counter:start()
  oscilloscope_counter:start()
end

function init_inputs()
  inputs = Inputs:new()
  inputs.available_inputs.crow = {
    CrowInput:new({ source = crow.input[1] }),
    CrowInput:new({ source = crow.input[2] })
  }
  inputs.available_inputs.lfo = {
    LFOInput:new({ name = 'LFO Input 1', id = 'lfo_input_1', min = params:get('cycle_min'), max = params:get('cycle_max'), depth = .75, period = .25, shape = 'tri'}),
    LFOInput:new({ name = 'LFO Input 2', id = 'lfo_input_2', min = params:get('cycle_min'), max = params:get('cycle_max'), depth = .6, period = .5, phase = .9 })
  }

  for k, v in pairs(inputs.available_inputs) do
    for i = 1, #v do
      v[i]:init()
    end
  end

  for i = 1, #parameters.input_sources do
    inputs:add(inputs.available_inputs[parameters.input_sources[i]][i])
  end
end

function init_notes()
  player_segment_notes = Notes:new({max_step = SCREEN_WIDTH - 1, exit_action = play_note, step_by = 4})
  quantizer_segment_notes = Notes:new({max_step = FRAME_WIDTH + QUANT_WIDTH, connection = player_segment_notes, exit_action = quantize_note, step_by = 2})
  cycle_window_notes = Notes:new({max_step = FRAME_WIDTH, connection = quantizer_segment_notes})
end

function init_oscilloscope()
  oscilloscope = Oscilloscope:new({frame_height = FRAME_HEIGHT, height_offset = HEIGHT_OFFSET, frame_width = FRAME_WIDTH})
  oscilloscope:init()
end

function init_outputs()
  outputs = Outputs:new()
  log_output = LogOutput:new()
  engine_output = EngineOutput:new()
  crow_output = CrowOutput:new()
  disting_output = DistingOutput:new()
  jf_output = JFOutput:new()
  midi_output = MidiOutput:new()
  nb_output = NBOutput:new()
  wslashsynth_output = WSlashSynthOutput:new()
  jf_output:init()
  midi_output:init()
  wslashsynth_output:init()
  outputs:add(engine_output)
end

function init_quantizer()
  quantizer = Quantizer:new({octaves = params:get('octaves'), root = params:get('root'), scale = params:get('scale')})
  quantizer:generate_scale()
end

function init_transport_status()
  transport_status = UI.PlaybackIcon.new(FRAME_WIDTH, FRAME_HEIGHT + HEIGHT_OFFSET, 5, 4)
end

function get_time(operator, operand)
  local bpm = 60 / params:get('clock_tempo')
  if operator == 'multiply' then
    return bpm / operand
  else
    return bpm * operand
  end
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

function refresh_sample_frequency()
  local hz = params:get('hz')
  local time_arg = 1 / hz
  oscilloscope:set('hz', hz)

  for i = 1, #inputs.available_inputs.crow do
    if parameters.input_sources[i] == parameters.input_source_names[1] then
      inputs.available_inputs.crow[i]:get('source').mode('stream', time_arg)
    end
  end
end

function convert_raw_voltage_to_note_number(v)
  local negative_offset = math.abs(params:get('cycle_min'))
  local volt_range = negative_offset + params:get('cycle_max')
  local midi_range = params:get('octaves') * 12
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
  if player_step % params:get('event_modulo') == 0 then
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
  screen.move(0, HEIGHT_OFFSET)
  screen.line_rel(SCREEN_WIDTH, 0)
  screen.move(0, FRAME_HEIGHT + 1)
  screen.line_rel(SCREEN_WIDTH, 0)
end

function draw_text()
  screen.level(5)
  screen.move(1, FRAME_HEIGHT + (HEIGHT_OFFSET * 2))
  screen.text(''..params:get('hz')..' Hz')
  screen.move(FRAME_WIDTH + QUANT_WIDTH, FRAME_HEIGHT + (HEIGHT_OFFSET * 2))
  screen.text(''..params:get('clock_tempo')..' BPM')
  screen.level(15)
end

function enc(e, d)
  if shift and e == 1 then
    params:delta('hz', d)
    refresh_sample_frequency()
  elseif shift and e == 2 then
    params:delta('cycle_min', d)
  elseif shift and e == 3 then
    params:delta('cycle_max', d)
  end
end

function play()
  player_run = true
  player_counter:start()
  transport_status.status = 1
end

function pause()
  player_run = false
  player_counter:stop()
  transport_status.status = 3
end

function stop()
  player_run = false
  player_counter:stop()
  quantizer_segment_notes:flush()
  player_segment_notes:flush()
  transport_status.status = 4
  player_step = 1
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
    play()
  elseif k == 3 and z == 0 and player_run == true and shift ~= true  then
    pause()
  elseif k == 3 and z == 0 and player_run == true and shift == true  then
    stop()
  end
end

function refresh_app_state()
  if parameters.last_tempo ~= params:get('clock_tempo') then
    parameters.generator_params_dirty = true
    parameters.player_params_dirty = true
  end
  
  if parameters.generator_params_dirty then
    generator_counter.time = get_time(parameters.gen_clock_mod_operator, params:get('gen_clock_operand'))
    parameters.generator_params_dirty = false
  end

  if parameters.input_params_dirty then
    for i = 1, #parameters.input_sources do
      inputs:replace_input(i, inputs.available_inputs[parameters.input_sources[i]][i])
    end

    refresh_sample_frequency()
    parameters.input_params_dirty = false
  end

  if parameters.output_params_dirty then
    outputs:set('outputs', {})
    local midi_active = false

    if parameters.outputs.crow == true then
      crow_output:config(get_time(parameters.play_clock_mod_operator, params:get('play_clock_operand')))
      outputs:add(crow_output)
    end

    if parameters.outputs.disting == true then
      outputs:add(disting_output)
    end

    if parameters.outputs.engine == true then
      outputs:add(engine_output)
    end
    
    if parameters.outputs.jf == true then
      outputs:add(jf_output)
    end

    for id, enabled in pairs(parameters.outputs.midi) do
      midi_active = enabled or midi_active
    end

    if midi_active == true then
      midi_output:config(get_time(parameters.play_clock_mod_operator, params:get('play_clock_operand')))
      outputs:add(midi_output)
    end
    
    if parameters.outputs.log == true then
      outputs:add(log_output)
    end
    
    if parameters.outputs.nb == true then
      outputs:add(nb_output)
    end
    
    if parameters.outputs.wslashsynth == true then
      outputs:add(wslashsynth_output)
    end

    parameters.output_params_dirty = false
  end

  if parameters.oscilloscope_params_dirty then
    refresh_sample_frequency()
    oscilloscope_counter.time = 1 / params:get('hz')
    parameters.oscilloscope_params_dirty = false
  end

  if parameters.player_params_dirty then
    player_counter.time = get_time(parameters.play_clock_mod_operator, params:get('play_clock_operand'))
    parameters.player_params_dirty = false
  end

  if parameters.quantizer_params_dirty then
    quantizer:set('octaves', params:get('octaves'))
    quantizer:set('scale', params:get('scale'))
    quantizer:set('root', params:get('root'))
    quantizer:generate_scale()

    parameters.quantizer_params_dirty = false
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
  draw_text()
end

function redraw()
  screen.clear()
  
  if transport_status then
    transport_status:redraw()
  end

  refresh_app_state()
  
  draw_stuff()
 
  screen.stroke()
  screen.update()
end

function refresh()
    redraw()
end
