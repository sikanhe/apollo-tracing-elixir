defmodule ApolloTracer.Phase.AddExtension do
  use Absinthe.Phase

  def run(bp, _options \\ []) do
    extensions = Map.get(bp.result, :extensions, %{})

    extensions = case Map.get(bp.execution.acc, :apollo_tracing) do
      nil -> extensions
      tracing ->
        Map.put(extensions, :tracing, tracing)
    end

    extensions = case Map.get(bp.execution.acc, :apollo_caching) do
      nil -> extensions
      cache ->
        Map.put(extensions, :cacheControl, cache)
    end

    result = Map.put(bp.result, :extensions, extensions)

    {:ok, %{bp | result: result}}
  end
end
