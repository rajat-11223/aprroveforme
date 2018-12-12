class Approval
  class StatusChecker
    def initialize(approval)
      @approval = approval
    end

    def should_be_completed?
      is_not_already_complete? &&
        (deadline_is_past? || all_have_responded?)
    end

    private

    attr_reader :approval

    def is_not_already_complete?
      !approval.complete?
    end

    def deadline_is_past?
      approval.deadline < Time.zone.now
    end

    def all_have_responded?
      approval.approvers.all?(&:has_responded?)
    end
  end
end
