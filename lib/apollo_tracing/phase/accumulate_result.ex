defmodule ApolloTracer.Phase.AccumulateResult do
  use Absinthe.Phase

  def run(bp, _options \\ []) do
    %{apollo_tracing_start_time: start_mono_time,
      apollo_tracing: apollo_tracing}
      = bp.resolution.acc
    final_tracing = %{bp.resolution.acc.apollo_tracing |
      endTime: DateTime.utc_now() |> DateTime.to_iso8601(),
      duration: System.monotonic_time() - start_mono_time,
      execution: %{
        resolvers: Enum.reverse(apollo_tracing.execution.resolvers)
      }
    } |> Map.from_struct()
    {:ok, put_in(bp.resolution.acc.apollo_tracing, final_tracing)}
  end
end