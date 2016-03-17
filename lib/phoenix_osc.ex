defmodule Phoenix.OSC do
  @behaviour Phoenix.Handler

  import Supervisor.Spec

  def child_spec(scheme, endpoint, config) do
    supervisor(Phoenix.OSC.Supervisor, [scheme, endpoint, config])
  end
end
