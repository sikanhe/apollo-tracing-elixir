defmodule ApolloTracing.Middleware.Caching do
  @behaviour Absinthe.Middleware

  def call(res, _config) do
    path =
      res
      |> Absinthe.Resolution.path
      |> Enum.filter(&is_bitstring(&1))

    hint =
      res.schema
      |> Absinthe.Schema.lookup_type(res.definition.schema_node.type)
      |> Absinthe.Type.meta()
      |> Map.get(:cache, [])
      |> Enum.into(%{})
      |> put_in([:path], path)


    res.acc
    |> Map.get(:apollo_caching)
    |> case do
      %{hints: hints} ->
        put_in(res.acc.apollo_caching.hints, [hint | hints])
      _ ->
        acc =
          res.acc
          |> Map.put(:apollo_caching, %{hints: [hint]})
        %{res | acc: acc}
    end
  end
end
