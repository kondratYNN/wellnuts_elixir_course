alias EventPlanning.User

defimpl Ability, for: User do
  def can?(%User{}, action, current_user) do
    if action == :delete do
      current_user.role == "admin"
    else
      true
    end
  end
end
