alias EventPlanning.Event

defimpl Ability, for: Event do
  def can?(event, _action, current_user) do
    if current_user.role == "user" do
      event.user_id == current_user.id
    else
      true
    end
  end
end
