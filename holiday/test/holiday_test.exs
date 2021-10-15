defmodule HolidayTest do
  use ExUnit.Case
  # doctest Holiday

  test "is_holiday/2 with holiday day" do
    db = Holiday.init_db()
    assert Holiday.is_holiday(db, ~D[2020-12-25]) == true
  end

  test "is_holiday/2 with not holiday day" do
    refute Holiday.is_holiday(Holiday.init_db(), ~D[2020-12-26]) == true
  end

  test "time_until_holiday/3 with holiday day" do
    assert Holiday.time_until_holiday(Holiday.init_db(), ~U[2021-12-25 00:00:00Z], :day) == 0
  end

  test "time_until_holiday/3 with day before Christmas(day)" do
    assert Holiday.time_until_holiday(Holiday.init_db(), ~U[2021-12-24 00:00:00Z], :day) == 1
  end

  test "time_until_holiday/3 with day before Christmas(hours)" do
    assert Holiday.time_until_holiday(Holiday.init_db(), ~U[2021-12-24 01:00:00Z], :hour) == 23
  end
end
