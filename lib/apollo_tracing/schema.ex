defmodule ApolloTracing.Schema do
  @moduledoc """
  Tracing Schema
  """
  @derive Jason.Encoder
  defstruct [:version,
             :startTime,
             :endTime,
             :duration,
             :execution]

  @type t :: %__MODULE__{
    version: pos_integer,
    startTime: DateTime.t,
    endTime: DateTime.t | nil,
    duration: pos_integer | nil,
    execution: __MODULE__.Execution.t
  }

  defmodule Execution do
    @derive Jason.Encoder
    defstruct [:resolvers]

    @type t :: %__MODULE__{
      resolvers: [__MODULE__.Resolver.t]
    }

    defmodule Resolver do
      @derive Jason.Encoder
      defstruct [:path,
                 :parentType,
                 :fieldName,
                 :returnType,
                 :startOffset,
                 :duration,
                 :meta]

      @type path_elem :: String.t | integer

      @type t :: %__MODULE__{
        path: [path_elem],
        parentType: String.t,
        fieldName: String.t,
        returnType: String.t,
        startOffset: pos_integer,
        duration: pos_integer,
        meta: KeywordList.t,
      }
    end
  end
end
