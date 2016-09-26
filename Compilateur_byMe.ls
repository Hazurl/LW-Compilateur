include('Concours_Compilateur');
include('lib_Objet');
//:: CONSTANTE LIE A LA COMPILATION
global _wordAI;
global _pos;
global _CompilVar;
global _KeyWord;
global _NativeFunction;
global _InacessibleWord;
global _CompilBloc;
//global _Structure;
global _AI;
global STOP;

function Reset () {
	_wordAI = [];
	_CompilVar = [];
	_KeyWord = ['var', 'in'];
	_NativeFunction = ['debug'];
	_CompilBloc = ['if', 'else', 'while', 'for', 'do'];
	_InacessibleWord = _KeyWord + _NativeFunction + _CompilBloc;
	//_Structure = [];
	_AI = '';
	_pos = 0;
}

//:: CONSTANTE KEYWORD
/* > OPERATIONS                                                                                                                           */
global OPE_ADD = 1, OPE_SOUS = 2, OPE_DIV = 3, OPE_MULTI = 4, OPE_MOD = 5;
/* > BLOCS                                                                                                                                */
global BLOC_IF = 11, BLOC_WHILE = 12, BLOC_DO_WHILE = 13, BLOC_FOR = 14, BLOC_FOREACH = 15;
/* > CONDITIONS                                                                                                                           */
global COND_SUP = 21, COND_INF = 22, COND_INF_EGAL = 23, COND_SUP_EGAL = 24, COND_DIF = 25, COND_OR = 26, COND_AND = 27;
/* > OTHER                                                                                                                                */
global NEW_VAR = 31, NEW_FUNCTION = 32, ASSIGN = 33;


//:: CONSTANTE MOD
global MOD_NUMBER = 1;
global MOD_VARIABLE = 2;
global MOD_OPERATOR = 3;

function _CompileAndRun (@str) {
	Reset();
    _AI = @str; // inutile ?
	_SplitAI();
	debug(_wordAI);
	Exec([], []);
}
/* Finalement cette methode n'est pas bien pour les variables, donc on pars sur de la recursivite
function _CreateStructure () {
	var stack = new_Stack();
	var word;
	while ((word = Next()) !== null) {
		if (InArray(_KeyWord, word)) { // C'est un KW
			if (word == 'var') { // NEW VAR
				if ((word = Next()) !== null) return COMPIL_ERR_UNDIFINED;

				if (inArray(_InacessibleWord, word)) return COMPIL_ERR_UNDIFINED;

			}
		}
	}
}*/

function Exec (@VarCreate, @VarValue) { // VarCreate est un tableau possedant les variables globals à ce morceau de code
	if (inArray(_KeyWord, get())) {
		if (get() === 'var') debug("FNEW_VAR : " + FNEW_VAR (VarCreate, VarValue));
	}
}

function FNEW_VAR (@VarCreate, @VarValue) {
	var cur;
	do { // Cur est un nom de var
		cur = Next();
		if (inArray(_InacessibleWord, cur)) { STOP = 5; return 5; }
		//if (VarCreate[(cur = Next())] === true) { STOP = 66; return 66; }

		var _var = cur; debug ("_var : " + _var);
		VarCreate[_var] = true;

		if ((cur = Next()) === '=') { VarValue[_var] = (cur = Next()); cur = Next(); }
		else VarValue[_var] = null;

	} while(cur !== ';' && cur !== null);
	if (cur === null) { STOP = 777; return 444; }
	debug("VarCreat : " + VarCreate);
	debug("VarValue : " + VarValue);
	return -8888;
}

function Next () { return _wordAI[++_pos]; }
function get () { return _wordAI[_pos]; }

