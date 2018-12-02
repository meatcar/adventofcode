# Advent

Elixir attempt at the Advent of Code. I was learning Elixir while
progressing through the problems, my solutions will not be retouched
to preserve a sense of progress.

## Installation

Install elixir and erlang. I used [`asdf`](https://github.com/asdf-vm/asdf).

```sh
asdf plugin-add elixir
asdf plugin-add erlang
asdf install
mix deps.get
cp config/{config,dev}.exs
cp config/{config,test}.exs
$EDITOR config/{dev,test}.exs # change :changeme to adventofcodes' cookie (if you trust me)
mix day 1 # 2, 3, etc :)
```