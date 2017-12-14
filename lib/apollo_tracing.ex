defmodule ApolloTracing do
  @moduledoc """
  Documentation for ApolloTracing.
  """

  def version, do: 1

  defmacro __using__(_) do
    quote do
      def middleware(middleware, field, object) do
        [ApolloTracing.Middleware |
         Absinthe.Schema.__ensure_middleware__(middleware, field, object)]
      end

      def pipeline(phases) do
        phases
        |> ApolloTracing.Pipeline.add_phases()
      end
    end
  end
end
