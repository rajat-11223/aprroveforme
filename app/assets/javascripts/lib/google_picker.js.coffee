# Create and render a Picker object
ApproveForMe.google.createFilePicker = ->
  view = new (google.picker.DocsView)(google.picker.ViewId.DOCS)
  view.setMode google.picker.DocsViewMode.LIST

  (new (google.picker.PickerBuilder)).
    setAppId(gon.googleAppId).
    setOAuthToken(gon.googleUserToken).
    addView(view).
    addView(new (google.picker.DocsUploadView)).
    setCallback(ApproveForMe.google.pickerCallback).
    build().
    setVisible true

# A simple callback implementation.
ApproveForMe.google.pickerCallback = (data) ->
  url = "nothing"
  if data[google.picker.Response.ACTION] == google.picker.Action.PICKED
    doc = data[google.picker.Response.DOCUMENTS][0]
    url = doc[google.picker.Document.URL]
    title = doc.name
    id = doc.id
    type = doc.type
    embed = doc[google.picker.Document.EMBEDDABLE_URL]

  message = "<input id=\"approval_link\" name=\"approval[link]\" type=\"hidden\" value=\"#{url}\">"
  message = "#{message} <input id=\"approval_embed\" name=\"approval[embed]\" type=\"hidden\" value=\"#{embed}\">"
  message = "#{message} <input id=\"approval_link_title\" name=\"approval[link_title]\" type=\"hidden\" value=\"#{title}\">"
  message = "#{message} <input id=\"approval_link_id\" name=\"approval[link_id]\" type=\"hidden\" value=\"#{id}\">"
  message = "#{message} <input id=\"approval_link_type\" name=\"approval[link_type]\" type=\"hidden\" value=\"#{type}\">"
  # add HTML around this for title
  message = "#{message} <p class=\"form-file-name\">Filename: \"#{title}\"</p>"

  document.getElementById("result").innerHTML = message
  document.getElementById("file-selector").text = "Replace File"

  #!-- prefill the title field with the doc title
  myTextField = document.getElementById("result2")
  myTextField.value = title
  return

ApproveForMe.add_fields = (link, association, content) ->
  new_id = (new Date).getTime()
  regexp = new RegExp("new_#{association}", 'g')
  #document.body.insertBefore(content.replace(regexp, new_id), $("div#insert"));
  $("div.add").before content.replace(regexp, new_id)
  #$(link).before(content.replace(regexp, new_id));

google.load "picker", "1"
