module ApplicationHelper
  def turbolinks_cache_control_meta_tag
    tag :meta, name: "turbolinks-cache-control", content: @turbolinks_cache_control || "cache"
  end

  def body_tag(opts = {})
    options = {class: [controller_name, action_name].join(" "),
               data: {page_name: [controller_name, action_name].map(&:classify).join}}.merge(opts)
    content_tag(:body, options) do
      yield
    end
  end

  def sign_up_button(plan:)
    link_to "Get Started", signin_path(plan_name: plan[:name], plan_interval: plan[:interval], type: :signup),
            class: "tw-btn tw-bg-green hover:tw-bg-green-dark",
            data: {turbolinks: false}
  end

  def upgrade_or_downgrade_button(plan:)
    on_plan = plan_compare(to: plan[:name])

    if on_plan != "Current"
      link_to on_plan, "#", data: {name: plan[:name], interval: plan[:interval], type: :upgrade, turbolinks: false},
                            class: "tw-btn tw-bg-green hover:tw-bg-green-dark continue-change"
    else
      link_to "Current", dashboard_home_index_path,
              data: {name: plan[:name], interval: plan[:interval], type: :upgrade},
              class: "tw-btn tw-bg-green hover:tw-bg-green-dark"
    end
  end

  def plan_responses_limit
    PlanDetails.new(current_user).approval_limit_in_words
  end

  def free_plan_compare
    {lite: "Current", professional: "Upgrade", unlimited: "Upgrade"}
  end

  def professional_plan_compare
    {lite: "Downgrade", professional: "Current", unlimited: "Upgrade"}
  end

  def unlimited_plan_compare
    {lite: "Downgrade", professional: "Downgrade", unlimited: "Current"}
  end

  def plan_compare(to:)
    current_user.reload
    subscription = current_user.try(:subscription)
    to = to.to_sym
    if subscription.present?
      case subscription.try(:plan_name).try(:to_sym)
      when :lite
        free_plan_compare[to]
      when :professional
        professional_plan_compare[to]
      when :unlimited
        unlimited_plan_compare[to]
      else
        free_plan_compare[to]
      end
    else
      "Get Started"
    end
  end

  def active_class(paths)
    return unless Array(paths).include?(request.path)

    "active"
  end

  def button_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
      render("#{association.to_s.singularize}_form", f: builder)
    end
    button_to_function(name, %( ApproveForMe.add_fields(this, "#{association}", "#{escape_javascript(fields)}")), class: "button secondary small")
  end

  def button_to_function(name, function = nil, html_options = {})
    message = "button_to_function is deprecated and will be removed from Rails 4.1. We recommend using Unobtrusive JavaScript instead. " +
              "See http://guides.rubyonrails.org/working_with_javascript_in_rails.html#unobtrusive-javascript"
    ActiveSupport::Deprecation.warn message

    onclick = ""
    build_js_function(onclick, html_options[:onclick])
    build_js_function(onclick, function)

    tag(:input, html_options.merge(type: "button", value: name, onclick: onclick))
  end

  def build_js_function(str, func)
    return unless func.present?

    str << "#{func};"
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {sort: column, direction: direction}, {class: css_class}
  end

  def layout_style
    if @layout_style == :full
      ""
    else
      "grid-container content"
    end
  end

  def page_title
    app_title = t("app-title")
    short_app_title = t("app-title-short")
    if content_for?(:title)
      [app_title, content_for(:title).strip].join(" : ")
    elsif controller_name == "home"
      [short_app_title, action_name.titleize].join(" ")
    else
      [short_app_title, controller_name.titleize, action_name.titleize].join(" ")
    end
  end
end
