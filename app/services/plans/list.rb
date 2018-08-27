module Plans
  class List
    def self.[] f
      load!
      @list[f]
    end

    def self.load!
      @list ||= new
    end

    def initialize
      load!
    end

    def [](f)
      @plans[f]
    end

    def ordered
      @plans.sort { |a, b| a.last["order"] <=> b.last["order"] }
    end

    private

    def load!
      path = Rails.root.join("config", "plan_data.yml")
      @yaml = YAML.load_file(path.to_s)
      @plans = @yaml[Rails.env]
    end
  end
end
