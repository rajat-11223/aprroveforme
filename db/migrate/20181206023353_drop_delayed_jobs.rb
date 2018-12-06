class DropDelayedJobs < ActiveRecord::Migration[5.2]
  def up
    drop_table :delayed_jobs
  end
end
