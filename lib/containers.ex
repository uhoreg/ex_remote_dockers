defmodule ExRemoteDockers.Containers do
  alias ExRemoteDockers.Client
  alias ExRemoteDockers.HostConfig
  @moduledoc """
  Connector for managing remote Docker containers
  """

  @containers_uri "/containers"

  @doc """
  Returns a list of running containers
  """
  def list(%HostConfig{} = host) do
    basic_url(host, "json")
    |> Client.get()
  end

  @doc """
  Returns a list of all containers
  """
  def list_all(%HostConfig{} = host) do
    basic_url(host, "json")
    |> Client.get([query: %{"all" => true}])
  end

  @doc """
  Create a container
  """
  def create(%HostConfig{} = host, name, query) do
    query =
      query
      |> Poison.encode!
    basic_url(host, "create")
    |> Client.post([name: name, body: query])
  end

  @doc """
  Remove a container
  """
  def remove(%HostConfig{} = host, container_id) do
    basic_url(host, container_id)
    |> Client.delete()
  end

  @doc """
  Start a container
  """
  def start(%HostConfig{} = host, container_id) do
    basic_url(host, container_id <> "/start")
    |> Client.post()
  end

  @doc """
  Stop a container
  """
  def stop(%HostConfig{} = host, container_id) do
    basic_url(host, container_id <> "/stop")
    |> Client.post()
  end

  @doc """
  Return low-level information about a container
  """
  def inspect(%HostConfig{} = host, container_id) do
    basic_url(host, container_id <> "/json")
    |> Client.get()
  end


  defp basic_url(%HostConfig{} = host_config, uri) do
    uri
    |> check_uri
    |> build_uri(host_config)
  end

  defp check_uri("/" <> _endpoint = uri), do: uri
  defp check_uri(uri), do: "/" <> uri

  defp build_uri(uri, %HostConfig{} = host_config) do
    host_config.host <> ":" <> check_port(host_config.port) <> @containers_uri <> uri
  end

  defp check_port(port) when is_integer(port), do: Integer.to_string(port)
  defp check_port(port), do: port

end
