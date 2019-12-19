class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    if user.admin?
      can :manage, :all
      return
    end

    can [:home, :contacts, :help], Page
    can :read, Blog, draft: false
    can :read, Book
    can :read, Dragon
    can :read, Game
    can [:read, :registration], Player

    if user.blogger?
      can :crud, Blog, user_id: user.id
      can :crud, Game, user_id: user.id
    end

    if user.librarian?
      can :crud, Book
    end

    if !user.guest?
      can :index, User
      can :non_public, Page
    end
  end
end
