window.ApproveForMe =
  Pages: {}

  google: {}

  payments: {}

  init: ->
    null

  setPage: ->
    ApproveForMe.page.close() if ApproveForMe.page? && ApproveForMe.page.close

    pageClassName = $("body").data("page-name")
    page = ApproveForMe.Pages[pageClassName]
    if typeof page == "function"
      log("Loading page #{pageClassName} class")
      ApproveForMe.page = new page
    else
      log("Can't find #{pageClassName} class; loading default page")
      ApproveForMe.page = new ApproveForMe.Page

  expandOrCollapseById: (id) ->
    nav = document.getElementById(id)
    nav.classList.toggle("tw-hidden")