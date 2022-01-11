defmodule HolidaysTest do
  use ExUnit.Case

  test "is_holiday/1 with holiday day" do
    assert Holidays.is_holiday(~D[2021-12-25]) == true
  end

  test "is_holiday/1 with not holiday day" do
    refute Holidays.is_holiday(~D[2021-12-26]) == true
  end

  test "time_until_holiday/2 with holiday day" do
    assert Holidays.time_until_holiday(~U[2021-12-25 00:00:00Z], :day) == 0
  end

  test "time_until_holiday/2 with day before Christmas(day)" do
    assert Holidays.time_until_holiday(~U[2021-12-24 00:00:00Z], :day) == 1
  end

  test "time_until_holiday/2 with day before Christmas(hours)" do
    assert Holidays.time_until_holiday(~U[2021-12-24 01:00:00Z], :hour) == 23
  end
end
