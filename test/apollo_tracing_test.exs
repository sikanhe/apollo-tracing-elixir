defmodule SharedTestCase do
  defmacro define_tests(do: block) do
    quote do
      defmacro __using__(options) do
        block = unquote(Macro.escape(block))

        quote do
          use ExUnit.Case

          @moduletag unquote(options)
          unquote(block)
        end
      end
    end
  end
end

defmodule ApolloTracingSharedTests do
  import SharedTestCase

  define_tests do
    @query """
      query {
        getPerson {
          name
          age
          cars { make model }
        }
      }
    """

    def get_result(schema, query) do
      pipeline = ApolloTracing.Pipeline.default(schema, [])

      query
      |> Absinthe.Pipeline.run(pipeline)
      |> case do
        {:ok, %{result: result}, _} -> result
        error -> error
      end
    end

    test "should have :tracing in extension", %{schema: schema} do
      result = get_result(schema, @query)
      assert result.extensions.tracing
    end

    test "should have start and end times in tracing", %{schema: schema} do
      result = get_result(schema, @query)
      assert result.extensions.tracing.startTime
      assert result.extensions.tracing.endTime
      assert result.extensions.tracing.duration
    end

    test "should have 6 resolvers", %{schema: schema} do
      result = get_result(schema, @query)
      assert length(result.extensions.tracing.execution.resolvers) == 6
    end

    test "each resolver should have path, start_offset and duration", %{schema: schema} do
      result = get_result(schema, @query)

      for resolver <- result.extensions.tracing.execution.resolvers do
        assert resolver.path
        assert resolver.startOffset
        assert resolver.duration
      end
    end

    test "includes cache hints", %{schema: schema} do
      result = get_result(schema, @query)
      assert result.extensions.cacheControl.version == 1

      assert result.extensions.cacheControl.hints == [
               %{
                 path: ["getPerson"],
                 maxAge: 30,
                 scope: "PRIVATE"
               },
               %{
                 path: ["getPerson", "cars"],
                 maxAge: 600,
                 scope: "PUBLIC"
               }
             ]
    end
  end
end

defmodule ApolloTracingTest do
  defmodule TestSchema do
    use Absinthe.Schema
    use ApolloTracing

    object :person do
      meta(:cache, max_age: 30, scope: :private)

      field(:name, :string)
      field(:age, non_null(:integer))
      field(:cars, list_of(:car))
    end

    object :car do
      meta(:cache, max_age: 600)

      field(:make, non_null(:string))
      field(:model, non_null(:string))
    end

    query do
      field :get_person, list_of(non_null(:person)) do
        resolve(fn _, _ ->
          {:ok,
           [
             %{
               name: "sikan",
               age: 20,
               cars: [%{make: "Honda", model: "Accord"}]
             }
           ]}
        end)
      end
    end
  end

  use ApolloTracingSharedTests, schema: TestSchema
end

defmodule ApolloTracingInlineTest do
  defmodule TestSchema do
    use Absinthe.Schema
    use ApolloTracing

    object :person, meta: [cache: [max_age: 30, scope: :private]] do
      field(:name, :string)
      field(:age, non_null(:integer))
      field(:cars, list_of(:car))
    end

    object :car, meta: [cache: [max_age: 600]] do
      field(:make, non_null(:string))
      field(:model, non_null(:string))
    end

    query do
      field :get_person, list_of(non_null(:person)) do
        resolve(fn _, _ ->
          {:ok,
           [
             %{
               name: "sikan",
               age: 20,
               cars: [%{make: "Honda", model: "Accord"}]
             }
           ]}
        end)
      end
    end
  end

  use ApolloTracingSharedTests, schema: TestSchema
end
