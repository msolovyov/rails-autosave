var Autosave = function($form, options) {
  var required_fields = options && options.required_fields || [];
  var started = false;
  var done = false;
  var id = /\d+/.exec($form.attr('action'));

  var required_fields_populated = function() {
    if (required_fields.length > 0) {
      var mode = options.require_mode || "all";
      return _[mode](required_fields, function(field) { return $.trim($(field).val() || $(field).text()) });
    }

    return true;
  };

  var save = function() {
    if (!started || done) {
      return;
    }

    if (required_fields_populated()) {
      if (!id) {
        $.post($form.attr('action'), $form.serialize(), function(data) {
          id = data.id;
          $form.attr('action', $form.attr('action') + '/' + id);
          var hidden = '<input type="hidden" name="_method" value="put" />';
          $form.append(hidden);
        }, 'json');
      } else {
        $.post($form.attr('action'), $form.serialize(), null, 'json');
      }
    }
  };

  setInterval(function() {
    save();
  }, 60000);

  $(window).unload(function() {
    started = true;
    save();
  });

  var auto_save = {
    start: function() {
      started = true;
    },

    stop: function() {
      started = false;
    },

    kill: function() {
      done = true;
    }
  };

  $form.submit(function() {
    auto_save.kill();
  });

  return auto_save;
};
