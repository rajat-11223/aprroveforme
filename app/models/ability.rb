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
    return unless user.has_role? :admin
    can :manage, :all
  end

  def standard_user_permissions
    can [:read, :approve, :decline], Approval, approvers: { email: user.email }
    can [:read, :approve, :decline], Approval, approvers: { email: user.second_email }

    can [:read, :create, :update], Subscription, user_id: user.id
    can [:read], SubscriptionHistory, user_id: user.id
    can :manage, Approval, owner: user.id
    can :manage, User, id: user.id
  end
end
