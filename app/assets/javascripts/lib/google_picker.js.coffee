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
  if data[google.picker.Response.ACTION] == google.picker.Action.PICKED
    doc = data[google.picker.Response.DOCUMENTS][0]
    url = doc[google.picker.Document.URL]
    title = doc.name
    id = doc.id
    type = doc.type
    embed = doc[google.picker.Document.EMBEDDABLE_URL]

    document.getElementById("approval_link").value = url
    document.getElementById("approval_embed").value = embed
    document.getElementById("approval_link_title").value = title
    document.getElementById("approval_link_id").value = id
    document.getElementById("approval_link_type").value = type

    # Update the clickable link to the right of the file selector
    fileLink = "<a target=\"_blank\" href=\"#{url}\">#{title}</a>"
    document.getElementById("link-to-file").innerHTML = fileLink

    # prefill the title field with the document title
    document.getElementById("result2").value = title

    # Update file selector text
    document.getElementById("file-selector").text = "Replace File"

ApproveForMe.add_fields = (link, association, content) ->
  new_id = (new Date).getTime()
  regexp = new RegExp("new_#{association}", 'g')
  #document.body.insertBefore(content.replace(regexp, new_id), $("div#insert"));
  $("div.add").before content.replace(regexp, new_id)
  #$(link).before(content.replace(regexp, new_id));

google.load "picker", "1"
