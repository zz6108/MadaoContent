#!/bin/bash
#

MINIONROOT="/mnt/c/MINIONAPP/Bots/FFXIVMinion64/LuaMods";
GITROOT="$(dirname -- ${BASH_SOURCE[0]})";

RSYNC_PARAMS=("-h" "--progress" )


#sync materia
rsync ${RSYNC_PARAMS[@]} "${MINIONROOT}/ffxivminion/MadaoFiles/MateriaSocket/Common Profile.lua" "${GITROOT}/ffxivminion/MadaoFiles/MateriaSocket/"	



if [ ! -d "${GITROOT}/zzzPatchCutscene" ]; then
	mkdir "${GITROOT}/zzzPatchCutscene"
fi

rsync ${RSYNC_PARAMS[@]} "${MINIONROOT}/zzzPatchCutscene/module.def" "${GITROOT}/zzzPatchCutscene/"
rsync ${RSYNC_PARAMS[@]} "${MINIONROOT}/zzzPatchCutscene/zzzPatchCutscene.lua" "${GITROOT}/zzzPatchCutscene/"


if [ -f "${GITROOT}/anonymize.sh" ]; then
	"${GITROOT}/anonymize.sh"
fi
