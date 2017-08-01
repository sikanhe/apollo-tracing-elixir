# ApolloTracing

## Installation

Add `:apollo_tracing` to your deps
```elixir
def deps do
  [
    {:apollo_tracing, "~> 0.1.0"}
  ]
end
```

## Usage

To add tracing to your graphql schema, add ApolloTracing.Middleware as the
first middleware of your middleware stack:
```elixir
def middleware(middlewares, field, object) do
  [ApolloTracing.Middleware | ...your other middlewares]
end
```

If you have no custom middleware callback, you can simply add `use ApolloTracing` to your schema file:

```elixir
def MyApp.Schema do
  use Absinthe.Schema
  use ApolloTracing
end
```

After adding the middleware, then you want to  modify Absinthe pipeline to ApolloTracing's custom pipeline before executing queries.

## Modifying pipeline with Plug

To add the pipeline to your Absinthe.Plug endpoint, you can simpley use the :pipeline option:

```elixir
forward "/graphql", Absinthe.Plug,
  schema: MyApp.Schema,
  pipeline: {ApolloTracing.Pipeline, :plug}
```

If you have your own pipeline function, you can use
ApolloTracing.Pipeline.add_phases(pipeline) function to added the phases to your pipeline before passing it to Absinthe.Plug.

```elixir
def my_pipeline_creator(config, opts) do
  config.schema_mod
  |> add_my_phases()
  |> ApolloTracing.Pipeline.add_phases()
end
```

### Adding pipeline to `Absinthe.run`
When you want to just call run a query with tracing, but without going through a Plug endpoint,
you can build the pipeline with `ApolloTracing.Pipeline.default(schema, opts)`
and pass that to `Absinthe.Pipeline.run`

```elixir
def custom_absinthe_runner(query, opts \\ []) do
  pipeline = ApolloTracing.Pipeline.default(YourSchema, opts)
  case Absinthe.Pipeline.run(query, pipeline) do
    {:ok, %{result: result}, _} -> {:ok, result}
    {:error, err, _} -> {:ok, err}
  end
end

"""
  query {
    fielda
    fieldb
  }
"""
|> custom_absinthe_runner()