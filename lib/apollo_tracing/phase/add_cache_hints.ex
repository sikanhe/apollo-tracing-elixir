defmodule ApolloTracer.Phase.AddCacheHints do
  use Absinthe.Phase

  def run(bp, _options \\ []) do
    case get_in(bp.execution.acc, [:apollo_caching, :hints]) do
      nil ->
        {:ok, bp}
      found ->
        {:ok, put_in(bp.execution.acc.apollo_caching, %{version: 1, hints: hints(found, [])})}
    end
  end

  defp hints([], result), do: result

  defp hints([%{max_age: max_age, path: path} = head | tail], result) do
    hint(max_age, Map.get(head, :scope), path)
    |> case do
      nil -> hints(tail, result)
      h -> hints(tail, [h | result])
    end
  end
  defp hints([_ | tail], result), do: hints(tail, result)

  defp hint(nil, _, _), do: nil
  defp hint(max_age, :private, path), do: %{path: path, maxAge: max_age, scope: "PRIVATE"}
  defp hint(max_age, _, path), do: %{path: path, maxAge: max_age, scope: "PUBLIC"}
end
