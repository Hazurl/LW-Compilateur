//:: CONSTANTE LIE A LA COMPILATION
global _wordAI = [];
global _CompilVar = [];
global _KeyWord = ["var"]; // Pour l'instant les seuls mise en place
global _NativeFunction = ["debug" : debug];
global _Structure = [];

//:: CONSTANTE KEYWORD
global KW_IF = 1;
global KW_IF_ELSE = 2;
global KW_WHILE = 3;
global KW_DO_WHILE = 4;
global KW_FOR = 5;
global KW_FOREACH = 6;
global KW_PARENTHESE = 7;

//:: CONSTANTE DE RETOUR
global COMPIL_SUCCESS = 1;
global COMPIL_ERR_END_OF_LINE = -1;
global COMPIL_ERR_VAR_NON_EXISTENT = -2;

function CompileAndRun (@AI) {
	// Votre compilation :
	SeparateWord(AI);
	debug(_wordAI);
	
	//if (true) return;
	
	for (var i = 0; i < count(_wordAI); i++) {
		var word = _wordAI[i];
		debug("Current Word : " + word);
		
		if (number(word) === null) {
			// En precense soit d'un mot-cle, soit d'une variable soit d'une "(" / "{", etc...
			if (inArray(_KeyWord, word)) {
				// KeyWord tel que if / while / var ...
				if (word === "var") { // Cas de creation de variable;
					// Creation d'une var'
					i++;
					var CurVar = _wordAI[i];
					debug("Current Word : " + CurVar);
					_CompilVar[CurVar] = null;

					// Assignation ou fin de ligne
					i+=2; // On passe le "=" : /!\ Pas encore de verif
					word = _wordAI[i]; debug("Current Word : " + word);
					if (word === ";") continue;
					var tmp; if ((tmp = number(word)) === null) return -1; //Erreur Compile, version n'acceptant que les nombres...
					_CompilVar[CurVar] = tmp;

					// Fin de ligne sinon Erreur de compile
					if (_wordAI [i + 1] !== ";") return -1;
				}
			}
			else {
				// Fonction ou variable
				var f; //fonction native
				if ((f = _NativeFunction[word]) !== null) {
					// Fonction native tel que debug, getCellDistance ...
					if (_wordAI[++i] !== "(") return -1;
					else {
						var params = [];
						for (var j = i; j < count(_wordAI); j++) {
							var tmpWord = _wordAI[j];
							if (tmpWord === ")") break;
							params += tmpWord;
						}
						var foo = getParam(params);
						var nbrParam = foo[0];
						if (nbrParam === 0) f();
						else if (nbrParam === 1) f(foo[1]);
						else if (nbrParam === 2) f(foo[1], foo[2]);
						else if (nbrParam === 3) f(foo[1], foo[2], foo[3]);
						else if (nbrParam === 4) f(foo[1], foo[2], foo[3], foo[4]);
						else return -1;
					}
					
				}
				else {
					// Fonction ou varaible de l'utilisateur
				}
			}
		}
	}
}

//Niveau 1 : Simple initialisation d'une variable et addition sur elle même.
/*CountOpe (1, function () { CompileAndRun("
	var test = 5;
	test = test + 1;
"); } );*/

//Niveau 2 : Affichage d'une variable avec debug
CountOpe (2,function () { CompileAndRun("
	var disp = 6 ;
	debug ( disp ) ;
"); } );

function SeparateWord (@str) {
	var currentStr = "";
	for (var i = 0; i < length(str); i++) {
		var char = charAt(str, i);
		//debug("pos : " + i + " -> '" + char + "'");
		if (char === ' ' || char === '\n' || char ===  '\t') {
			if (currentStr !== "") {
				push(_wordAI, currentStr);
				currentStr = "";
			}
			continue ;
		}
		else currentStr += char;
	}
}

function setStructure () {
	// Structure set dans la global _Structure
	var curInstruction = [];
	var curKW = 0;
	for (var word in _wordAI) {
		if (word === ";" && (curInstruction === [] || !push(_Structure, curInstruction))) continue;
		if (word === "if") {
			curInstruction[0] = (curKW = KW_IF);
		} else if (word === "(") {
			
		} else {debugE("KW not implemented : " + word); return;}
	}
}

function getParam (@tab) {
	return @[1, _CompilVar["disp"]];
}

function CountOpe (@lvl, @callback) {
    var ope = getOperations();
	var output = @(callback());
	ope = getOperations() - ope - 6; //Determine sur un appel à "vide" (CompileAndRun vide)
	
    if (output === COMPIL_SUCCESS) // Bon retour
        debug("Niveau " + lvl + " compile et executer en " + (ope) + " opérations");
    else if (output === COMPIL_ERR_END_OF_LINE)
		debug("Niveau " + lvl + " à échouer au bout de " + (ope) + " opérations : ERR_END_OF_LINE");
	else if (output === COMPIL_ERR_VAR_NON_EXISTENT)
		debug("Niveau " + lvl + " à échouer au bout de " + (ope) + " opérations : ERR_VAR_NON_EXISTENT");
	else debug("Niveau " + lvl + " compile et executer en " + (ope) + " retour null, impossible de savoir si la compilation à marcher.");
}

