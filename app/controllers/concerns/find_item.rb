module FindItem
  refine Array do
    def find_item(elem)
      each do |value|
        if value == elem
          return elem
        end
      end

      nil
    end
  end
end
