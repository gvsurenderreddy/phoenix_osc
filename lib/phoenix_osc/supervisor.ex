defmodule Phoenix.OSC.Supervisor do
  use Supervisor

  def start_link(scheme, endpoint, config) do
    Supervisor.start_link __MODULE__, {scheme, endpoint, config}
  end

  def init {scheme, endpoint, config} do
    children = [
      Phoenix.Endpoint.CowboyHandler.child_spec(scheme, endpoint, config),
      worker(Phoenix.OSC.Server, [endpoint])
    ]
    supervise children, strategy: :one_for_one
  end

end
