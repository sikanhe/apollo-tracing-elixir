defmodule ApolloTracer.Phase.AddExtension do
  use Absinthe.Phase

  def run(bp, _options \\ []) do
    result = Map.put(bp.result, :extensions, %{tracing: bp.execution.acc.apollo_tracing})
    {:ok, %{bp | result: result}}
  end
end
