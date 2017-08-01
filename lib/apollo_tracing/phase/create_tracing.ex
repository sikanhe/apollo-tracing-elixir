defmodule ApolloTracer.Phase.CreateTracing do
  use Absinthe.Phase

  def run(bp, _options \\ []) do
    tracing = %ApolloTracing.Schema{
      version: ApolloTracing.version(),
      start_mono_time: System.monotonic_time(:nanosecond),
      start_wall_time: DateTime.utc_now() |> DateTime.to_iso8601(),
      end_wall_time: nil,
      end_mono_time: nil,
      duration: nil,
      execution: %ApolloTracing.Schema.Execution{
        resolvers: []
      }
    }
    acc = Map.put(bp.resolution.acc, :apollo_tracing, tracing)
    {:ok, put_in(bp.resolution.acc, acc)}
  end
end