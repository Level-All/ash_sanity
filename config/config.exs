import Config

if Config.config_env() == :test do
  config :ash_sanity, ash_apis: [AshSanity.Test.Api]

  config :ash_sanity, AshSanity.TestCMS,
    project_id: "abc",
    dataset: "myset",
    token: "supersecret",
    cdn: false,
    finch_mod: AshSanity.MockFinch
end
