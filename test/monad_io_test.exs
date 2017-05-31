defmodule MonadIOTest do
  use ExUnit.Case
  doctest MonadIO

  defmodule CreateUserIO do
    defstruct [:name]
  end
  defimpl MonadIO.Protocol, for: CreateUserIO do
    def run (%CreateUserIO{name: name}) do
      IO.puts "Create: #{name}"
      :success
    end
  end

  defmodule UpdateUserIO do
    defstruct [:name]
  end
  defimpl MonadIO.Protocol, for: UpdateUserIO do
    def run(%UpdateUserIO{name: name}) do
      IO.puts "Update: #{name}"
    end
  end

  defmodule MyController do
    import MonadIO

    def call do
      run_io composed_io(to_io %CreateUserIO{name: 'Juan'})
    end

    @spec composed_io(%CreateUserIO{}) :: %MonadIO{}
    def composed_io(io) do
      bind io, fn(status) ->
        if status == :success do
          to_io %UpdateUserIO{name: 'Pepito'}
        else
          return status
        end
      end
    end
  end

  test "works for a single operation" do
    MonadIO.run_io MonadIO.to_io(%CreateUserIO{name: 'Juan'})
  end

  test "works for a binded operation" do
    MyController.call
  end
end
