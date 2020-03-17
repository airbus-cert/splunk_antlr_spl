import sys
import re
import configparser
import antlr4

from PLParserParser import PLParserParser
from PLParserLexer import PLParserLexer
from PLParserVisitor import PLParserVisitor

from io import StringIO
macros = {
    'generate_foo': 'table',
    'get_foo_index': 'index=foo',
    'get_windows_index': 'index=win*',
}


def beautify_lisp_string(in_string):
    indent_size = 3
    add_indent = ' '*indent_size
    out_string = in_string[0]  # no indent for 1st (
    indent = ''
    for i in range(1, len(in_string)):
        if in_string[i] == '(' and in_string[i+1] != ' ':
            indent += add_indent
            out_string += "\n" + indent + '('
        elif in_string[i] == ')':
            out_string += ')'
            if len(indent) > 0:
                indent = indent.replace(add_indent, '', 1)
        else:
            out_string += in_string[i]
    return out_string

def parse(spl):
    spl = 'search index=av [ | inputlookup UC007-foo| fields - bar | format] NOT [ | inputlookup UC042-foo-whitelist | fields - baz ] | table'
    spl = 'search index=av [| inputlookup UC013-helloworld-pattern | fields - bar | format] | table'
    spl = 'search xindex="*av*" kikoo [| inputlookup bar] | table foo'
    spl = 'search xindex="*av*" "kikoo" "gogo" | table foobar'
    spl = 'search xindex="*av*" kikoo gogo | table foobar'
    spl = 'search  kikoo gogo xindex="*av*" | table foobar'
    if not spl.startswith('search'):
        spl = 'search ' + spl
    for k, v in macros.items():
        spl = re.sub('`\s*%s\s*`' % k, v, spl)
    m = re.match('`\s*(\w+)\s*`', spl)
    if m:
        sys.stderr.write('ERROR: Unknown macro: %s\n', m[1])
        return
    spl = re.sub('\s+', ' ', spl).strip()

    print()
    print(repr(spl))
    #input_stream = antlr4.FileStream(StringIO(spl))
    stream = antlr4.InputStream(spl)
    lexer = PLParserLexer(stream)
    stream = antlr4.CommonTokenStream(lexer)
    parser = PLParserParser(stream)
    tree = parser.pipe_spl_fragment()
    #tree = parser.prog()

    print(beautify_lisp_string(tree.toStringTree(recog=parser)))

    #printer = antlr4.KeyPrinter()
    #walker = antlr4.ParseTreeWalker()
    #walker.walk(printer, tree)
    sys.exit(1)

conf = open(sys.argv[1]).read()

conf_fixed = re.sub('\\\s*\n', ' ', conf, flags=re.MULTILINE)
c = configparser.ConfigParser()
c.read_string(conf_fixed)
for name, x in c.items():
  if not 'search' in x:
      continue
  spl_query = x['search']
  parse(spl_query)
  #sys.exit(1)


