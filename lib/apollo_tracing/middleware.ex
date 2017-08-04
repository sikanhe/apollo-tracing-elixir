defmodule ApolloTracing.Middleware do
  @moduledoc """
  Documentation for ApolloTracing.
  """

  alias ApolloTracing.{Schema, Schema.Execution, Schema.Execution.Resolver}
  alias Absinthe.Resolution

  # Called before resolving
  def call(%Resolution{state: :unresolved} = res, _config) do
    %{acc: %{
      apollo_tracing_start_time: start_mono_time,
      apollo_tracing: %Schema{
        execution: %Execution{resolvers: resolvers_so_far}
      }
    }} = res

    now = System.monotonic_time()
    resolver = %Resolver{
      path: Absinthe.Resolution.path(res),
      parentType: res.parent_type.name,
      fieldName: res.definition.name,
      returnType: res.definition.schema_node.type,
      startOffset: now - start_mono_time,
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
      duration: System.monotonic_time() - start_time
    }

    put_in(res.acc.apollo_tracing.execution.resolvers, [updated_resolver | prev_resolvers])
  end
end
