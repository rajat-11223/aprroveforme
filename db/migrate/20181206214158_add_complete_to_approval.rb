class AddCompleteToApproval < ActiveRecord::Migration[5.2]
  def change
    add_column :approvals, :complete, :bool, default: false
    Approval.all.find_each do |approval|
      if approval.is_completable?
        approval.mark_as_complete!
      end

      print "."
    end
  end
end
