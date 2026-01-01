ASSETS := !arrow.t3x !dicesix-sheet.t3x !felt.t3x !table-edge.t3x !arrow2.t3x !dice-outline.t3x !table-corner.t3x !playerbuttons.t3x !rollbutton.t3x
ASSETS_DIR := ./assets

all: $(subst  !, ./assets/,$(ASSETS))

$(ASSETS_DIR)/%.t3x: assets/%.png
	tex3ds $< -o $@
