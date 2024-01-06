parameters = {
  clock_operators = {'multiply', 'divide'},
  gen_clock_operator = '',
  play_clock_operator = '',
  enabled_terms = {'off', 'on'},
  enabled_state = {false, true},
  generator_params_dirty = false,
  input_params_dirty = false,
  input_source_names = {'crow', 'lfo'},
  input_sources = {'', ''},
  last_tempo = params:get('clock_tempo'),
  midi_devices = {},
  output_params_dirty = false,
  outputs = {},
  oscilloscope_params_dirty = false,
  player_params_dirty = false,
  quantizer_note_snap = true,
  quantizer_params_dirty = false,
  quantizer_step_snap = true,
  scale = '',
  scale_names = get_musicutil_scale_names()
}

function init_params()
  params:add_separator('app_name_space', '')
  params:add_separator('app_name', 'Forge')

  params:add_trigger('midi_panic', 'MIDI Panic')
  params:set_action('midi_panic', midi_panic)

  params:add_separator('inputs_space', '')
  params:add_separator('inputs', 'Inputs')

  for input = 1, #parameters.input_sources do
    params:add_option('input_'..input, 'Input '..input..' Source', parameters.input_source_names, 2)
    params:set_action('input_'..input, function(i) parameters.input_sources[input] = parameters.input_source_names[i]; parameters.input_params_dirty = true end)
  end

  params:add_separator('oscilloscope_space', '')
  params:add_separator('oscilloscope', 'Oscilloscope')

  params:add_number('cycle_min', 'Cycle Volts Min', -5, 10, -5)
  params:set_action('cycle_min', function() parameters.oscilloscope_params_dirty = true end)
  params:add_number('cycle_max', 'Cycle Volts Max', -5, 10, 10)
  params:set_action('cycle_max', function() parameters.oscilloscope_params_dirty = true end)
  params:add_number('hz', 'Cycle Sampling Hz', 50, 500, 185)
  params:set_action('hz', function() parameters.oscilloscope_params_dirty = true end)

  params:add_separator('generator_space', '')
  params:add_separator('generator', 'Note Generator')

  params:add_option('gen_clock_operator', 'Clock Operator', parameters.clock_operators, 2)
  params:set_action('gen_clock_operator', function(i) parameters.gen_clock_mod_operator = parameters.clock_operators[i]; parameters.generator_params_dirty = true end)
  params:add_number('gen_clock_operand', 'Clock Operand', 1, 64, 1)
  params:set_action('gen_clock_operand', function() parameters.generator_params_dirty = true end)
  params:add_number('event_modulo', 'New Notes on Nth Tick', 1, FRAME_WIDTH, 6)
  params:set_action('event_modulo', function() parameters.generator_params_dirty = true end)
  params:add_number('octaves', 'Octave Range', 1, 10, 2)
  params:set_action('octaves', function() parameters.quantizer_params_dirty = true end)
  params:add_number('root', 'Root Note', 0, 127, 48, function(param) return musicutil.note_num_to_name(param:get(), true) end)
  params:set_action('root', function() parameters.quantizer_params_dirty = true end)

  params:add_separator('quatizer_space', '')
  params:add_separator('quantizer', 'Quantizer')

  params:add_option('quantizer_steps_snap', 'Snap Notes to Steps', parameters.enabled_terms, 2)
  params:set_action('quantizer_steps_snap', function(i) parameters.quantizer_step_snap = parameters.enabled_state[i] end)
  params:add_option('quantizer_note_snap', 'Snap Notes to Scale', parameters.enabled_terms, 2)
  params:set_action('quantizer_note_snap', function(i) parameters.quantizer_note_snap = parameters.enabled_state[i]; refresh_params() end)
  params:add_option('scale', 'Scale Type', parameters.scale_names, 1)
  params:set_action('scale', function(i) parameters.scale = parameters.scale_names[i]; parameters.quantizer_params_dirty = true end)

  params:add_separator('player_space', '')
  params:add_separator('player', 'Player Roll')

  params:add_option('play_clock_operator', 'Clock Operator', parameters.clock_operators, 1)
  params:set_action('play_clock_operator', function(i) parameters.play_clock_mod_operator = parameters.clock_operators[i]; parameters.player_params_dirty = true end)
  params:add_number('play_clock_operand', 'Clock Operand', 1, 64, 1)
  params:set_action('play_clock_operand', function() parameters.player_params_dirty = true end)

  params:add_separator('outputs_space', '')
  params:add_separator('outputs', 'Outputs')

  params:add_option('engine_output', 'Engine', parameters.enabled_terms, 2)
  params:set_action('engine_output', function(i) parameters.outputs.engine = parameters.enabled_state[i]; parameters.output_params_dirty = true end)

  refresh_midi_params()

  for device = 1, #parameters.midi_devices do
    params:add_option('midi_device_'..device..'_output', 'MIDI '..device..': '..parameters.midi_devices[device].name, parameters.enabled_terms, 1)
    params:set_action('midi_device_'..device..'_output',  function(i) parameters.midi_devices[device].enabled = parameters.enabled_state[i]; refresh_params(); parameters.output_params_dirty = true end)
    params:add_number('midi_device_'..device..'_output_channel', 'MIDI Channel', 1, 16, 1)
    params:set_action('midi_device_'..device..'_output_channel', function() parameters.output_params_dirty = true end)
  end

  params:add_option('crow_output', 'Crow', parameters.enabled_terms, 1)
  params:set_action('crow_output', function(i) parameters.outputs.crow = parameters.enabled_state[i]; refresh_params(); parameters.output_params_dirty = true end)
  params:add_option('crow_raw_out_unipolar', 'Crow Raw -> Unipolar', parameters.enabled_terms, 1)
  params:set_action('crow_raw_out_unipolar', function(i) parameters.crow_raw_out_unipolar = parameters.enabled_state[i]; parameters.output_params_dirty = true end)
  params:add_option('disting_output', 'Disting EX', parameters.enabled_terms, 1)
  params:set_action('disting_output', function(i) parameters.outputs.disting = parameters.enabled_state[i]; parameters.output_params_dirty = true end)
  params:add_option('jf_output', 'Just Friends', parameters.enabled_terms, 1)
  params:set_action('jf_output', function(i) parameters.outputs.jf = parameters.enabled_state[i]; parameters.output_params_dirty = true end)
  params:add_option('wslashsynth_output', 'W/ Synth', parameters.enabled_terms, 1)
  params:set_action('wslashsynth_output', function(i) parameters.outputs.wslashsynth = parameters.enabled_state[i]; parameters.output_params_dirty = true end)

  params:add_separator('lfo_inputs_space', '')
  params:add_separator('lfo_inputs', 'Internal LFO Inputs')

  refresh_params()

  params:bang()
