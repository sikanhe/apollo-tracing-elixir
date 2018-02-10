defmodule ApolloTracing do
  @moduledoc """
  Documentation for ApolloTracing.
  """

  def version, do: 1

  defmacro __using__(_) do
    quote do
      def middleware(middleware, _, %{identifier: :subscription}), do: middleware
      def middleware(middleware, _, %{identifier: :mutation}),
        do: [ApolloTracing.Middleware.Tracing] ++ middleware
      def middleware(middleware, _, _),
        do: [ApolloTracing.Middleware.Tracing, ApolloTracing.Middleware.Caching] ++ middleware
    end
  end
end
