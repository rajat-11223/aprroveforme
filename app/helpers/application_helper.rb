module ApplicationHelper
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

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

end
