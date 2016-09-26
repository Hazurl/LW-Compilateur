if (getTurn() > 1) return;
include('Compilateur_byMe');
//:: LEVEL TO COMPILE 
// Renseigner la plage de valeur des valeurs que vous voulez compilez par exemple : [1, 7] signifie qe les 7 premiers levels seront compilés
global PLAGE_LEVEL = [ -1 , -1 ]; // Par defaut tout les levels (-1 signifie le minimum/maximum, ainsi [-1,-1] signifie tout les levels)

//:: CONSTANTE DE RETOUR
global COMPIL_SUCCESS = 1;
global COMPIL_ERR_END_OF_LINE = -1;
global COMPIL_ERR_VAR_NON_EXISTENT = -2;
global COMPIL_ERR_UNDIFINED = -42;

function CompileAndRun (@str) {
    // Votre compilation :
	_CompileAndRun(str);
}
 
//Niveau 1 : Simple initialisation d'une variable et addition sur elle même.
CountOpe (1, COMPIL_SUCCESS, function () { return CompileAndRun('
   var test = 5;
   test = test + 1;
'); } );
 
//Niveau 2 : Affichage d'une variable avec debug
CountOpe (2, COMPIL_SUCCESS, function () { return CompileAndRun('
   var disp = 6;
   debug(disp);
'); } );

//Niveau 3 : Premiere condition
CountOpe (3, COMPIL_SUCCESS, function () { return CompileAndRun('
	var ok = true;
	if (ok) {
		debug(ok);
	}
	else debug("pas ok");
'); } );

//Niveau 4 : Le while, boucle conditionnelle
CountOpe (4, COMPIL_SUCCESS, function () { return CompileAndRun('
	var increment = 3;
	while (increment > 0) {
		increment--;
		debug(increment);
	}
'); } );

//Niveau 5 : For utilisation basique
CountOpe (5, COMPIL_SUCCESS, function () { return CompileAndRun('
	for (var i = 0; i < 3; i++) {
		debug("i : " + i);
	}
'); } );

//Niveau 6 : Fonction
CountOpe (6, COMPIL_SUCCESS, function () { return CompileAndRun('
	function haha () { debug("something"); }
	
	haha();
'); } );
 
//Niveau 7 : boucle while
CountOpe (7, COMPIL_SUCCESS, function () { return CompileAndRun('
	var enemy = getNearestEnemy();
	while (getMP() > 0 || getCellDistance(getCell(), getCell(enemy))) {
		moveToward(enemy, 0);
		debug(getCellDistance(getCell(), getCell(enemy)));
	}
'); } );

//Niveau 8 : foreach
CountOpe (8, COMPIL_SUCCESS, function () { return CompileAndRun('
	for (var weap in getWeapons()) {
		debug(getWeaponName(weap));
	}
'); } );

function CountOpe (@lvl, @wantedOutput @callback) {
	if (!((lvl >= PLAGE_LEVEL[0] || PLAGE_LEVEL[1] === -1) && (lvl <= PLAGE_LEVEL[1] || PLAGE_LEVEL[1] === -1))) return;
    var ope = getOperations();
	var output = @(callback());
	ope = getOperations() - ope - 6; //Determine sur un appel à "vide" (CompileAndRun vide)
	
	var debugText = 'Niveau ' + lvl;
	if (output === wantedOutput) debugText += ' à été bien compilé en ' + ope + ' opérations , la valeur de retour est bien ' + output;
	else debugText += ' n\'as pas été bien compilé en ' + ope + ' opérations , la valeur de retour à été : ' + output + ' à la place de ' + wantedOutput;
	debugE(debugText);
}