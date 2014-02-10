class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.is_super_admin?
      can :manage, Entity
      can :manage, User
      can :manage, Version
    elsif user.is_admin?
      can :manage, Building
      can :manage, Department
      can :manage, User
      can :manage, Account
      can :manage, Auxiliary
      can :manage, Asset
      can :index, :dbf
      can :import, :dbf
    end
  end
end
