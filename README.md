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

### The Happy Path

If you have no custom middleware callback and no custom pipeline, you can simply add `use ApolloTracing` to your schema file:

```elixir
def MyApp.Schema do
  use Absinthe.Schema
  use ApolloTracing
end
```

### Advanced

To add tracing to your custom middleware, add ApolloTracing.Middleware as the
first middleware of your middleware stack:
```elixir
def middleware(middlewares, field, object) do
  [ApolloTracing.Middleware | ...your other middlewares]
end
```

Note that you don't have to add tracing to all fields in your schema, like we did above. You could selectively add tracing information to the fields of your choice:

```elixir
field :selected_field, :string do
  middleware ApolloTracing.Middleware # Has to be the first middleware
  resolve fn _, _ -> {:ok, "this field is now added to be traced"} end
end
```

To add tracing to your custom pipeline, you want to modify Absinthe pipeline to ApolloTracing's custom pipeline before executing queries. In your `schema.ex`:

```elixir
def pipeline(phases) do
  phases
  |> ApolloTracing.Pipeline.add_phases()
end
```
