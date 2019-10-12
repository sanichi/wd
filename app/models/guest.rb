class Guest
  def id
    0
  end

  def role
    "guest"
  end

  def first_name
    "Dummy"
  end

  def last_name
    "McDummy"
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
