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
        cdn: true,
        perspective: "published"

  """

  @type t :: module

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias AshSanity.Query

      require Logger

      otp_app = opts[:otp_app] || raise("Must configure OTP app")
      @otp_app otp_app

      def all(query) do
        query_string = Query.build(query)

        {:ok, response} = request(query_string)

        Logger.debug("QUERY OK #{query_string}")

        response.body["result"]
      end

      defp request(query_string) do
        config =
          Application.get_env(@otp_app, __MODULE__, [])
          |> Keyword.put_new(:finch_mod, Finch)

        perspective = Keyword.get(config, :perspective, "published")

        config = Keyword.delete(config, :perspective)

        Sanity.query(query_string, %{}, perspective: perspective)
        |> Sanity.request(config)
      end
    end
  end
end