end

function refresh_midi_params()
  -- TODO move the actual storage of the midi devices to a midi class and move the utils under it
  local devices = {}
  
  for i = 1, #midi.devices do
    if parameters.midi_devices[i] and parameters.midi_devices[i].name == midi.devices[i].name then
      devices[i] = parameters.midi_devices[i]
    else
      devices[i] = midi.devices[i]
    end
  end

  parameters.midi_devices = devices
  refresh_midi_connections()
end

function refresh_params()
  refresh_midi_params()

  if norns.crow.dev then
    params:show('inputs_space')
    params:show('inputs')
    params:show('input_1')
    params:show('input_2')
    params:show('crow_output')
    params:show('crow_raw_out_unipolar')
    params:show('disting_output')
    params:show('jf_output')
    params:show('wslashsynth_output')
  else
    params:hide('inputs_space')
    params:hide('inputs')
    params:hide('input_1')
    params:hide('input_2')
    params:hide('crow_output')
    params:hide('crow_raw_out_unipolar')
    params:hide('disting_output')
    params:hide('jf_output')
    params:hide('wslashsynth_output')
  end

  if parameters.input_sources[1] == parameters.input_source_names[2] or parameters.input_sources[2] == parameters.input_source_names[2] then
    params:show('lfo_inputs_space')
    params:show('lfo_inputs')
  else
    params:hide('lfo_inputs_space')
    params:hide('lfo_inputs')
  end

  if parameters.outputs.crow == true then
    params:show('crow_raw_out_unipolar')
  else
    params:hide('crow_raw_out_unipolar')
  end

  for i = 1, #parameters.midi_devices do
    if parameters.midi_devices[i].enabled == true then
      params:show('midi_device_'..i..'_output_channel')
    else
      params:hide('midi_device_'..i..'_output_channel')
    end
  end

  if parameters.quantizer_note_snap == true then
    params:show('scale')
  else
    params:hide('scale')
  end

  _menu.rebuild_params()
end
