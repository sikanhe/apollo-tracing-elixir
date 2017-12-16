defmodule ApolloTracing.Middleware do
  @moduledoc """
  Documentation for ApolloTracing.
  """

  alias ApolloTracing.Schema.Execution.Resolver
  alias Absinthe.Resolution

  # Called before resolving
  # if there isn't an `ApolloTracing` flag set then we aren't actually doing any tracing
  def call(%Resolution{acc: %{apollo_tracing_start_time: start_mono_time}, state: :unresolved} = res, _config) do
    now = System.monotonic_time()
    resolver = %Resolver{
      path: Absinthe.Resolution.path(res),
      parentType: res.parent_type.name,
      fieldName: res.definition.name,
      returnType: Absinthe.Type.name(res.definition.schema_node.type, res.schema),
      startOffset: now - start_mono_time,
    }

    %{res |
      extensions: Map.put(res.extensions, __MODULE__, resolver),
      middleware: res.middleware ++ [{{__MODULE__, :after_field}, [start_time: now]}]
     }
  end
  def call(res, _) do
    res
  end

  # Called after each resolution to calculate the duration
  def after_field(%Resolution{state: :resolved} = res, [start_time: start_time]) do
    %{extensions: %{__MODULE__ => resolver}} = res

    updated_resolver = %Resolver{resolver |
      duration: System.monotonic_time() - start_time
    } |> Map.from_struct()

    update_in(res.acc.apollo_tracing.execution.resolvers, &[updated_resolver | &1])
  end
end
