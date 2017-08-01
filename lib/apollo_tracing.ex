defmodule ApolloTracing do
  @moduledoc """
  Documentation for ApolloTracing.
  """

  def version, do: 1

  defmacro __using__(_) do
    quote do
      def middleware(middleware, field, object) do
        [ApolloTracing.Middleware |
         Absinthe.Schema.ensure_middleware(middleware, field, object)]
      end
    end
  end
end
