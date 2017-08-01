defmodule ApolloTracer.Phase.AccumulateResult do
  use Absinthe.Phase

  def run(bp, _options \\ []) do
    %{apollo_tracing: apollo_tracing} = bp.resolution.acc
    end_mono_time = System.monotonic_time(:nanosecond)
    duration = end_mono_time - apollo_tracing.start_mono_time
    final_tracing = %{bp.resolution.acc.apollo_tracing |
      end_wall_time: DateTime.utc_now() |> DateTime.to_iso8601(),
      end_mono_time: end_mono_time,
      duration: duration,
      execution: %{resolvers: Enum.reverse(apollo_tracing.execution.resolvers)}
    }
    {:ok, put_in(bp.resolution.acc.apollo_tracing, final_tracing)}
  end
end