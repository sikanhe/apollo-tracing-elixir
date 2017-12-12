# ApolloTracing (for Elixir)

This package is used to collect and expose trace data in the Apollo Tracing format.

It relies on instrumenting a GraphQL schema to collect resolver timings, and exposes trace data for an individual request under extensions as part of the GraphQL response.

The extension format is work in progress, and we're collaborating with others in the GraphQL community to make it broadly available, and to build awesome tools on top of it.

One use of Apollo Tracing is to add support for [Apollo Optics](https://www.apollodata.com/optics/) to more GraphQL servers.


## Installation

Add `:apollo_tracing` to your deps
```elixir
def deps do
  [
    {:apollo_tracing, "~> 0.2.0"}
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

Note that you don't have to add tracing to all fields in your schema, like we did above. You could selectively add tracing information to the fields of your choice:

```elixir
field :selected_field, :string do
  middleware ApolloTracing.Middleware # Has to be the first middleware
  resolve fn _, _ -> {:ok, "this field is now added to be traced"} end
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
def my_pipeline_creator(config, pipeline_opts) do
  config.schema_mod
  |> Absinthe.Pipeline.for_document(pipeline_opts)
  |> add_my_phases() # w.e your custom phases are
  |> ApolloTracing.Pipeline.add_phases() # Add apollo at the end
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