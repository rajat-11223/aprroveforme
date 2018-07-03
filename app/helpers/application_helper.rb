module ApplicationHelper

  def plan_responses_limit
    if current_user.subscription.plan_type == 'free'
      '2'
    elsif current_user.subscription.plan_type == 'professional'
      '6'
    else
      'unlimited'
    end
  end

  def free_plan_compare
    if !Subscription.find_by_user_id(current_user.id).nil?
      if Subscription.find_by_user_id(current_user.id).plan_type == "free"
        'Current'
      elsif Subscription.find_by_user_id(current_user.id).plan_type == "professional"
        'Downgrade'
      elsif Subscription.find_by_user_id(current_user.id).plan_type == "unlimited"
        'Downgrade'
      end
    else
      'Get Started'
    end
  end

  def pro_plan_compare
    if !Subscription.find_by_user_id(current_user.id).nil?
      if Subscription.find_by_user_id(current_user.id).plan_type == "professional"
        'Current'
      elsif Subscription.find_by_user_id(current_user.id).plan_type == "unlimited"
        'Downgrade'
      else
        'Upgrade'
      end
    else
      'Get Started'
    end
  end

  def unlimited_plan_compare
    if !Subscription.find_by_user_id(current_user.id).nil?
      if Subscription.find_by_user_id(current_user.id).plan_type == "unlimited"
        'Current'
      elsif Subscription.find_by_user_id(current_user.id).plan_type == "professional"
        'Upgrade'
      else
        'Upgrade'
      end
    else
      'Get Started'
    end
  end

  def continue_permission_decider(id)
    if id == 'free'
      free_plan_compare
    elsif id == 'professional'
      pro_plan_compare
    else
      unlimited_plan_compare
    end
  end

  def active_class(array)
    array.include?(request.path) ? 'active' : ''
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

    tag(:input, html_options.merge(:type => 'button', :value => name, :onclick => onclick))
  end

  def gateway
    @gateway ||= Braintree::Gateway.new(
        :environment => :sandbox,
        :merchant_id => '896h6fqr23smp2ny',
        :public_key => 'swc9g7ffxxfgdb8b',
        :private_key => 'bde545bb49e6ecbd4831b38d19e0faf3',
        )
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
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
          content_tag("div", ERB::Util.h(error.message), {:style => "color: red;"})
        end.join
      else
        ""
      end
    end
  end
end
