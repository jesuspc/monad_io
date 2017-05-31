defmodule ManuelTest do
  use ExUnit.Case
  import MonadIO

  defmodule GetRedirectionIO do
    defstruct [:token]
  end
  defimpl MonadIO.Protocol, for: GetRedirectionIO do
    def run(%GetRedirectionIO{token: token}) do
      IO.puts "Database find token #{token}"
      %{event: :redirection_event, url: :redirection_url}
    end
  end

  defmodule ReportMixpanelIO do
    defstruct [:event]
  end
  defimpl MonadIO.Protocol, for: ReportMixpanelIO do
    def run(%ReportMixpanelIO{event: event}) do
      IO.puts "Report mixpanel #{event}"
      :success
    end
  end

  test "works for Manuel" do
    token = "my_redirection_token"

    io = bind to_io(%GetRedirectionIO{token: token}), fn redirection ->
      bind to_io(%ReportMixpanelIO{event: redirection.event}), fn status ->
        if status == :success do
          return(fn -> IO.puts "Returning 302 with url #{redirection.url}" end)
        else
          return(fn -> IO.puts "Returning 400 with url #{redirection.url}" end)
        end
      end
    end

    run_io(io).()
  end
end
