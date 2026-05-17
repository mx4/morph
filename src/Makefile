# MORPH — DOS 4K intro (UASM: brew tap upiter/uasm && brew install uasm)

ASM       := MORPH.ASM
COM       := morph.com
UASM      ?= uasm
UASMFLAGS := -Cu -bin -Fo $(COM)
DEPS      := MACROS.INC MOTEUR.ASM MAKE_1.ASM PLASMA.INC TUNNEL.INC
STEM      := $(basename $(ASM))
CLEAN     := $(COM) $(STEM).err $(STEM).lst

.PHONY: build run clean

all: build

clean:
	rm -f $(CLEAN)

build: $(COM)

$(COM): $(ASM) $(DEPS)
	$(UASM) $(UASMFLAGS) $(ASM)
	@echo "Built: $(CURDIR)/$(COM) ($$(wc -c < $(COM) | tr -d ' ') bytes)"

run: $(COM)
	@if command -v dosbox >/dev/null 2>&1; then \
		dosbox -exit "$(CURDIR)/$(COM)"; \
	elif [ "$$(uname)" = Darwin ] && [ -d /Applications/DOSBox.app ]; then \
		open -a DOSBox --args -c "mount c $(CURDIR)" -c "c:" -c "$(COM)"; \
	else \
		echo "Install DOSBox: brew install dosbox (or DOSBox.app on macOS)"; \
		exit 1; \
	fi
