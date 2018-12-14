class AddRespondedAtToApprover < ActiveRecord::Migration[5.2]
  def up
    add_column :approvers, :responded_at, :datetime

    Approver.find_each do |approver|
      if !["declined", "approved"].include?(approver.status)
        print "."
        next
      else
        print "u"
      end

      approver.responded_at = approver.updated_at
      approver.save!(touch: false)
    end
  end

  def down
    remove_column :approvers, :responded_at
  end
end
