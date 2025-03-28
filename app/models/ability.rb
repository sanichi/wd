class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    if user.admin?
      can :manage, :all
      return
    end

    can [:home, :help], :page
    can :read, Blog, draft: false
    can :read, Dragon
    can :read, Game
    can :contacts, Player

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
