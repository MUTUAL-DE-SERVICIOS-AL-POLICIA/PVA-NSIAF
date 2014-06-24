class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.is_super_admin?
      can :manage, Entity
      can :manage, User
      cannot [:show, :update], User, id: user.id
    elsif user.is_admin?
      can :manage, Building
      can :manage, Department
      can :manage, User
      cannot [:show, :update], User, role: 'super_admin'
      can :manage, Account
      can :manage, Auxiliary
      can :manage, Asset
      can :manage, Decline
      can :manage, Proceeding
      can :manage, Material
      can :manage, Article
      can :manage, Request
      can [:index, :asset, :auxiliary, :pdf], :barcode
    end
    can [:index, :import], :dbf
    can :manage, Version
  end
end
