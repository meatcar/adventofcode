solutions=$(wildcard days/*)
days=$(solutions:days/%.zig=%)
inputs=$(days:%=inputs/%.txt)

.SECONDARY:

all: $(days)
.PHONY: all

day%: inputs/day%.txt
	zig test days/$@.zig
	zig run days/$@.zig

inputs: $(inputs)

inputs/%.txt:
	$(eval FILE := $(notdir $@))
	$(eval NAME := $(basename ${FILE}))
	$(eval DAY := $(NAME:day%=%))
	curl -b session=${COOKIE} 'https://adventofcode.com/2020/day/$(DAY)/input' > $@

clean:
	rm -f $(inputs)

