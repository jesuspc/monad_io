defmodule MonadIO do
  # use Witchcraft.Monad

  defstruct [:action, :return]

  @type io(a) :: %{action: (() -> a), return: any()}
  @spec join(io(io(a :: any()))) :: io(a :: any())
  def join(io) do
    %__MODULE__{action: fn -> run_io run_io(io) end}
  end

  @spec fmap(io(a :: any()), (a :: any() -> b :: any())) :: io(b :: any())
  def fmap(io, func) do
    %{io | action: fn() -> func.(run_io io) end}
  end

  @spec run_io(io(a :: any())) :: io(a :: any())
  def run_io(%{return: return}) when not is_nil(return) do
    return
  end
  def run_io(io) do
    io.action.()
  end

  @spec bind(io(a :: any()), (a :: any() -> io(b :: any()))) :: io(b :: any)
  def bind(io, func) do
    join fmap(io, func)
  end

  @spec return(a :: any()) :: io(a :: any())
  def return(x) do
    %__MODULE__{action: fn -> x end}
  end

  @spec to_io(io(a :: any())) :: %MonadIO{action: action :: (() -> a :: any())}
  def to_io(action) do
    %MonadIO{action: fn -> MonadIO.Protocol.run action end}
  end
end
