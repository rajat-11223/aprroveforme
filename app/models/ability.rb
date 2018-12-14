class Ability
  include CanCan::Ability

  class DoneProcessing < StandardError; end

  def initialize(user)
    @user = user || User.new # guest user (not logged in)

    everyone_permissions
    guest_permissions
    admin_permissions
    standard_user_permissions
  rescue DoneProcessing
  end

  private

  attr_reader :user

  def everyone_permissions
    can :read, :homepage
  end

  def guest_permissions
    return if user.persisted?

    raise DoneProcessing
  end

  def admin_permissions
    return if !user.has_role?(:admin)

    can :manage, ActiveAdmin::Page
    can :manage, :all
  end

  def standard_user_permissions
    can [:create, :read], SubscriptionHistory, user_id: user.id

    # Approvals I am an approver on
    can [:approve, :decline], Approval, approvers: {email: user.email}

    # Approvals I own
    can :manage, Approval, owner: user.id, completed_at: nil
    can [:read, :clone], Approval, owner: user.id

    can [:create, :read, :update], User, id: user.id
  end
end
