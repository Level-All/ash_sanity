defmodule AshSanity.CMSCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      alias AshSanity.TestCMS

      import AshSanity.CMSCase
    end
  end
end
