defmodule ApolloTracer.Phase.AddCacheHints do
  use Absinthe.Phase

  def run(bp, _options \\ []) do
    cache_control_hints = hints(bp.execution.acc.apollo_tracing.execution.resolvers, [])
    acc = Map.put(bp.execution.acc, :apollo_caching, %{version: 1, hints: cache_control_hints})
    {:ok, put_in(bp.execution.acc, acc)}
  end

  defp hints([], result), do: result
  defp hints([%{meta: meta, path: path} | tail], result) do
    meta
    |> Map.get(:cache, [])
    |> Enum.into(%{})
    |> hint(path)
    |> case do
      nil -> hints(tail, result)
      h -> hints(tail, [h | result])
    end
  end

  defp hint(%{max_age: max_age} = hint, path) do
    scope = if Map.get(hint, :scope) == :private, do: "PRIVATE", else: "PUBLIC"
    paths = Enum.filter(path, &(is_bitstring(&1)))
    %{path: paths, maxAge: max_age, scope: scope}
  end
  defp hint(_, _), do: nil
end
