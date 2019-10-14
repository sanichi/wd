# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    if user.blogger?
      can :manage, Blog, user_id: [user.id, nil]
    else
      can :read, Blog
    end

    if !user.guest?
      can :index, User
    end
  end
end
