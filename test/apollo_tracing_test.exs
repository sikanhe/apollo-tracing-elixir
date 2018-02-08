defmodule ApolloTracingTest do
  use ExUnit.Case
  doctest ApolloTracing

  defmodule TestSchema do
    use Absinthe.Schema
    use ApolloTracing

    object :person do
      meta(:cache, max_age: 30, scope: :private)

      field :name, :string
      field :age, non_null(:integer)
      field :cars, list_of(:car)
    end

    object :car do
      meta(:cache, max_age: 600)

      field :make, non_null(:string)
      field :model, non_null(:string)
    end

    query do
      field :get_person, list_of(non_null(:person)) do
        resolve fn _, _ ->
          {:ok, [
            %{
              name: "sikan", age: 20,
              cars: [%{make: "Honda", model: "Accord"}]
            }
          ]}
        end
      end
    end
  end

  setup_all do
    pipeline = ApolloTracing.Pipeline.default(TestSchema, [])

    result =
    """
      query {
        getPerson {
          name
          age
          cars { make model }
        }
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
    assert result.extensions.tracing.startTime
    assert result.extensions.tracing.endTime
    assert result.extensions.tracing.duration
  end

  test "should have 6 resolvers", %{result: result} do
    assert (length result.extensions.tracing.execution.resolvers) == 6
  end

  test "each resolver should have path, start_offset and duration", %{result: result} do
    for resolver <- result.extensions.tracing.execution.resolvers do
      assert resolver.path
      assert resolver.startOffset
      assert resolver.duration
    end
  end

  test "includes cache hints", %{result: result} do
    assert result.extensions.cacheControl.version == 1
    assert result.extensions.cacheControl.hints == [
      %{
        "path": ["getPerson", "cars"],
        "maxAge": 600,
        "scope": "PUBLIC",
      },
      %{
        "path": ["getPerson"],
        "maxAge": 30,
        "scope": "PRIVATE",
      }
    ]
  end
end
