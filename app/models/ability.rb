class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.is_super_admin?
      can :manage, Entity
      can :manage, User
      cannot [:show, :update], User, id: user.id
      can [:index, :import], :dbf
      can :manage, Version
      can :indice, :almacenes
    elsif user.is_admin?
      can :manage, Building
      can :manage, Department
      can :manage, User
      cannot [:show, :update], User do |user|
        %w(super_admin admin_store).include?(user.role)
      end
      can :manage, Account
      can :manage, Auxiliary
      can :manage, Asset
      can :manage, Proceeding
      can [:index, :account, :asset, :auxiliary, :load_data, :pdf], :barcode
      can :manage, Version
    elsif user.is_admin_store?
      can [:welcome, :show, :update], User, id: user.id
      can [:departments, :users], Asset
      can :manage, Article
      can :manage, Material
      can :manage, Request
      can :manage, Subarticle
      can :manage, NoteEntry
      can :manage, EntrySubarticle
      can [:index, :account, :asset, :auxiliary, :load_data, :pdf], :barcode
      can :manage, Building
      can :manage, Department
      can :manage, User
      cannot [:show, :update], User do |user|
        %w(super_admin admin).include?(user.role)
      end
      can :manage, Version
    else
      can [:show, :update], User, id: user.id
      can :index, :welcome
    end
  end
end
