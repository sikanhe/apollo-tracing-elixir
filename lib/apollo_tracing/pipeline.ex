defmodule ApolloTracing.Pipeline do
  def add_phases(pipeline) do
    pipeline
    |> Absinthe.Pipeline.insert_after(
      Absinthe.Phase.Blueprint,
      ApolloTracer.Phase.CreateTracing
    )
    |> Absinthe.Pipeline.insert_before(
      Absinthe.Phase.Document.Result,
      ApolloTracer.Phase.AccumulateResult
    )
    |> Absinthe.Pipeline.insert_after(
      Absinthe.Phase.Document.Result,
      ApolloTracer.Phase.AddExtension
    )
  end
end
