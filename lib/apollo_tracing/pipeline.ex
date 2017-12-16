defmodule ApolloTracing.Pipeline do
  def default(schema, pipeline_opts \\ []) do
    schema
    |> Absinthe.Pipeline.for_document(pipeline_opts)
    |> add_phases()
  end

  if Code.ensure_loaded?(Absinthe.Plug) do
    def plug(config, pipeline_opts \\ []) do
      config
      |> Absinthe.Plug.default_pipeline(pipeline_opts)
      |> add_phases()
    end
  else
    def plug(_, _ \\ []) do
      raise RuntimeError, """
        You don't have Plug loaded, please use
        ApolloTracing.Pipeline.default(absinthe_schema, pipeline_opts)
        to produce a pipeline without Plug specific phases
      """
    end
  end

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
