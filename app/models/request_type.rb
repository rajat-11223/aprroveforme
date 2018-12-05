class RequestType < OpenStruct
  def self.available_options
    @available_options ||=
      [:approval, :confirmation].map { |o| self.send(o) }
  end

  def self.approval
    @approval ||=
      self.new({name: "Approval",
                affirming_text: "Approve",
                dissenting_text: "Decline"})
  end

  def self.confirmation
    @confirmation ||=
      self.new({name: "Confirmation",
                affirming_text: "Confirm",
                dissenting_text: "_",
                allow_dissenting: false})
  end

  def request_options
    @request_options ||= begin
      opts = []

      opts << ["approved", affirming_text]
      opts << ["declined", dissenting_text] if allow_dissenting?

      opts
    end
  end

  def request_text_options
    request_options.map(&:last)
  end

  def allow_dissenting?
    allow_dissenting
  end

  def allow_dissenting
    @table.fetch(:allow_dissenting, true)
  end

  def lower_name
    name.downcase
  end
end
