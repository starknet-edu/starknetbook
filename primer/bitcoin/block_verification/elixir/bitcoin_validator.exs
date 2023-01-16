#! /usr/bin/env elixir

Mix.install([:jason, :tesla])

defmodule BitcoinValidator do
  require Logger
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://blockchain.info")
  plug(Tesla.Middleware.JSON)

  def validate_block(block_hash) do
    with {:ok, %{body: %{"ver" => _ver} = body}} <- get("/rawblock/" <> block_hash) do
      calculated_hash = hash_block(body)

      IO.puts("Given Hash: #{block_hash}")
      IO.puts("Calculated Hash: #{calculated_hash}")
      IO.puts("Match: #{calculated_hash == block_hash}")

      IO.puts("\n\n")
      merkle_root = block_merkle_root(body)

      IO.puts("Given Merkle Root: #{body["mrkl_root"]}")
      IO.puts("Calculated Merkle Root: #{merkle_root}")
      IO.puts("Match: #{merkle_root == body["mrkl_root"]}")
    else
      error ->
        Logger.error("#{inspect(error)}")
        :error
    end
  end

  defp hash_block(block) do
    header =
      ["ver", "prev_block", "mrkl_root", "time", "bits", "nonce"]
      |> Enum.reduce(<<>>, fn item, acc ->
        bytes =
          block[item]
          |> decimal_to_hex()
          |> reverse_string_bytes()

        acc <> bytes
      end)

    hash_bytes = :crypto.hash(:sha256, header)

    :crypto.hash(:sha256, hash_bytes)
    |> Base.encode16()
    |> reverse_string_bytes()
    |> Base.encode16()
    |> String.downcase()
  end

  defp block_merkle_root(block) do
    merkle_hold =
      Enum.reduce(block["tx"], [], fn transaction, acc ->
        acc ++ [reverse_string_bytes(transaction["hash"])]
      end)
      |> ensure_even_nodes()

    merkle_height = merkle_height(merkle_hold)

    IO.puts("Num leaves: #{length(merkle_hold)}")
    IO.puts("Rounds: #{merkle_height}")

    {merkle_hold, merkle_pass} = calculate_merkle(merkle_hold, [], 0, merkle_height)

    if rem(merkle_height, 2) == 0 do
      merkle_hold
    else
      merkle_pass
    end
    |> hd()
    |> Base.encode16()
    |> reverse_string_bytes()
    |> Base.encode16()
    |> String.downcase()
  end

  defp decimal_to_hex(value) when is_binary(value), do: value
  defp decimal_to_hex(value) when is_number(value), do: Integer.to_string(value, 16)

  defp reverse_string_bytes(binary) when is_binary(binary), do: do_reverse(binary, <<>>)

  defp do_reverse(<<>>, acc), do: acc

  defp do_reverse(<<byte::binary-size(2)-little, bin::binary>>, acc) do
    decode_byte = Base.decode16!(byte, case: :mixed)

    do_reverse(bin, decode_byte <> acc)
  end

  defp merkle_height(merkle_hold) do
    merkle_hold
    |> length()
    |> :math.log2()
    |> ceil()
    |> trunc()
  end

  defp ensure_even_nodes(merkle) do
    if rem(length(merkle), 2) == 1 do
      merkle ++ [List.last(merkle)]
    else
      merkle
    end
  end

  defp calculate_merkle(merkle_hold, merkle_pass, merkle_round, total_rounds)
       when merkle_round == total_rounds,
       do: {merkle_hold, merkle_pass}

  defp calculate_merkle(merkle_hold, merkle_pass, merkle_round, total_rounds) do
    if rem(merkle_round, 2) == 0 do
      merkle_pass =
        ensure_even_nodes(merkle_hold)
        |> intermediate_round(merkle_pass, 0, length(merkle_hold))

      print_merkle_round(merkle_pass, merkle_round, total_rounds)

      calculate_merkle([], merkle_pass, merkle_round + 1, total_rounds)
    else
      merkle_hold =
        ensure_even_nodes(merkle_pass)
        |> intermediate_round(merkle_hold, 0, length(merkle_pass))

      print_merkle_round(merkle_hold, merkle_round, total_rounds)

      calculate_merkle(merkle_hold, [], merkle_round + 1, total_rounds)
    end
  end

  defp intermediate_round(_traverse_merkle, append_merkle, round_count, size)
       when round_count >= size do
    append_merkle
  end

  defp intermediate_round(traverse_merkle, append_merkle, round_count, size) do
    leafs = Enum.at(traverse_merkle, round_count) <> Enum.at(traverse_merkle, round_count + 1)

    hashed_leafs = :crypto.hash(:sha256, leafs)
    final_hash = :crypto.hash(:sha256, hashed_leafs)

    appended = append_merkle ++ [final_hash]

    intermediate_round(traverse_merkle, appended, round_count + 2, size)
  end

  defp print_merkle_round(merkle, merkle_round, total_rounds) do
    leaf1 = pretty_print_leaf(hd(merkle))
    leaf2 = pretty_print_leaf(List.last(merkle))
    blank_padding = String.duplicate("  ", merkle_round)
    leaf_padding = String.duplicate("....", total_rounds - merkle_round)

    IO.puts("Round #{merkle_round}: #{blank_padding} 0x#{leaf1} #{leaf_padding} 0x#{leaf2}")
  end

  defp pretty_print_leaf(leaf) do
    leaf
    |> Base.encode16()
    |> String.slice(0..7)
    |> String.downcase()
  end
end

block_hash = "0000000000000000000836929e872bb5a678546b0a19900b974c206c338f0947"
BitcoinValidator.validate_block(block_hash)
