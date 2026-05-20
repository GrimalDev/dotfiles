BINARY_NAME = apple_menu

bin/$(BINARY_NAME): Sources/AppleMenu/main.swift | bin
	swift build -c release 2>/dev/null || swift build
	cp $$(swift build -c release --show-bin-path 2>/dev/null || swift build --show-bin-path)/AppleMenu bin/$(BINARY_NAME)

bin:
	mkdir -p bin

clean:
	rm -rf bin .build

.PHONY: clean 