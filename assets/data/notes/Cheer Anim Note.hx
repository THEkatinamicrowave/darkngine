function onNoteHit(event) if (event.noteType == "Cheer Anim Note") {
	event.animCancelled = true;
	event.character.playAnim("cheer");
}