defmodule AshSanity.FinchBehavior do
  @moduledoc false
  @callback request(Finch.Request.t(), Finch.name(), keyword()) ::
              {:ok, Finch.Response.t()} | {:error, Mint.Types.error()}
end

Mox.defmock(AshSanity.MockFinch, for: AshSanity.FinchBehavior)
