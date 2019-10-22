class Guest
  def id
    0
  end

  def handle
    "GG"
  end

  def roles
    ["guest"]
  end

  def first_name
    "Guest"
  end

  def last_name
    "Guest"
  end

  def guest?
    true
  end

  User::ALLOWED_ROLES.each do |role|
    define_method "#{role}?" do
      false
    end
  end
end
