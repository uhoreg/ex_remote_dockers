defmodule RemoteDockers.ContainerConfig do
  @enforce_keys [:Image]
  defstruct [
    :Image,
    :Env,
    :HostConfig
  ]

  @doc """
  Build an container configuration with a specified `image_name`.
  """
  def new(image_name) do
    %RemoteDockers.ContainerConfig{
      "Image": image_name,
      "Env": [],
      "HostConfig": %{
        "Mounts": []
      }
    }
  end

  @doc """
  Add an environment variable to the specified container configuration.
  """
  @spec add_env(RemoteDockers.ContainerConfig, bitstring, bitstring) :: RemoteDockers.ContainerConfig
  def add_env(%RemoteDockers.ContainerConfig{} = container_config, key, value) do
    env =
      Map.get(container_config, :Env)
      |> List.insert_at(-1, key <> "=" <> value)
    container_config
    |> Map.put(:Env, env)
  end

  @doc """
  Add a volume mount point description to the container host configuration.

  ## Example:
    ```elixir
    mount_point = %{
      "Source": "/path/to/host/mount/point",
      "Target": "/path/to/container/directory",
      "Type": "bind"
    }
    ContainerConfig.new("MyImage")
    |> ContainerConfig.add(mount_point)
    ```
  """
  @spec add_mount_point(RemoteDockers.ContainerConfig, Map.t) :: RemoteDockers.ContainerConfig
  def add_mount_point(%RemoteDockers.ContainerConfig{} = container_config, %{} = mount_point) do
    host_config = Map.get(container_config, :HostConfig)

    mount_points =
      Map.get(host_config, :Mounts)
      |> List.insert_at(-1, mount_point)

    host_config = Map.put(host_config, :Mounts, mount_points)
    container_config
    |> Map.put(:HostConfig, host_config)
  end

  @doc """
  Add a volume mount point binding (i.e. mount type is `bind`) to the container configuration.

  `source` and `target` values are respectively mapped to the `"Source"` and `"Target"` mount point
  description fields.

  See `add_mount_point/2`
  """
  @spec add_mount_point(RemoteDockers.ContainerConfig, bitstring, bitstring) :: RemoteDockers.ContainerConfig
  def add_mount_point(%RemoteDockers.ContainerConfig{} = container_config, source, target) do
    mount = %{
      "Source": source,
      "Target": target,
      "Type": "bind"
    }
    add_mount_point(container_config, mount)
  end

end
