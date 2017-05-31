defprotocol MonadIO.Protocol do
  @spec run(MonadIO.io(a :: any())) :: any()
  def run(action)
end
