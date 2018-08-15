module ApplicationHelper

  def sign_up_button(plan:, color: "ffa500")
    link_to "Get Started", signin_path(plan_type: plan),
                           class: "button primary",
                           style: "background-color: ##{color} !important;"
  end

  def upgrade_or_downgrade_button(plan:, on_color: "ffa500", current_color: "2787cd")
    on_plan = plan_compare(to: plan)

    if on_plan != 'Current'
      link_to on_plan, "#", data: { id: plan },
                            class: "button primary continue-change",
                            style: "background-color: ##{on_color}"
    else
      content_tag :span, data: { id: plan },
                         class: "button primary continue-change",
                         style: "background-color: ##{current_color}" do
                           on_plan
                         end

    end
  end

  def plan_responses_limit
    case current_user.subscription.plan_type
    when "free"
      "2"
    when "professional"
      "6"
    else
      "unlimited"
    end
  end

  def free_plan_compare
    { free: "Current", professional: "Upgrade", unlimited: "Upgrade" }
  end

  def professional_plan_compare
    { free: "Downgrade", professional: "Current", unlimited: "Upgrade" }
  end

  def unlimited_plan_compare
    { free: "Downgrade", professional: "Downgrade", unlimited: "Current" }
  end

  def plan_compare(to:)
    current_user.reload
    subscription = current_user.try(:subscription)
    to = to.to_sym
    if subscription.present?
      case subscription.try(:plan_type).try(:to_sym)
      when :free
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

  def active_class(array)
    return unless array.include?(request.path)

    "active"
  end

  def button_to_add_fields(name, f, association)
    #begin f.object.class.reflect_on_association(association).klass.new
    new_object = f.object.class.reflect_on_association(association).klass.new
    #rescue
    # 	new_object = f.object.approvers.first.class.reflect_on_association(association).klass.new
    # end
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_form", :f => builder)
    end
    button_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class=>"button secondary small")
  end

  def button_to_function(name, function=nil, html_options={})
    message = "button_to_function is deprecated and will be removed from Rails 4.1. We recommend using Unobtrusive JavaScript instead. " +
        "See http://guides.rubyonrails.org/working_with_javascript_in_rails.html#unobtrusive-javascript"
    ActiveSupport::Deprecation.warn message

    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function};"

    tag(:input, html_options.merge(:type => "button", :value => name, :onclick => onclick))
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {sort: column, direction: direction}, {class: css_class}
  end

  class BraintreeFormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::TagHelper

    def initialize(object_name, object, template, options, proc)
      super
      @braintree_params = @options[:params]
      @braintree_errors = @options[:errors]
    end

    def fields_for(record_name, *args, &block)
      options = args.extract_options!
      options[:builder] = BraintreeFormBuilder
      options[:params] = @braintree_params && @braintree_params[record_name]
      options[:errors] = @braintree_errors && @braintree_errors.for(record_name)
      new_args = args + [options]
      super record_name, *new_args, &block
    end

    def text_field(method, options = {})
      has_errors = @braintree_errors && @braintree_errors.on(method).any?
      field = super(method, options.merge(:value => determine_value(method)))
      result = content_tag("div", field, :class => has_errors ? "fieldWithErrors" : "")
      result.safe_concat validation_errors(method)
      result
    end

    protected

    def determine_value(method)
      @braintree_params[method] if @braintree_params
    end

    def validation_errors(method)
      if @braintree_errors && @braintree_errors.on(method).any?
        @braintree_errors.on(method).map do |error|
          content_tag("div", ERB::Util.h(error.message), {style: "color: red;"})
        end.join
      else
        ""
      end
    end
  end
end
