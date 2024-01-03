parameters = {
  clock_operators = {'multiply', 'divide'},
  clock_mod_state = {},
  enabled_terms = {'off', 'on'},
  enabled_state = {false, true},
  input_sources = {'Crow', 'LFO'},
  inputs = {'', ''},
  midi_devices = {},
  outputs = {},
  scale = '',
  scale_names = get_musicutil_scale_names()
}

function init_params()
  params:add_separator('app_name_space', '')
  params:add_separator('app_name', 'Forge')

  params:add_trigger('midi_panic', 'MIDI Panic')
  params:set_action('midi_panic', function() print('PANIC!') end)

  params:add_separator('inputs_space', '')
  params:add_separator('inputs', 'Inputs')

  params:add_option('input_1', 'Input 1 Source', parameters.input_sources, 1)
  params:set_action('input_1', function(i) parameters.inputs[1] = parameters.input_sources[i] end)
  params:add_option('input_2', 'Input 2 Source', parameters.input_sources, 1)
  params:set_action('input_2', function(i) parameters.inputs[2] = parameters.input_sources[i] end)

  params:add_separator('oscilloscope_space', '')
  params:add_separator('oscilloscope', 'Oscilloscope')

  params:add_number('cycle_min', 'Cycle Volts Min', -5, 10, -3)
  params:add_number('cycle_max', 'Cycle Volts Max', -5, 10, 6.5)
  params:add_number('hz', 'Hz', 50, 500, 120)

  params:add_separator('generator_space', '')
  params:add_separator('generator', 'Generator')

  params:add_number('event_modulo', 'New Notes on Nth Tick', 1, 16, 6)

  params:add_separator('quatizer_space', '')
  params:add_separator('quantizer', 'Quantizer')

  params:add_number('octaves', 'Octave Range', 1, 10, 3)
  params:add_option('scale', 'Scale Type', parameters.scale_names, 1)
  params:set_action('scale', function(i) parameters.scale = parameters.scale_names[i] end)
  params:add_number('root', 'Root Midi Note', 0, 127, 60)

  params:add_separator('player_space', '')
  params:add_separator('player', 'Player Roll')

  params:add_option('clock_operator', 'Clock Operator', parameters.clock_operators, 1)
  params:set_action('clock_operator', function(i) parameters.clock_mod_state.operator = parameters.clock_operators[i] end)
  params:add_number('clock_operand', 'Clock Operand', 1, 64, 1)

  params:add_separator('outputs_space', '')
  params:add_separator('outputs', 'Outputs')

  params:add_option('crow_output', 'Crow', parameters.enabled_terms, 2)
  params:set_action('crow_output', function(i) parameters.outputs.crow = parameters.enabled_state[i]; refresh_params() end)
  params:add_option('crow_raw_out_unipolar', 'Crow Raw -> Unipolar', parameters.enabled_terms, 1)
  params:set_action('crow_raw_out_unipolar', function(i) parameters.crow_raw_out_unipolar = parameters.enabled_state[i] end)
  params:add_option('engine_output', 'Engine', parameters.enabled_terms, 2)
  params:set_action('engine_output', function(i) parameters.outputs.engine = parameters.enabled_state[i] end)

  refresh_midi_params()

  for j = 1, #parameters.midi_devices do
    params:add_option('midi_device_'..j..'_output', parameters.midi_devices[j].name, parameters.enabled_terms, 1)
    params:set_action('midi_device_'..j..'_output',  function(i) parameters.midi_devices[j].enabled = parameters.enabled_state[i]; refresh_params() end)
    params:add_number('midi_device_'..j..'_output_channel', 'MIDI Channel', 1, 16, 1)
  end

  params:add_option('wslashsyn_output', 'W/ Synth', parameters.enabled_terms, 1)
  params:set_action('wslashsyn_output', function(i) parameters.outputs.wslashsyn = parameters.enabled_state[i] end)
  params:add_option('jf_output', 'Just Friends', parameters.enabled_terms, 1)
  params:set_action('jf_output', function(i) parameters.outputs.jf = parameters.enabled_state[i] end)
  params:add_option('disting_output', 'Disting EX', parameters.enabled_terms, 1)
  params:set_action('disting_output', function(i) parameters.outputs.disting = parameters.enabled_state[i] end)

  params:add_separator('lfo_inputs_space', '')
  params:add_separator('lfo_inputs', 'Internal LFO Inputs')

  params:default()

  refresh_params()

  params:bang()
end

function refresh_midi_params()
  local devices = {}
  
  for i = 1, #midi.devices do
    if parameters.midi_devices[i] and parameters.midi_devices[i].name == midi.devices[i].name then
      devices[i] = parameters.midi_devices[i]
    else
      parameters.midi_devices[i] = midi.devices[i]
    end
  end
end

function refresh_params()
  refresh_midi_params()

  if parameters.inputs[1] == parameters.input_sources[2] or parameters.inputs[2] == parameters.input_sources[2] then
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

  _menu.rebuild_params()
end
