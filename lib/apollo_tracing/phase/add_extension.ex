defmodule ApolloTracer.Phase.AddExtension do
  use Absinthe.Phase

  def run(bp, _options \\ []) do
    extensions = Map.get(bp.result, :extensions, %{})
                 |> Map.put(:tracing, bp.execution.acc.apollo_tracing)
                 |> Map.put(:cacheControl, bp.execution.acc.apollo_caching)
    result = Map.put(bp.result, :extensions, extensions)
    {:ok, %{bp | result: result}}
  end
end
