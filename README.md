# Elixir to Erlang decompiler

## About

Elixir *.beam files -> Erlang sources decompiler

elixir2erl.zip is an archive with decompiled Exlixir *.beams for Elixir sources and libs files and elixir2erl decompiler sources.

## Using it for decompilation Elixir's *.beam files

Run erl with -pa 'Path_to_elixir_core' with files elexir_*.beam

## Calls examples

1>elixir2erl:dir("Dir").
2>elixir2erl:file("elixir_some.beam").

## See decompiled *.erld files in directory Dir

## Test

$erl -pa ./ex_beams

1>elixir2erl:dir("beam"). or any directory with Elixir beams
2>q().

