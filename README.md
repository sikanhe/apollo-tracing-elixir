# ApolloTracing (for Elixir)

ApolloTracing adds data to your GraphQL query response so that an Apollo Engine can provide insights into your [Absinthe](http://absinthe-graphql.org)-based GraphQL service.

## Supported Apollo Features

- [Performance Tracing](https://www.apollographql.com/docs/engine/performance.html)
- [Response Caching](https://www.apollographql.com/docs/engine/caching.html)

## Installation

Add `:apollo_tracing` to your deps
```elixir
def deps do
  [
    {:apollo_tracing, "~> 0.4.0"}
  ]
end
```

## Usage

### Register the Middlewares

*ApolloTracing uses the Absinthe's middleware functionality to track field-level resolution times. In order to register our custom middleware, you have a few options:*

**Add `use ApolloTracing` to your schema file:**

```elixir
def MyApp.Schema do
  use Absinthe.Schema
  use ApolloTracing
end
```

**If you have a custom middleware stack, add the apollo tracing middlewares to the beginning of your middleware stack:**

```elixir
def middleware(middleware, _field, _object),
  do: [ApolloTracing.Middleware.Tracing, ApolloTracing.Middleware.Caching] ++ [...your other middlewares]
```

**If you prefer to only add tracing to some fields, you can selectively add tracing information:**

```elixir
field :selected_field, :string do
  middleware ApolloTracing.Middleware # Has to be the first middleware
  resolve fn _, _ -> {:ok, "this field is now added to be traced"} end
end
```

### Register the Pipeline

*ApolloTracing currently requires you to use a custom Pipeline in order to register 'Phases' in the correct order during resolution. Phases are used for measuring overall query times as well as appending the custom data to the response (including cache hints).*

**Specify the pipeline in your Absinthe.Plug endpoint:**

```elixir
forward "/graphql", Absinthe.Plug,
  schema: MyApp.Schema,
  pipeline: {ApolloTracing.Pipeline, :plug}
```

**If you have your own pipeline function, you can add the phases directly:**

```elixir
def my_pipeline_creator(config, pipeline_opts) do
  config.schema_mod
  |> Absinthe.Pipeline.for_document(pipeline_opts)
  |> add_my_phases() # w.e your custom phases are
  |> ApolloTracing.Pipeline.add_phases() # Add apollo at the end
end
```

**When you want to just call run a query with tracing, but without going through a Plug endpoint:**

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
```

### Add Cache Metadata

**You can configure caching by adding metadata to your Absinthe objects:**

```elixir
object :user do
  meta :cache, max_age: 30
end

# or

object :user, meta: [max_age: 30] do
  # ...
end
```

**To ensure that the object is not cached across users, you can mark it as private:**

```elixir
object :user do
  meta :cache, max_age: 30, scope: :private
end
```

See the [Apollo docs](https://www.apollographql.com/docs/engine/caching.html#hints-to-schema) for more information about cache scope.
