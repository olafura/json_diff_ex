defmodule JsonDiffEx do
  @moduledoc """
  This is the documentation of JsonDiffEx.

  There are no runtime dependencies and it should be easy
  to use.

  You can use the javascript library
  [jsondiffpatch](https://github.com/benjamine/jsondiffpatch)
  with it since it get's it's diff format from it.

  It contains both diff and patch

  ## Example

  ### Diff

  Simple example:

      iex> JsonDiffEx.diff %{"test" => 1}, %{"test" => 2}
      %{"test" => [1, 2]}

  Now with list:

      iex> JsonDiffEx.diff %{"test" => [1,2,3]}, %{"test" => [2,3]}
      %{"test" => %{"_0" => [1, 0, 0], "_t" => "a"}}

  Now with a map in the map:

      iex> JsonDiffEx.diff %{"test" => %{"1": 1}}, %{"test" => %{"1": 2}}
      %{"test" => %{"1": [1, 2]}}

  Now with a map in an list in the map:

      iex> JsonDiffEx.diff %{"test" => [%{"1": 1}]}, %{"test" => [%{"1": 2}]}
      %{"test" => %{"0" => %{"1": [1, 2]}, "_t" => "a"}}

  If you have problems with using both integers and floats you can override the
  strict comparison:

      iex> JsonDiffEx.diff(%{a: 2100}, %{a: 2.1e3}, strict_equality: false)
      %{}

  ### Patch

  Simple example of a patch:

      iex> JsonDiffEx.patch %{"test" => 1}, %{"test" => [1, 2]}
      %{"test" => 2}

  Now a patch with list:

      iex> JsonDiffEx.patch %{"test" => [1,2,3]},
      ...> %{"test" => %{"_0" => [1, 0, 0], "_t" => "a"}}
      %{"test" => [2,3]}

  Now a patch with a map in the map:

      iex> JsonDiffEx.patch %{"test" => %{"1": 1}}, %{"test" => %{"1": [1, 2]}}
      %{"test" => %{"1": 2}}

  Now with a map in an list in the map:

      iex> JsonDiffEx.patch %{"test" => [%{"1": 1}]},
      ...> %{"test" => %{"0" => %{"1": [1, 2]}, "_t" => "a"}}
      %{"test" => [%{"1": 2}]}

  """

  @default_strict_equality true

  @spec split_underscore_map({binary, list}) :: boolean
  defp split_underscore_map({<<"_", _>>, [value, 0, 0]}) when is_map(value) do
    false
  end
  defp split_underscore_map(_) do
    true
  end

  @spec split_underscore({binary, list}) :: boolean
  defp split_underscore({<<"_", _>>, [_, 0, 0]}) do
    false
  end

  defp split_underscore(_) do
    true
  end


  @spec all_checked(list, map, list) :: list
  defp all_checked([], deleted_map, _) do
    Map.to_list(deleted_map)
  end

  defp all_checked([head | tail], deleted_map, opts) do
    case head do
      {i, [value]} when is_map(value) ->
        neg_i = "_" <> i
        case Map.fetch(deleted_map, neg_i) do
          {:ok, [value2, 0, 0]} -> [{i, do_diff(value2, value, opts)} | all_checked(tail, Map.delete(deleted_map, neg_i), opts)]
          :error -> [head | all_checked(tail, deleted_map, opts)]
        end
      _ -> [head | all_checked(tail, deleted_map, opts)]
    end
  end

  @spec do_diff(list, list, list) :: map | nil
  defp do_diff(l1, l2, opts) when is_list(l1) and is_list(l2) do
    new_list = List.myers_difference(l1, l2)
    |> Enum.reduce({0, %{}}, fn
      {:eq, equal}, {count, acc} ->
        {count + length(equal), acc}
      {:del, deleted_list}, {count, acc} ->
        {_, acc3} = Enum.reduce(deleted_list, {count, acc}, fn deleted_item, {count2, acc2} ->
          {count2 + 1, Map.put(acc2, "_" <> Integer.to_string(count2), [deleted_item, 0, 0])}
        end)
        {count, acc3}
      {:ins, inserted_list}, {count, acc} ->
        Enum.reduce(inserted_list, {count, acc}, fn inserted_item, {count2, acc2} ->
          {count2 + 1, Map.put(acc2, Integer.to_string(count2), [inserted_item])}
        end)
    end)
    |> elem(1)

    diff = case Enum.split_while(new_list, &split_underscore_map/1) do
      {[], []} -> new_list
      {_, []} -> new_list
      {check, deleted} ->
        deleted_map = Enum.into(deleted, %{})
        all_checked(check, deleted_map, opts)
    end
    if diff != %{} do
      diff
      |> Enum.concat([{"_t", "a"}])
      |> Enum.into(%{})
    else
      nil
    end
  end

  @spec do_diff(binary | integer | float, binary | integer | float, list) :: map | nil
  defp do_diff(i1, i2, opts) when not (is_list(i1) and is_list(i2))
                    and not (is_map(i1) and is_map(i2)) do
    compare = if Keyword.get(opts, :strict_equality, @default_strict_equality) do
      &===/2
    else
      &==/2
    end
    case compare.(i1, i2) do
      true -> nil
      false -> [i1, i2]
    end
  end

  @spec do_diff(map, map, list) :: map | nil
  defp do_diff(map1, map2, opts) when is_map(map1) and is_map(map2) do
    keys_non_uniq = Enum.concat(Map.keys(map1), Map.keys(map2))
    diff = keys_non_uniq
    |> Enum.uniq
    |> Enum.map(fn(k) ->
      case Map.has_key?(map1, k) do
        true ->
          case Map.has_key?(map2, k) do
            true -> {k, do_diff(Map.get(map1, k), Map.get(map2, k), opts)}
            false -> {k, [Map.get(map1, k), 0, 0]}
          end
        false -> {k, [Map.get(map2, k)]}
      end
    end)
    |> Enum.filter(fn({_,v}) -> v !== nil end)
    |> Enum.into(%{})
    if map_size(diff) != 0 do
      diff
    else
      nil
    end
  end

  @doc """
  Diff only supports Elixir's Map format but they can contain,
  lists, other maps and anything that can be compared like strings,
  numbers and boolean.
  """
  @spec diff(map, map) :: map
  def diff(map1, map2, opts \\ []) when is_map(map1) and is_map(map2) do
    case do_diff(map1, map2, opts) do
      nil -> %{}
      map -> map
    end
  end

  defp do_patch_delete(list, diff) do
    case Enum.split_while(diff, &split_underscore/1) do
      {[], []} -> {list, diff}
      {_, []} -> {list, diff}
      {check, deleted} ->
        delete_list = Enum.map(deleted, fn
          {"_" <> s_index, _} -> String.to_integer(s_index)
        end)

        filtered_list = Enum.filter(list, fn
          {_, index} -> index not in delete_list
        end)
        |> clean_index()
        |> Enum.with_index()

        {filtered_list, Enum.into(check, %{})}
    end
  end

  defp clean_index(list) do
    Enum.map(list, fn {value, _index} -> value end)
  end

  defp do_patch_list({list, diff}) do
    new_list = clean_index(list)

    diff
    |> Enum.map(fn
     {s_index, value} -> {String.to_integer(s_index), value}
    end)
    |> Enum.reduce(new_list, fn
      {index, %{} = diff_map}, acc ->
        List.update_at(acc, index, &do_patch(&1, diff_map))
      {index, [value | []]}, acc ->
        List.insert_at(acc, index, value)
      {index, [_old_value | [new_value]]}, acc ->
        List.replace_at(acc, index, new_value)
    end)
  end

  defp do_patch(map1, diff1) do
    diff2 = diff1 |> Enum.map(fn({k, v}) ->
      case v do
        [new_value] -> {k, new_value}
        _ -> {k, v}
      end
    end)
    |> Enum.into(%{})
    Map.merge(map1, diff2, fn(_k, v_map, v_diff) ->
      case v_diff do
        [^v_map, new_value] -> new_value
        new_map when is_map(new_map) ->
          case Map.get(new_map, "_t", false) === "a" do
            true ->
              v_diff2 = Map.delete(v_diff, "_t")

              v_map
              |> Enum.with_index
              |> do_patch_delete(v_diff2)
              |> do_patch_list()
            false -> do_patch(v_map, v_diff)
          end
        [1, 0, 0] -> nil
      end
    end)
    |> Enum.filter(fn({_k, v}) -> v !== nil end)
    |> Enum.into(%{})
  end

  @doc """
  Patch only supports Elixir's Map format.
  """
  @spec patch(map, map) :: map
  def patch(map1, diff1) when is_map(map1) and is_map(diff1) do
    do_patch(map1, diff1)
  end
end
