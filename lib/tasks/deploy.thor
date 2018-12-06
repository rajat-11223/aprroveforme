# frozen_string_literal: true

class Deploy < Thor
  include Thor::Actions

  desc "production", "deploys to production"
  method_option :force, type: :boolean, aliases: "-f"
  method_option :without_maintenance, type: :boolean, aliases: "-wm"

  def production
    heroku_snapshot :production
    deploy :production, options
    set_sha_and_branch :production
  end

  desc "staging", "deploys to staging"
  method_option :force, type: :boolean, aliases: "-f"
  method_option :without_maintenance, type: :boolean, aliases: "-wm"

  def staging
    copy_prod_to_staging
    deploy :staging, options
    set_sha_and_branch :staging
  end

  desc "all", "deploys to all environments"
  method_option :force, type: :boolean, aliases: "-f"
  method_option :without_maintenance, type: :boolean, aliases: "-wm"

  def all
    invoke "deploy:staging"
    invoke "deploy:production"
  end

  desc "copy_prod_to_staging", "copies production data to staging"

  def copy_prod_to_staging
    puts "Copy from production to staging"
    heroku_snapshot :production
    heroku "pg:copy #{app :production}::DATABASE DATABASE_URL --app #{app :staging} --confirm #{app :staging}", nil
  end

  desc "copy_prod_to_local", "copies production data to local"

  def copy_prod_to_local
    puts "Copy from production to local"

    dropdb local_db
    heroku "pg:pull DATABASE_URL #{local_db}", :production
    `bundle exec rails chore:clean_up_stripe_customers`
  end

  desc "copy_stg_to_local", "copies staging data to local"

  def copy_stg_to_local
    puts "Copy from staging to local"

    dropdb local_db
    heroku "pg:pull DATABASE_URL #{local_db}", :staging
    `bundle exec rails chore:clean_up_stripe_customers`
  end

  desc "snap_prod", "take a production snapshot"

  def snap_prod
    puts "take a production snapshot"
    heroku_snapshot :production
  end

  desc "snap_stag", "take a staging snapshot"

  def snap_stag
    puts "take a staging snapshot"
    heroku_snapshot :stag
  end

  desc "restart_stag", "restart staging"

  def restart_stag
    heroku "restart", :stag
  end

  desc "restart_stag", "restart production"

  def restart_prod
    heroku "restart", :production
  end

  private

  def deploy(stage, options)
    Bundler.with_clean_env do
      heroku "git:remote -a #{app stage}", stage

      force = "-f" if options["force"]
      with_maintenance = !options["without_maintenance"]

      run_with_maintenance(stage, with_maintenance) do
        heroku_scale_process(name: :worker, to: 0, stage: stage)
        run "git push #{force} #{stage} #{current_branch}:master"
        heroku_run "rails db:migrate", stage
        heroku_run "rails chore:clean_up_stripe_customers", stage

        case stage
        when :staging
          heroku_run "rails chore:clear_sidekiq_jobs", stage
        end

        # heroku_run "rails temporary:migrate_goal_status", stage
        heroku_scale_process(name: :worker, to: 1, stage: stage)
      end

      puts "Warming things up"
      run "curl -sI #{app_url stage} | grep Status"
    end
  end

  def set_sha_and_branch(stage, options = {})
    heroku "config:set CURRENT_SHA=\"#{current_sha}\" CURRENT_BRANCH=\"#{current_branch}\"", stage
  end

  def app(stage)
    if stage.to_sym == :production
      "approveforme"
    else
      "approveforme-#{stage}"
    end
  end

  def app_url(stage)
    "https://#{app stage}.herokuapp.com"
  end

  def current_branch
    @branch ||= (run "git rev-parse --symbolic-full-name --abbrev-ref HEAD", capture: true).strip
  end

  def current_sha
    @sha ||= (run "git log --oneline -1", capture: true).strip
  end

  def dropdb(db_name)
    run "dropdb #{db_name}"
  end

  def local_db
    "approveforme_development"
  end

  def run_with_maintenance(stage, with_maintenance)
    if with_maintenance
      puts "Turning maintenance mode on"
      heroku "maintenance:on", stage
    else
      puts "Running without maintenance mode"
      puts "Ctl-C to stop soon."
      sleep 3
    end

    yield
  ensure
    if with_maintenance
      puts "Turning off maintenance mode"
      heroku "maintenance:off", stage
    end
  end

  def heroku_run(cmd, stage)
    heroku "run #{cmd}", stage
  end

  def heroku_snapshot(stage)
    puts "Taking snapshot of #{stage}"
    heroku "pg:backups capture", stage
  end

  def heroku_scale_process(name:, to:, stage:)
    heroku "ps:scale #{name}=#{to}", stage
  end

  def heroku(cmd, stage)
    Bundler.with_clean_env do
      remote = "-r #{stage}" unless stage.nil?
      run "heroku #{cmd} #{remote}"
    end
  end
end
