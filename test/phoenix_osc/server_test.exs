defmodule Phoenix.OSC.ServerTest do
  use ExUnit.Case
  # doctest Phoenix.Osc.Server

  defmodule Endpoint do
    def config(:osc_udp_port), do: 8111
    def broadcast! topic, event, data do
      send :test_pid, {topic, event, data}
    end
  end

  setup do
    Process.register self, :test_pid
    here = self()
    {:ok, pid} = Phoenix.OSC.Server.start_link Endpoint
    {:ok, %{server: pid}}
  end

  test "it broadcasts OSC messages received over UDP", %{server: server} do
    msg = <<"/topic/event", 0, ",ii", 0, 1000 :: signed-big-size(32), 16 :: signed-big-size(32)>>
    # assert {"/ab", [{:osc_integer, 1000}, {:osc_integer, 16}]} = OSC.Message.parse(msg)
    send server, {:udp, 1, 2, 3, msg}
    assert_receive  {"topic", "event", %{"event" => [1000, 16]}}

    msg = <<"/topic/event", 0, ",if", 0, 20 :: signed-big-size(32), 0x43dc0000 :: size(32)>>

    send server, {:udp, 1, 2, 3, msg}
    assert_receive  {"topic", "event", %{"event" => [20, float_value]}}
    assert_in_delta 440.0, float_value, 0.001
  end



end