function _SplitAI () {
	var currentWord = '';
	var currentMod = null;
	var AddWord = function () {
		//debugW(currentWord);
		if (currentWord === '') return;
		else {
			push(_wordAI, currentWord);
			currentWord = ''; return;
		}
	};
	for (var pos = 0; pos < length(_AI); pos++) {
		var char = charAt(_AI, pos);
		if (char === ' ' || char === '\n' || char === '\t') { // blank character
			AddWord();
		}

		else if (char === ';' || char === ',' || char === '(' || char === ')' || char === '{' || char === '}') { // EndOfLign, Coma, brackets, accolades
			AddWord();
			currentWord = char;
			AddWord();
		}

		else if (char === '=' || char === '-' || char === '+' || char === '*' || char === '/' || char === '%' || char === '>' || char === '<') {
			// Operator
			AddWord();
			currentMod = MOD_OPERATOR;

			currentWord += char;
		}

		else if (number(char) !== null) { // number : 2 cases -> a number or a variable/function
			if (currentMod !== MOD_NUMBER && currentMod !== MOD_VARIABLE) AddWord();
			if (currentMod !== MOD_VARIABLE) currentMod = MOD_NUMBER;

			currentWord += char;
		}

		else { // This is a letter, so we are writing a vriable/function/KW
			//debugW(char + ' is a letter, the current Mod is ' + currentMod);
			if (currentMod !== MOD_VARIABLE) {
				AddWord();
				currentMod = MOD_VARIABLE;
			}

			currentWord += char;
		}
	}
}

/*
========================================================================================================== 
   var test = 5;
   test = test + 1;
   
[
	[NEW_VAR, test, 5],
	[ASSIGN, test, [ADDITION, test, 1]]
]
========================================================================================================== 
   var disp = 6;
   debug(disp);
   
[
	[NEW_VAR, disp, 6],
	[FUNCTION, debug, disp]
]
========================================================================================================== 
	var ok = true;
	if (ok) {
		debug(ok);
	}
	else debug("pas ok");

[
	[NEW_VAR, ok, true],
	[BLOC_IF, ok, 
		[FUNCTION, debug, ok],
		[FUNCTION, debug, 'pas ok']
	]
]
========================================================================================================== 
	var increment = 3;
	while (increment > 0) {
		increment--;
		debug(increment);
	}
	
[
	[NEW_VAR, increment, 3],
	[BLOC_WHILE, [SUPERIEUR, increment, 0],
		[ASSIGN, increment, --],
		[FUNCTION, debug, increment]
	]
]
========================================================================================================== 
	for (var i = 0; i < 3; i++) {
		debug("i : " + i);
	}

[
	[BLOC_FOR, [NEW_VAR, i, 0], [INFERIEUR, i, 3], [ASSIGN, i, ++],
		[FUNCTION, debug, 'i : ' + i]
	]
]
========================================================================================================== 
	function haha () { debug("something"); }
	
	haha();
	
[
	[NEW_FUNCTION, haha, [], 
		[FUNCTION, debug, 'something']
	],
	[FUNCTION, haha]
]

========================================================================================================== 
	var enemy = getNearestEnemy();
	while (getMP() > 0 || getCellDistance(getCell(), getCell(enemy))) {
		moveToward(enemy, 1);
		debug(getCellDistance(getCell(), getCell(enemy)));
	}

[
	[NEW_VAR, enemy, [FUNCTION, getNearestEnemy]],
	[BLOC_WHILE, [OR, [SUPERIEUR, [FUNCTION, getMP], 0], [FUNCTION, getCellDistance, [FUNCTION, getCell], [FUNCTION, getCell, enemy]]],
		[FUNCTION, moveToward, enemy, 1],
		[FUNCTION, debug, [FUNCTION, getCellDistance, [FUNCTION, getCell], [FUNCTION, getCell, enemy]]]
	]
]
========================================================================================================== 
	for (var weap in getWeapons()) {
		debug(getWeaponName(weap));
	}

[
	[BLOC_FOREACH, [NEW_VAR, weap], [FUNCTION, getWeapons]
		[FUNCTION, debug, [FUNCTION, getWeaponName, weap]]
	]
]
========================================================================================================== 
*/










