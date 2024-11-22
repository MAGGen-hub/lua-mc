## Проект Lua-MC
Lua-MC (lua macro compiller) - препроцессор для языка Lua версии Lua5.1
Основная цель проекта - расширение функционала языка Lua.
#### На данный момент реализован следующий функционал
- Полная поддержка операторов введённых в Lua5.3 включая мета-методы:
  `>>` `<<` `&` `|` `~` `//`  `unary ~`
- Операторы дополненного присвоения:
  `+=` `-=` `*=` `/=` `%=` `^=` `..=` `&&=` `||=`
  `>>=` `<<=` `|=` `&=`
  Оператор `?=` (инициализирует переменную если её значение `nil`)
- Сокращения ключевых слов:
  -  `@` - `local`
  -  `$` - `return`
  -  `||` - `or`
  -  `&&` - `and`
  -  `!` - `not`
  -  `;` - `end` (`\;` -> `;`) 
  -  `/|` -`if`
  -  `:|`- `esleif`
  -  `\|` - `else`
  - `?` - `then`
- Операторы авто проверки на `nil` (проверяется значение слева)
  `?.` `?:` `?"` `?[` `?{` `?(
  `local a a?() --не вызовет ошибки (attempt to call a nil value) 
 - Лямбда-функции `()->` `()=>`
 - Ключевое слово `is` (правая часть может быть таблицей с разрешенными типами)
 - Стандартные аргументы и строгая типизация для аргументов функций
   `function(arg : type = def_arg)`
#### Способ установки и запуска (Lua5.1)
1. Скачать файл `out/lua_mc__lua51__original.lua`
2. Установить одну из вариаций библиотеки bit:
	- bitop-lua5.1 (рекомендуется)
	- bit32-lua5.1
	- Использовать lua версию: https://github.com/AlberTajuelo/bitop-lua/blob/master/src/bitop/funcs.lua
	  (нужно будет отдельно выполнить:`package.path['bitop']=loadfile"funcs.lua"`)
3. Поместить проект в любую папку
4. Занести путь папки в package.path
5. `lua_mc=require"lua_mc__lua51__original"`
6. Выбрать одну из  конфигураций:
	- `lua_mc_instance = lua_mc.make"config=lua_mc_basic"`
	- `lua_mc_instance = lua_mc.make"config=lua_mc_user"`
	- `lua_mc_instance = lua_mc.make"config=lua_mc_full"`
7. `lua_mc_instance:run(" *source_cod* ")`
8. `rez, err = lua_mc_instance:cssc_load("chun_name",nil,_ENV)`
9. `rez()`
