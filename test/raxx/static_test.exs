defmodule Raxx.StaticTest do
  use ExUnit.Case

  defmodule MyApp do
    use Raxx.SimpleServer

    @impl Raxx.SimpleServer
    def handle_request(_request, _state) do
      response(:no_content)
    end
  end

  @static_setup Raxx.Static.setup(source: Path.join(__DIR__, "public"))

  setup %{} do
    stack = Raxx.Stack.new([{Raxx.Static, @static_setup}], {MyApp, nil})
    {:ok, stack: stack}
  end

  test "File content is served", %{stack: stack} do
    request = Raxx.request(:GET, "/hello.txt")

    {[response], _} = Raxx.Server.handle_head(stack, request)

    assert response.status == 200
    assert response.body == "Hello, World!\n"
    assert Raxx.get_content_length(response) == 14
    assert Raxx.get_header(response, "content-type") == "text/plain"
  end

  test "A css file is served with the correct content type", %{stack: stack} do
    request = Raxx.request(:GET, "/site.css")

    {[response], _} = Raxx.Server.handle_head(stack, request)
    assert Raxx.get_header(response, "content-type") == "text/css"
  end

  test "files in subdirectories are  found", %{stack: stack} do
    request = Raxx.request(:GET, "/sub/file.txt")

    {[response], _} = Raxx.Server.handle_head(stack, request)

    assert response.status == 200
    assert response.body == "sub file.\n"
    assert Raxx.get_content_length(response) == 10
    assert Raxx.get_header(response, "content-type") == "text/plain"
  end

  test "request that does not match is passed up the stack", %{stack: stack} do
    request = Raxx.request(:GET, "/")

    {[response], _} = Raxx.Server.handle_head(stack, request)

    assert response.status == 204
  end

  test "setup options can be passed to the middleware" do
    stack =
      Raxx.Stack.new(
        [
          {Raxx.Static, source: Path.join(__DIR__, "public")}
        ],
        {MyApp, nil}
      )

    request = Raxx.request(:GET, "/hello.txt")

    {[response], _} = Raxx.Server.handle_head(stack, request)

    assert response.status == 200
    assert response.body == "Hello, World!\n"
    assert Raxx.get_content_length(response) == 14
    assert Raxx.get_header(response, "content-type") == "text/plain"
  end
end
