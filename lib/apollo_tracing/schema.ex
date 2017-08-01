defmodule ApolloTracing.Schema do
  @moduledoc """
  Tracing Schema
  """
  defstruct [:version,
             :start_mono_time,
             :start_wall_time,
             :end_mono_time,
             :end_wall_time,
             :duration,
             :execution]

  @type t :: %__MODULE__{
    version: pos_integer,
    start_wall_time: DateTime.t,
    start_mono_time: integer,
    end_wall_time: DateTime.t | nil,
    end_mono_time: integer | nil,
    duration: pos_integer | nil,
    execution: __MODULE__.Execution.t
  }

  defmodule Execution do
    defstruct [:resolvers]

    @type t :: %__MODULE__{
      resolvers: [__MODULE__.Resolver.t]
    }

    defmodule Resolver do
      defstruct [:path,
                 :parent_type,
                 :field_name,
                 :return_type,
                 :start_offset,
                 :duration]

      @type path_elem :: String.t | integer

      @type t :: %__MODULE__{
        path: [path_elem],
        parent_type: String.t,
        field_name: String.t,
        return_type: String.t,
        start_offset: pos_integer,
        duration: pos_integer
      }
    end
  end
end
