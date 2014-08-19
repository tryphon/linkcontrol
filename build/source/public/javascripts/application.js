Event.observe(window, "load", function() {
  var toggle_stream_mode_inputs = function(mode, enabled) {
    $('outgoing_stream_' + mode + '_inputs').select("input[type=text]").each(function(input) {
      if (enabled) {
        input.enable();
      } else {
        input.disable();
      }
    });
  };

  var outgoing_stream_radios = new Array();
  $$('input[type=radio][name="outgoing_stream[mode]"]').each(function(radio) {
    toggle_stream_mode_inputs(radio.value, radio.checked);
    outgoing_stream_radios.push(radio);

    Event.observe(radio, 'change', function() {
      toggle_stream_mode_inputs(radio.value, radio.checked);
      outgoing_stream_radios.without(radio).each(function(other_radio) {
        toggle_stream_mode_inputs(other_radio.value, other_radio.checked);
      });
    });
  });
});
