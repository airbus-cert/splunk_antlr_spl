import sys
import re
import configparser
import antlr4

from io import StringIO

from SPLParser import SPLParser
from SPLLexer import SPLLexer
from SPLListener import SPLListener

macros = {
    'generate_es_ticket_reference': 'table',
    'get_symantec_av_index': 'index=av',
    'get_windows_index': 'index=*wineventlog*',
    'get_all_windows_index': 'index=*wineventlog*',
    'get_all_dc_index': 'index=*wineventlog* host=*dc*',
    'get_all_antivirus_index': 'index=*av*',
}


class mySPLListener(SPLListener):
    used_fields = set()
    def enterField_comparison_expr(self, ctx):
        return
        print(ctx)

    def enterFieldname(self, ctx:SPLParser.FieldnameContext):
        print(ctx.getText())
        self.used_fields.add(ctx.getText())

    def enterWildcard_expr(self, ctx:SPLParser.Wildcard_exprContext):
        print(ctx.R_WILDCARD())
        print(ctx.LR_WILDCARD())
        pass

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
    spl = 'search index=av [ | inputlookup UC01003-lsass_dump_detection-pattern | fields - SOCComment | format] NOT [ | inputlookup UC01003-lsass_dump_detection-whitelist | fields - SOCComment ] | table'
    spl = 'search index=av [| inputlookup UC01003-lsass_dump_detection-pattern | fields - SOCComment | format] | table'
    spl = 'search xindex="*av*" kikoo [| inputlookup bar] | table foo'
    spl = 'search xindex="*av*" "kikoo" "gogo" | table foobar'
    spl = 'search xindex="*av*" kikoo gogo | table foobar'
    spl = 'search  kikoo gogo xindex="*av*" | table foobar'
    spl = 'search  "kikoo" 123 gogo tata* foo bar xyz=123 xindex=*av* | table foobar'
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
    stream = antlr4.InputStream(spl)
    lexer = SPLLexer(stream)
    stream = antlr4.CommonTokenStream(lexer)
    parser = SPLParser(stream)
    tree = parser.stat()

    #print(beautify_lisp_string(tree.toStringTree(recog=parser)))

    printer = mySPLListener()
    walker = antlr4.ParseTreeWalker()
    walker.walk(printer, tree)

    print('List of fields')
    for field in printer.used_fields:
        print(f'  - {field}')
    return tree

conf = open(sys.argv[1]).read()

conf_fixed = re.sub('\\\s*\n', ' ', conf, flags=re.MULTILINE)
c = configparser.ConfigParser()
c.read_string(conf_fixed)
for name, x in c.items():
  if not 'search' in x:
      continue
  spl_query = x['search']
  tree = parse(spl_query)
  sys.exit(1)


