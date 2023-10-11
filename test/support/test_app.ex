defmodule AshSanity.TestApp do
  @moduledoc false
  def start(_type, _args) do
    children = [
      AshSanity.TestCMS
    ]

    opts = [strategy: :one_for_one, name: AshSanity.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
