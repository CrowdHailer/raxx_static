defmodule Raxx.Static do
  @moduledoc """
  Serve the contents of a directory as static content.

      @static_setup Raxx.Static.setup(source: "path/to/assets")

      stack =
        Raxx.Stack.new(
          [
            {Middleware.Static, @static_state}
          ],
          {MyApp, config}
        )

  Use `setup/1` at compile time so that files are read only once.
  Raxx.Static should not be used for serving large files.

  #### Extensions

  Proposed extensions to Raxx.Static:

  - Check accept header and return content error when appropriate
  - gzip encoding
    plug doesnt actually gzip it just assumes a file named path <>.gz
    gzip is assumed false by default, say true to generate gz from contents or path modification if zipped exists.
    https://groups.google.com/forum/#!topic/elixir-lang-talk/RL-qWWx9ILE
  - cache control time
  - Etags
  - filtered reading of a file
  - set a maximum size of file to bundle into the code.
  - static_content(content, mime)
  - check trying to serve root file
  - use plug semantics of {:app, path/in/priv} or "/binary/absoulte" or "./binary/from/file"
  - Passing options to the middleware reads the entire source directory on every request!
  """
  use Raxx.Middleware
  alias Raxx.Server
  @default_pattern "./**/*.*"

  @enforce_keys [:matches]
  defstruct @enforce_keys

  def setup(options) do
    {:ok, source_directory} = Keyword.fetch(options, :source)
    pattern = Keyword.get(options, :pattern, @default_pattern)

    matches = build_matches(source_directory, pattern)

    %__MODULE__{matches: matches}
  end

  def process_head(request, state, next) do
    case match_request(request, state) do
      :none ->
        {parts, next} = Server.handle_head(next, request)
        {parts, state, next}

      response ->
        {[response], state, next}
    end
  end

  defp build_matches(source_directory, pattern) do
    filepaths = Path.wildcard(Path.expand(pattern, source_directory))

    Enum.flat_map(filepaths, fn filepath ->
      case File.read(filepath) do
        {:ok, content} ->
          mime = MIME.from_path(filepath)
          route = Path.relative_to(filepath, source_directory) |> Path.split()

          response =
            Raxx.response(:ok)
            |> Raxx.set_header("content-type", mime)
            |> Raxx.set_body(content)

          [{route, response}]

        {:error, :eisdir} ->
          []
      end
    end)
    |> Enum.into(%{})
  end

  defp match_request(%{method: :GET, path: segments}, %__MODULE__{matches: matches}) do
    case Map.fetch(matches, segments) do
      {:ok, response} ->
        response

      :error ->
        :none
    end
  end

  defp match_request(request, options) when is_list(options) do
    match_request(request, setup(options))
  end
end
