defmodule AshSanity.Test.Api do
  @moduledoc false
  use Ash.Api

  resources do
    resource(AshSanity.Test.Post)
  end
end
