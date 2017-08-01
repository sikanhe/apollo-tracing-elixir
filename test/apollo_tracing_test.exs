defmodule ApolloTracingTest do
  use ExUnit.Case
  doctest ApolloTracing

  defmodule TestSchema do
    use Absinthe.Schema

    object :person do
      field :name, :string
      field :age, :integer
    end

    query do
      field :get_person, list_of(:person) do
        resolve fn _, _ ->
          {:ok, [%{name: "sikan", age: 20}]}
        end
      end
    end

    def middleware(middleware, field, object) do
      [ApolloTracing.Middleware |
      Absinthe.Schema.ensure_middleware(middleware, field, object)]
    end
  end

  setup do
    pipeline = ApolloTracing.Pipeline.default(TestSchema, [])

    result =
    """
      query {
        getPerson { name age }
      }
    """
    |> Absinthe.Pipeline.run(pipeline)
    |> case do
      {:ok, %{result: result}, _} -> result
      error -> error
    end

    {:ok, %{result: result}}
  end

  test "should have :tracing in extension", %{result: result} do
    assert result.extensions.tracing
  end

  test "should have start and end times in tracing", %{result: result} do
    assert result.extensions.tracing.start_mono_time
    assert result.extensions.tracing.start_wall_time
    assert result.extensions.tracing.end_mono_time
    assert result.extensions.tracing.end_wall_time
  end

  test "should have 3 resolvers", %{result: result} do
    assert (length result.extensions.tracing.execution.resolvers) == 3
  end

  test "each resolver should have path, start_offset and duration", %{result: result} do
    for resolver <- result.extensions.tracing.execution.resolvers do
      assert resolver.path
      assert resolver.start_offset
      assert resolver.duration
    end
  end
end
