defmodule Phoenix.OSC.Server do
  use GenServer
  require Logger

  @default_port 8000

  def start_link endpoint do
    GenServer.start_link __MODULE__, endpoint
  end

  def init(endpoint) do
    port = endpoint.config(:osc_udp_port) || @default_port
    {:ok, udp} = :gen_udp.open(port, [:binary, {:active, true}])
    Logger.info "Running #{inspect __MODULE__} on UDP port #{port}"
    {:ok, %{udp_socket: udp, endpoint: endpoint}}
  end

  def handle_info {:udp, _socket, _sender_ip, _sender_port, data}, state do
    broadcast state, OSC.Message.parse(data)
    {:noreply, state}
  end

  defp broadcast state, {addr, packets} do
    Logger.debug "||||| [Phoenix.OSC.Server] message addr: #{inspect addr} data: #{inspect packets} ||||||"
    [topic, event] = topic_event_from(addr)
    payload = %{event => Enum.map(packets, fn {osc_type, value}-> value end)}
    state.endpoint.broadcast! topic, event, payload
  end

  defp topic_event_from(<<?/, address :: binary>>), do: String.split(address, "/", parts: 2)

end
