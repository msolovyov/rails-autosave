$.fn.Autosave = (options) ->
  $form = this
  required_fields = options and options.required_fields or []
  started = false
  done = false
  match = /^(\/\w+\/\w+\/\w+|\/\w+)\/(\w+)$/.exec($form.attr("action"))
  id = match.pop() if match
  required_fields_populated = ->
    if required_fields.length > 0
      mode = options.require_mode or "all"
      return _[mode](required_fields, (field) ->
        $.trim $(field).val() or $(field).text()
      )
    true

  save = ->
    return  if not started or done
    if required_fields_populated()
      unless id
        $.post($form.attr("action"), $form.serialize(), ((data) ->
                  id = data._id
                  
                  $form.attr "action", $form.attr("action") + "/" + id
                  hidden = "<input type=\"hidden\" name=\"_method\" value=\"put\" />"
                  $form.append hidden
                ), "json").error ->
            console.log "validation error"
            false
        
      else
        $.post($form.attr("action"), $form.serialize(), null, "json").error ->
          console.log "validation error"
          false
        

  setInterval (->
    save()
  ), 6000
  $(window).unload ->
    started = true
    save()

  auto_save =
    start: ->
      started = true

    stop: ->
      started = false

    kill: ->
      done = true

  $form.submit ->
    auto_save.kill()

  auto_save