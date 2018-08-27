window.ApproveForMe =
  Pages: {}

  google: {}

  payments: {}

  init: ->
    null

  setPage: ->
    ApproveForMe.page.close() if ApproveForMe.page? && ApproveForMe.page.close

    page = ApproveForMe.Pages[gon.pageName]
    if typeof page == "function"
      ApproveForMe.page = new page
    else
      log("Can't find #{gon.pageName} class; loading default page")
      ApproveForMe.page = new ApproveForMe.Page
