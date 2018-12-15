module CapybaraHelpers
  def fill_in_datepicker(selector, value)
    page.execute_script("$('#{selector}').val('#{value}')")
  end
end
