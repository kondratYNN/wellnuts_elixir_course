defmodule EventPlanning.EventTest do
  use EventPlanning.DataCase, async: true

  test "incorrect repetition" do
    changeset =
      EventPlanning.Event.changeset(%EventPlanning.Event{}, %{
        date: ~U[2021-12-19 17:00:00Z],
        repetition: "aaaa"
      })

    assert %{repetition: ["is invalid"]} = errors_on(changeset)
  end

  test "incorrect date" do
    changeset =
      EventPlanning.Event.changeset(%EventPlanning.Event{}, %{
        date: nil,
        repetition: "day"
      })

    assert %{date: ["can't be blank"]} = errors_on(changeset)
  end

  test "correct event" do
    changeset =
      EventPlanning.Event.changeset(%EventPlanning.Event{}, %{
        date: ~U[2021-12-19 17:00:00Z],
        repetition: "day"
      })

    assert %{} = errors_on(changeset)
  end

end
