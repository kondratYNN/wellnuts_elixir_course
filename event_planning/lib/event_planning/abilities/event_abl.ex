alias EventPlanning.Event
alias EventPlanning.Repo
alias EventPlanning.User

defimpl Ability, for: Event do
  def can?(event, _action, current_user) do
    user = Repo.get!(User, current_user.id)
    if user.role == "user" do
      event.user_id == user.id
    else
      true
    end
  end
end
