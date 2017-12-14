defmodule ApolloTracingTest do
  use ExUnit.Case
  doctest ApolloTracing

  defmodule TestSchema do
    use Absinthe.Schema
    use ApolloTracing

    object :person do
      field :name, :string
      field :age, non_null(:integer)
    end

    query do
      field :get_person, list_of(non_null(:person)) do
        resolve fn _, _ ->
          {:ok, [%{name: "sikan", age: 20}]}
        end
      end
    end
  end

  setup_all do
    result = """
      query {
        getPerson { name age }
      }
    """
    |> Absinthe.run(TestSchema)
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
    assert result.extensions.tracing.startTime
    assert result.extensions.tracing.endTime
    assert result.extensions.tracing.duration
  end

  test "should have 3 resolvers", %{result: result} do
    assert (length result.extensions.tracing.execution.resolvers) == 3
  end

  test "each resolver should have path, start_offset and duration", %{result: result} do
    for resolver <- result.extensions.tracing.execution.resolvers do
      assert resolver.path
      assert resolver.startOffset
      assert resolver.duration
    end
  end

  test "should raise when trying to use Plug pipeline without plug loaded" do
    assert_raise RuntimeError, fn -> ApolloTracing.Pipeline.plug(TestSchema) end
  end
end
