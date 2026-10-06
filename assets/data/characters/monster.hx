//
using StringTools;

function postCreate() {
	for (symbol in frames.dictionary) {
		for (shit in symbol.timeline.layers) {
			if (shit.name.startsWith('HAT')) shit.visible = false;
		}
	}
}
