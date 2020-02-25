ApproveForMe.ApprovalValidator =
  submit: (e) ->
    e.preventDefault()
    self = ApproveForMe.ApprovalValidator

    $target = $(e.target)

    $("#errors.callout").hide()

    is_valid =
      self.requireValue($target, "#result input#approval_link", "a#google-file-picker", "Select a file from Google drive") &&
      self.requireValue($target, "#result input#approval_embed", "a#google-file-picker", "Select a file from Google drive") &&
      self.requireValue($target, "input#result2", null, "Select a title") &&
      self.requireValue($target, "input.flatpickr-input", "input.flatpickr-input", "Select a date for the approval to be completed") &&
      self.requireAtLeastOneApprover($target, "Needs at least one approver") &&
      self.requireAllApprovers($target, "All approvers need a name and email address")

    if is_valid
      true
    else
      setTimeout(self.finishFormProgressBar, 300)
      false

  finishFormProgressBar: () ->
    Turbolinks.controller.adapter.progressBar.setValue(10000)
    Turbolinks.controller.adapter.progressBar.hide()

  requireValue: (base, validationSelect, focusSelector, message) ->
    self = ApproveForMe.ApprovalValidator
    target = base.find(validationSelect)

    if (target.val().trim() == "")
      target = base.find(focusSelector) if focusSelector

      self.showFlash(message)
      target.focus()
      return false
    else
      return true

  focusFirstApproverFieldWithNoValue: (base) ->
    fields = base.find("input.approvers-input").toArray()

    for f in fields
      $f = $(f)

      if $f.val() == ""
        console.log("Focus on #{$f.attr('name')}")
        $f.focus()

      return

  approversFor: (base) ->
    baseFields =
      base.find("input.approvers-input").serializeArray().map (input) ->
        obj = {}
        fieldName = input.name.split("[").pop().split("]").shift()
        value = input.value

        obj[fieldName] = value

        obj

    index = 0
    finalFields = []

    while index < baseFields.length
      throw new Error("unknown order") if !baseFields[index].hasOwnProperty("name")
      throw new Error("unknown order") if !baseFields[index + 1].hasOwnProperty("email")

      finalFields.push({
        name: baseFields[index].name,
        email: baseFields[index + 1].email,
      })

      index = index + 2

    finalFields

  requireAtLeastOneApprover: (base, message) =>
    self = ApproveForMe.ApprovalValidator
    is_valid = false

    for approver in self.approversFor(base)
      if (approver.name != "" && approver.email != "")
        is_valid = true

    self.showFlash(message)
    self.focusFirstApproverFieldWithNoValue(base) if !is_valid

    is_valid

  requireAllApprovers: (base, message) =>
    self = ApproveForMe.ApprovalValidator
    is_valid = true

    for approver in self.approversFor(base)
      if (approver.name == "" && !approver.email == "") || (approver.name != "" && approver.email == "")
        is_valid = false

    self.showFlash(message)
    self.focusFirstApproverFieldWithNoValue(base) if !is_valid

    is_valid

  showFlash: (message) ->
    if message
      $("#errors.callout p").text(message)
      $("#errors.callout").show()