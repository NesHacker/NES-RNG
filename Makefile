BUILD = ./build
SRC = ./src
OBJECTS = nes-rng-test.o

all: build-dir nes-rng-test.nes

clean: build-dir
	rm -rf build/*.o nes-rng-test.nes

build-dir:
	mkdir -p $(BUILD)

nes-rng-test.nes: $(OBJECTS)
	cl65 -t nes -o nes-rng-test.nes $(BUILD)/*.o

%.o: $(SRC)/%.s
	ca65 $< -o $(BUILD)/$@  -t nes
