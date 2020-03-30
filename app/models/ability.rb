class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    if user.admin?
      can :manage, :all
      return
    end

    can :read, Blog, draft: false
    can :read, Blog, id: 40 # TEMPORARY
    can :read, Book
    can :read, Dragon
    can :read, Game
    can [:read, :contacts, :registration], Player

    if user.blogger?
      can :crud, Blog, user_id: user.id
      can :crud, Game, user_id: user.id
    end

    if user.librarian?
      can :crud, Book
    end

    if !user.guest?
      can :index, User
    end
  end
end
