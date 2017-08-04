defmodule ApolloTracer.Phase.CreateTracing do
  use Absinthe.Phase

  def run(bp, _options \\ []) do
    tracing = %ApolloTracing.Schema{
      version: ApolloTracing.version(),
      startTime: DateTime.utc_now() |> DateTime.to_iso8601(),
      endTime: nil,
      duration: nil,
      execution: %ApolloTracing.Schema.Execution{
        resolvers: []
      }
    }
    acc =
      bp.resolution.acc
      |> Map.put(:apollo_tracing, tracing)
      |> Map.put(:apollo_tracing_start_time, System.monotonic_time())
    {:ok, put_in(bp.resolution.acc, acc)}
  end
end