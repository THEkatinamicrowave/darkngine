//
using StringTools;

function onTryDance(e:CancellableEvent) {
  	if (getAnimName().startsWith('hair') && !isAnimFinished()) e.cancel();
}
