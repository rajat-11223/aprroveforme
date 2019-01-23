module EmailProcessorHelpers
  def build_email(attrs = {})
    details = {}
    if attrs[:to].present?
      attrs[:to].each do |u|
        details[:to] ||= []
        details[:to] << EmailExtractor.new(u).extract
      end
    end

    if attrs[:from].present?
      details[:from] = EmailExtractor.new(attrs[:from]).extract
    end

    build(:email, details)
  end

  def to_service(email_at)
    build_stubbed(:user, email: "#{email_at}@mail.approveforme.com")
  end

  class EmailExtractor
    def initialize(user)
      @user = user
    end

    def extract
      {full: "#{@user.name} <#{@user.email}>", email: @user.email, token: @user.email.split("@").first, host: @user.email.split("@").last, name: @user.name}
    end
  end

  def set_to_test_adapter(example)
    old_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test

    example.run

    ActiveJob::Base.queue_adapter = old_adapter
  end
end
