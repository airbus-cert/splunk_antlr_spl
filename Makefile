antlr-4.8-complete.jar:
	wget https://www.antlr.org/download/antlr-4.8-complete.jar

SPLParser.py: SPL.g4
	java -jar antlr-4.8-complete.jar -Dlanguage=Python3  -visitor $<

PLParserParser.py: spl/PLParser.g4
	 java -jar antlr-4.8-complete.jar -Dlanguage=Python3  -visitor $<
	 perl -i -ne 'print unless /^\s*\\s\s*$$/' PLParserParser.py


