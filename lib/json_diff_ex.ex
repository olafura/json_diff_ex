defmodule JsonDiffEx do

  defp check_shift([], _) do
    []
  end


  defp check_shift([head|tail], shift_length) do
    case head do
      {_ , [_, 0, 0]} -> [head | check_shift(tail, shift_length+1)]
      {_ , [_]} -> [head | check_shift(tail, shift_length-1)]
      {<<"_", x>>, ["", y, 3]} when (x-48)-y === shift_length -> check_shift(tail, shift_length)
      _ -> [head | check_shift(tail, shift_length)]
    end
  end

  def map_find_match(_, _, []) do
    []
  end

  def map_find_match(i, value, [head | tail]) do
    {i2, value2} = case head do
      {<<"_", x>>, [value2, 0, 0]} -> {<<x>>, value2}
      _ -> {"", ""}
    end
    case i == i2 do
      true -> if is_map(value2) do
          [{i, diff(value2, value)} | tail]
        else
          [{i, [value]}] ++ [ head | tail]
        end
      false -> [head | map_find_match(i, value, tail) ]
    end
  end

  defp check_map([]) do
    []
  end

  defp check_map([head | tail]) do
    case head do
      {i, [value]} when is_map(value) -> map_find_match(i, value, tail)
      _ -> [head | check_map(tail) ]
    end
  end

  defp make_diff_list({[nil, v], i}) do
    {"_"<>to_string(i), [v, 0, 0]}
  end

  defp make_diff_list({[i2, _], i}) do
    {"_"<>to_string(i), ["", i2, 3]}
  end

  defp make_add_list({v, i}) do
    {to_string(i), [v]}
  end

  def diff(l1, l2) when is_list(l1) and is_list(l2) do
    l1_in_l2 = Enum.with_index(Enum.map(l1, &([Enum.find_index(l2, fn(x) -> x === &1 end), &1])))
    not_in_l1 = Enum.filter(Enum.with_index(l2), fn({x,_}) -> not x in l1 end)
    Enum.map(not_in_l1, &make_add_list(&1))
    ++ Enum.filter_map(l1_in_l2, fn({[i2, _], i}) -> i !== i2 end, &make_diff_list(&1))
    ++ [{"_t", "a"}]
    |> check_shift(0)
    |> check_map
    |> Enum.into(%{})
  end

  def diff(i1, i2) when not (is_list(i1) and is_list(i2)) and not (is_map(i1) and is_map(i2)) do
    case i1 === i2 do
      true -> nil
      false -> [i1, i2]
    end
  end 

  def diff(map1, map2) when is_map(map1) and is_map(map2) do
    keys = Map.keys(map1) ++ Map.keys(map2) |> Enum.uniq
    Enum.map(keys, fn(k) ->
      case Dict.has_key?(map1, k) do
        true ->
          case Dict.has_key?(map2, k) do
            true -> {k, diff(Dict.get(map1, k), Dict.get(map2, k))}
            false -> {k, [Dict.get(map1, k), 0, 0]}
          end
        false -> {k, [Dict.get(map2, k)]}
      end
    end)
    |> Enum.filter(fn({_,v}) -> v !== nil end)
    |> Enum.into(%{})
  end
end
