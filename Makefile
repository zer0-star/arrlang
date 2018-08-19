arrlang: main.nim lexer.nim tree.nim common.nim
	@if ! type nim > /dev/null 2>&1; then\
		brew install nim;\
	fi
	nim c -o:$@ -d:release main
