alias EventPlanning.User

defimpl Ability, for: User do
  alias EventPlanning.Repo

  def can?(%User{}, action, current_user) do
    user = Repo.get!(User, current_user.id)
    if action == :delete do
      user.role == "admin"
    else
      true
    end
  end
end
