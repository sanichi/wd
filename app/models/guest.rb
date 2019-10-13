class Guest
  def id
    0
  end

  def handle
    "GGG"
  end

  def role
    "guest"
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

  User::ALLOWED_ROLES.each do |r|
    define_method "#{r}?" do
      false
    end
  end
end
