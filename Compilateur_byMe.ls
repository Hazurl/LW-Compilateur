include("Concours_Compilateur");
include("lib_Objet");
//:: CONSTANTE LIE A LA COMPILATION
global _wordAI = []; // Contient tout les "mots" de l'IA
global _CompilVar = []; // Contient la valeur de la variable : ["variable" : value, ...]
global _isCreate = []; // Tableau assoc ["variable" : true], si == true, la variable à été crée
global _KeyWord = ["var", "if", "while", "do", "global", "else", "return", "function", "for", "in", "break", "continue", "and", "or", "null", "true", "false"];
global _NativeFunction = ["debug" : debug];
global _Structure = [];
global _AI = "";

//:: CONSTANTE KEYWORD
global KW_IF = 1;
global KW_IF_ELSE = 2;
global KW_WHILE = 3;
global KW_DO_WHILE = 4;
global KW_FOR = 5;
global KW_FOREACH = 6;
global KW_BRACKETS = 7;

//:: CONSTANTE MOD
global MOD_NUMBER = 1;
global MOD_VARIABLE = 2;
global MOD_OPERATOR = 3;

function _CompileAndRun (@str) {
    _Ai = @str;
    _SplitAI();
    debug(_wordAI);
}

function _CreateStructure () {
	var stack = new_Stack();
	
	for (var word in _wordAI) {
		if (word === "(") { // parenthese ouvrante

		}

		else if (inArray(_KeyWord, word)) { // On est sur un KW, comme if / while / var ...

		}

		else if (inArray(_NativeFunction, word)) { // On est sur une fonction native, i.e. deja implemente par le LS

		}

		else if (_isCreate[word] === true) { // On est sur une variable deja creer

		}
	}
}

function _SplitAI () {
	var currentWord = "";
	var currentMod = null;
	var AddWord = function () {
		if (currentWord === "") return;
		else {
			push(_wordAI, currentWord);
			currentWord = ""; return;
		}
	};
	for (var pos = 0; pos < length(_AI); pos++) {
		var char = charAt(_AI, pos);
		if (char === ' ' || char === '\n' || char === '\t') { // blank character
			AddWord();
		}

		else if (char === ";" || char === "," || char === "(" || char === ")" || char === "{" || char === "}") { // EndOfLign, Coma, brackets, accolades
			AddWord();
			currentWord = char;
			AddWord();
		}

		else if (char === '|' || char === '&' || char === '=' || char === '-' || char === '+' || char === '*' || char === '/' || char === '%' || char === '>' || char === '<') {
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
			if (currentMod === MOD_NUMBER) return 'ERR';
			if (currentMod !== MOD_VARIABLE) {
				AddWord();
				currentMod = MOD_VARIABLE;
			}

			currentWord += char;
		}
	}

	return 'OK';
}