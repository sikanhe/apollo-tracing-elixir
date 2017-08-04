defmodule ApolloTracing.Middleware do
  @moduledoc """
  Documentation for ApolloTracing.
  """

  alias ApolloTracing.{Schema, Schema.Execution, Schema.Execution.Resolver}
  alias Absinthe.Resolution

  defp get_time,
    do: System.monotonic_time(:nanosecond)

  # Called before resolving
  def call(%Resolution{state: :unresolved} = res, _config) do
    %{acc: %{
      apollo_tracing: %Schema{
        start_mono_time: start_mono_time,
        execution: %Execution{resolvers: resolvers_so_far}
      }
    }} = res

    now = get_time()
    start_offset = now - start_mono_time

    resolver = %Resolver{
      path: Absinthe.Resolution.path(res),
      parent_type: res.parent_type.name,
      field_name: res.definition.name,
      return_type: res.definition.schema_node.type,
      start_offset: start_offset,
      duration: nil
    }

    res = put_in(
      res.acc.apollo_tracing.execution.resolvers,
      [resolver | resolvers_so_far]
    )

    %{res | middleware:
       res.middleware ++ [{{__MODULE__, :after_field}, [start_time: now]}]
     }
  end

  # Called after each resolution to calculate the duration
  def after_field(%Resolution{state: :resolved} = res, [start_time: start_time]) do
    %{acc: %{
      apollo_tracing: %Schema{
        execution: %Execution{resolvers: [resolver | prev_resolvers]}
      }
    }} = res

    updated_resolver = %Resolver{resolver |
      duration: get_time() - start_time
    }

    put_in(res.acc.apollo_tracing.execution.resolvers, [updated_resolver | prev_resolvers])
  end
end
