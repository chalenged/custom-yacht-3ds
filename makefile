ASSETS := !arrow.t3x !dicesix-sheet.t3x !felt.t3x !table-edge.t3x !arrow2.t3x !dice-outline.t3x !table-corner.t3x !playerbuttons.t3x !rollbutton.t3x
ASSETS_DIR := ./assets
LUA := main.lua button.lua scoreboard.lua score.lua dice.lua anim8 assets classic lua-yaml nest
.PHONY: gamefolder all

all: $(subst  !, ./assets/,$(ASSETS)) gamefolder

$(ASSETS_DIR)/%.t3x: assets/%.png
	tex3ds $< -o $@

gamefolder:
	mkdir -p build/game
	cp -r $(LUA) build/game/
	cp lovebrew.toml yachticon.png build/
	(cd build; zip -r yachtgame.zip ./*)
	mv build/yachtgame.zip yachtgame.zip
	rm -r build
