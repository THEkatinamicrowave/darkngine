function onNoteHit(event) if (event.noteType == "Hey Anim Note") {
	event.animCancelled = true;
	event.character.playAnim("hey");
}