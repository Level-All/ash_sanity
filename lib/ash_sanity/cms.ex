defmodule AshSanity.CMS do
  @moduledoc """
  Defines a CMS.

  A CMS maps to an underlying Sanity instance.

  When used, the CMS expects the `:otp_app` 
  option. The `:otp_app` should point to an OTP application that has
  the CMS configuration. For example, the CMS:

      defmodule CMS do
        use AshSanity.CMS,
          otp_app: :my_app
      end

  Could be configured with:

      config :my_app, CMS,
        project_id: "my_project_id",
        dataset: "production",
        token: "my_sanity_api_token",
        cdn: true

  """

  @type t :: module

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias AshSanity.Query

      otp_app = opts[:otp_app] || raise("Must configure OTP app")
      @otp_app otp_app

      def all(query) do
        query_string = Query.build(query)

        {:ok, response} = request(query_string)

        response.body["result"]
      end

      defp request(query_string) do
        config = Application.get_env(@otp_app, __MODULE__, [])

        Sanity.query(query_string)
        |> Sanity.request(
          project_id: Keyword.get(config, :project_id),
          dataset: Keyword.get(config, :dataset),
          token: Keyword.get(config, :token),
          cdn: Keyword.get(config, :cdn),
          finch_mod: Keyword.get(config, :finch_mod, Finch)
        )
      end
    end
  end
end
