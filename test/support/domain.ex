defmodule AshSanity.Test.Domain do
  @moduledoc false
  use Ash.Domain

  resources do
    resource(AshSanity.Test.Post)
    resource(AshSanity.Test.Comment)
    resource(AshSanity.Test.User)
    resource(AshSanity.Test.Image)
    resource(AshSanity.Test.IdentityFilter)
  end
end
