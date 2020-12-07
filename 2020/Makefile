solutions=$(wildcard days/day*)
inputs=$(solutions:days/%.zig=inputs/%.txt)
days=$(solutions:days/%.zig=%)

.PRECIOUS: $(inputs)
.PHONY: all clean dev inputs $(days) $(solutions)

.DEFAULT: all

.PHONY: all
all: $(days)

.PHONY: inputs
inputs: $(inputs)

.PHONY: clean
clean:
	rm -f $(inputs)

.PHONY: $(days)
$(days): day%: days/day%.zig

.PHONY: $(solutions)
$(solutions): days/day%.zig: inputs/day%.txt
	zig fmt $@
	zig test $@
	zig run $@

$(inputs):
	$(eval FILE := $(notdir $@))
	$(eval NAME := $(basename ${FILE}))
	$(eval DAY := $(NAME:day%=%))
	curl -b session=${COOKIE} 'https://adventofcode.com/2020/day/$(DAY)/input' > $@

dev:
	while sleep 1; do \
		find days inputs -type f \
		| SHELL=/bin/sh entr -dcs 'realpath --relative-to=$$PWD $$0 | xargs make'; \
		done
