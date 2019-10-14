# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    if user.admin?
      can :manage, :all
      return
    end

    can :read, Blog, draft: false

    if user.blogger?
      can :crud, Blog, user_id: user.id
    end

    if !user.guest?
      can :index, User
    end
  end
end
