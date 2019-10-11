class Guest
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

  User::ROLES.each do |r|
    unless r == "guest"
      define_method "#{r}?" do
        false
      end
    end
  end
end
