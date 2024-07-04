#!/usr/bin/env python3

import argparse
import os
import re
import subprocess
import sys
import time

#####################################################################
# Utility functions, mostly to help with rerun-until-fixpoint

from subprocess import CalledProcessError
def run_command(commandline, quiet=False):
    try:
        output=subprocess.check_output(commandline,shell=True,stderr=subprocess.STDOUT)
        output=output.decode('utf-8', errors='ignore').strip()
        return output
    except CalledProcessError as e:
        e.output = e.output.decode('utf-8', errors='ignore').strip()
        if not quiet:
            print(e.output)
        raise

def readfile(filename, splitlines=False):
    """read a file and return its contents as a string or a list of strings"""
    if not os.path.isfile(filename):
        return [] if splitlines else None
    data = open(filename,"rb").read()
    text = data.decode('utf-8',errors='ignore')
    return text.splitlines() if splitlines else text

def dict_hexdigest(some_dict, maxdigits=6):
    # utility function, to help debugging fixpoint stuff
    import hashlib
    res=dict()
    for key,value in some_dict.items():
        hasher=hashlib.md5()
        if value is not None:
            hasher.update(value.encode())
            res[key]=hasher.hexdigest()[:maxdigits]
    return str(res).replace("'","")
    
def snapshot():
    """Return a dict mapping some file names to their contents (or None for non-existent files)"""
    res=dict()

    for tool in helper_tools:
        for filename in tool.files_to_watch():
            res[filename]=readfile(filename)
 
    for line in readfile(jobname+'.fls',splitlines=True): # .fls = `pdflatex -recorder` file list
        if line[:5]== 'INPUT':
            filename = line[6:]
            if filename[0] == '/':   continue # skip absolute paths (probably from tex distro)
            if filename[:2] == './': filename=filename[2:] # uniquify 'job.aux' and './job.aux'
            if filename[-8:] == '.run.xml': continue # hack for reducing time to fixpoint
            res[filename]=readfile(filename)
    return res

#####################################################################
# Auxiliary tools to be run in between pldflatex passes

class HelperTool:
    def __init__(self):
        pass
    def files_to_watch(self): # used by `snapshot()`: any change in a file from this list triggers a recompilation
        return []
    def before_first_pass(self): pass
    def after_first_pass(self):  pass
    def before_later_pass(self): pass
    def after_later_pass(self):  pass
    
class Bibtex(HelperTool):
    def files_to_watch(self):
        if os.path.isfile(jobname+'.bcf'): return [] # use biber, not bibtex
        if not os.path.isfile(jobname+".blg"): return []
        return[ line[18:].strip()
                for line in readfile(jobname+".blg",True)
                if 'Database file' in line and '-blx.bib' not in line]

    def before_first_pass(self):
        if os.path.isfile(jobname+'.bcf'): return # use biber, not bibtex
        self.citations_before = [ line[10:-1]
                                  for line in readfile(jobname+'.aux',True)
                                  if line[:10] == r'\citation{' ]

    def after_first_pass(self):
        if os.path.isfile(jobname+'.bcf'): return # use biber, not bibtex

        bibtex_needed = False

        if os.path.isfile(jobname+'.log'):
            log=readfile(jobname+".log")
            if "No file "+jobname+".bbl" in log: # cf #03 vs #15
                # print("bibtex is needed because 'No file "+jobname+".bbl'")
                bibtex_needed = True
                
        # detect hard-coded bibliographies (and maybe other corner cases)
        # which don't use bibtex at all. (cf e.g. #15)
        if not (bibtex_needed or os.path.isfile(jobname+".bbl") or os.path.isfile(jobname+".blg")):
            return

        # design note: we rerun bibtex even if there were only warnings,
        # so as to annoy the user, hoping for them to correct their .bib
        # files :-)
        if os.path.isfile(jobname+".blg"):
            blg=readfile( jobname+".blg" )
            if "error message" in blg or "Warning--" in blg: # cf #31, #32
                # print("bibtex is needed again because previous run went poorly")
                bibtex_needed=True
                
        self.citations_after = [ line[10:-1]
                                 for line in readfile(jobname+'.aux',True)
                                 if line[:10] == r'\citation{' ]
        if set(self.citations_before) != set(self.citations_after): # cf #22, #40
            # print("bibtex is needed because some citations have been added or removed")
            bibtex_needed = True

        if os.path.isfile(jobname+".blg"): # cf #49, #50, #58
            last_bibtex_time = os.path.getmtime(jobname+".blg")
            for bibname in self.files_to_watch(): # iterate over all .bib files, cf #50
                if os.path.getmtime(bibname) >= last_bibtex_time:
                    # print("bibtex is needed because "+bibname+" is more recent that "+jobname+".blg")
                    bibtex_needed = True

        if bibtex_needed:
            print("running BibTeX on "+jobname+"...")
            bibtex_output = run_command("bibtex "+jobname)
            if "Warning--" in bibtex_output: # see design note above
                print(bibtex_output)

class Biber(HelperTool):
    def files_to_watch(self):
        if not os.path.isfile(jobname+'.bcf'): return [] # use bibtex, not biber
        return  [ line[line.index("'")+1:-1]
                  for line in readfile(jobname+'.blg',True)
                  if 'Found BibTeX data source' in line ]

    def before_first_pass(self):
        bcf=readfile(jobname+'.bcf',True)
        if bcf and bcf[-1] != '</bcf:controlfile>':
            print(f'latex-compile: biber control file {jobname}.bcf is malformed, deleting {jobname}.bbl')
            os.remove(jobname+'.bbl')

    def after_first_pass(self):
        if not os.path.isfile(jobname+'.bcf'): return  # use bibtex, not biber
        
        biber_needed=False

        # biber explicitly requests "rerun" when needed (cf #63) so we
        # don't have to figure out citations ourselves
        log=readfile(jobname+'.log')
        if "Please (re)run Biber on the file" in log:
            # print("biber is needed because log says 'Please (re)run'")
            biber_needed = True

        # design note: here we annoy the user to help them
        blg=readfile(jobname+'.blg')
        if blg and ('INFO - WARNINGS:' in blg or 'INFO - ERRORS:' in blg):
            # print("biber is needed because previous run went poorly")
            biber_needed = True

        if os.path.isfile(jobname+".blg"): # cf test-case #64
            last_biber_time = os.path.getmtime(jobname+".blg")
            for bibname in self.files_to_watch():
                if os.path.getmtime(bibname) >= last_biber_time:
                    # print("biber is needed because "+bibname+" is more recent that "+jobname+".blg")
                    biber_needed = True

        if biber_needed:
            print("running biber on "+jobname+"...")
            try:
                biber_output = run_command("biber "+jobname,quiet=True)
            except CalledProcessError as e:
                bibfile=None
                for line in e.output.splitlines():
                    if line.startswith('INFO - Found BibTeX data source'):
                        bibfile=line[1+line.index("'"):-1]
                    if line.startswith('ERROR - BibTeX subsystem:'):
                        message=line[1+line.index(","):]
                        print(bibfile+':'+message)
                raise
            if "INFO - WARNINGS:" in biber_output:
                for line in biber_output.splitlines():
                    if line.startswith('WARN - BibTeX subsystem:'):
                        should_print_this_warning = True
                        if "possible runaway string started at line" in line: # cf test-case #69
                            # workaround for https://github.com/plk/biber/issues/456
                            re_possible_runaway_string_trigger = re.compile(r' *[a-zA-z-]+ * =.*')
                            linenum = int(line.split(",")[1].strip().split(" ")[1].strip())
                            for name in self.files_to_watch():
                                contents=["dummy line zero"]+readfile(name,splitlines=True)
                                if (linenum < len(contents)
                                    and re_possible_runaway_string_trigger.match(contents[linenum])):
                                    should_print_this_warning = False
                        if should_print_this_warning:
                            print('biber warning:'+line[1+line.index(","):])
                    elif line.startswith('WARN - '):
                        print('biber warning:',line[7:])

class MakeGlossaries(HelperTool):
    def files_to_watch(self):
        return [jobname+'.glo']
    
    def before_first_pass(self):
        self.old_glo = readfile(jobname+'.glo')
        
    def after_first_pass(self):
        self.new_glo = readfile(jobname+'.glo')
        if self.old_glo != self.new_glo:
            print("running makeglossaries on "+jobname)
            run_command('makeglossaries '+jobname)
        
    before_later_pass=before_first_pass
    after_later_pass=after_first_pass

# global variable, used by `latex_full_build()` and `snapshot()`
helper_tools = [ Bibtex(), Biber(), MakeGlossaries() ] 

#####################################################################
# Pretty-print error messages and warnings

def unbreak79(sequence):
    # TeX breaks its output at 79 characters. here we rejoin the fragments
    acc=''
    for fragment in sequence:
        if len(fragment)==79:
            acc+=fragment
            continue
        yield acc+fragment
        acc=''

re_file_line_error= re.compile(r'.*:[0-9]*:.*')
re_package_error = re.compile(".*Package (?P<pkg>.*) Error: .*$")

##########################################
# Error handling logic

def pretty_print_errors():
    prefix = None
    log=readfile(jobname+'.log',splitlines=True)
    ##########################################
    # First: we locate the message in the log
    for line in unbreak79(log):
        # merge multi-line messages together. cf #14 #37
        if prefix is not None:
            if line[:len(prefix)] == prefix:
                text.append( line[len(prefix):].strip() )
            else:
                line=" ".join(text)
                break
        if "LaTeX Error:" in line: # cf #07
            break

        if "Runaway argument" in line: # cf #54
            break

        if re_package_error.match(line):
            m=re_package_error.match(line)
            prefix = "(%s)" % m.groupdict()["pkg"]
            text = [line]
            continue
            
        if re_file_line_error.search(line):
            break

    else:
        print("could not understand error ; dumping log file")
        # try to be useful even if we could not understand the log
        print("...")
        print("...")
        print("\n".join( log[-10:] )) # cf #33
        return
    ##########################################
    # Second: print the actual error message
    print(line)
    
    ##########################################
    # Third: give some details about the error
    loglinenum=1+log.index(line[:79]) # the log file itself doesn't have our unbroken lines (cf #37)
    for detail in log[loglinenum:]:
        if detail.strip() in line:
            # discard this fragment if already joined into "line"
            continue
        if prefix is not None: # iff we are dealing with a package error
            # similarly: discard long-error fragments when already joined
            if detail[ len(prefix):].strip() in line:
                continue
            # and discard generic RTFM advice
            if detail == "See the "+prefix[1:-1]+" package documentation for explanation.":
                continue
        # supress superfluous noise: RTFM, boilerplate, etc.
        if detail.strip() in ["See the LaTeX manual or LaTeX Companion for explanation.", # cf #06, #18, #37
                              "Type  H <return>  for immediate help.",  # cf #06, #14, #18, #21, #37...
                              "Type X to quit or <RETURN> to proceed,", # cf #07, #47
                              "Enter file name:","...", "<read *>",     # cf #07, #47
                              ""]:
            continue
        # suppress interactive querying for all extensions (.sty and others)
        if "or enter new name. (Default extension:" in detail: # cf #07, #47
            continue

        # sometimes there is no offending line to be reached cf #54
        if 'Runaway argument' in line and '<inserted text>' in detail:
            break

        print(detail)

        # Have we reached the offending line yet ?
        if detail[:2].startswith("l."): 
            j=log.index(detail) # kludge
            if log[j+1].strip(): # offending line is sometimes displayed broken in two pieces cf #14
                print(log[j+1].rstrip())
            break    

##########################################
# Warning handling logic
re_warning = re.compile("(Package|Class)( (?P<pkg>.*)) Warning: (?P<text>.*)$")

def pretty_print_warnings():
    text=''    # actual message to be printed on the console
    prefix=''  # in long warnings, we expect loglines to have a prefix e.g. '(hyperref)'

    tracker = Tracker()
    for line in unbreak79(readfile(jobname+".log",True)):
        tracker.process_logline(line)
        
        if len(line) == 0 and len(text)>0: # now is finally the time to spit out our message
            tracker.pprint(text)
            text=''
            prefix=''
            
        elif prefix and line.startswith(prefix):  # we are in the middle of a (prefixed)-warning
            text += ' '+line[len(prefix):]

        elif re_warning.match(line): # Class and package warnings
            m   = re_warning.match(line)
            pkg = m.groupdict()["pkg"]
            prefix = ("(%s)" % pkg).ljust(m.start("text")) # guess the prefix. BUT: can be wrong, cf #27
            text=line

        elif line.startswith('LaTeX Warning: '): # cf #05, #09, #13, #17, #27...
            text=line
            if ' Unused global option(s):' in line:
                prefix="    " # offending options on next logline, cf #46

        elif line.startswith('pdfTeX warning:'): # cf #36, #48
            tracker.pprint(line) # pdfTeX warnings are always single-line

        elif line.startswith('LaTeX Font Warning:'):
            text=line
            prefix = ("(Font)".ljust(20))

        elif line.startswith(r'Overfull ') or line.startswith(r'Underfull '): # cf #30, #34
            if options.nobadboxes is False:
                tracker.pprint(line) # bad boxes are always single-line

        elif len(text)>0: # we are in the middle of a non-prefixed warning e.g. #27
            text += ' '+line.strip()

####################
# keep track of current document page and current source file so that
# warnings and errors are reported with more meaningful info

re_page = re.compile(r'\[(?P<num>[0-9]+)(?:$|[^/0-9])')

class Tracker():
    def __init__(self):
        self.current_pagenum=1
        self.should_skip_next_line=False
        self.opened_files=[]
        self.print_all_filenames=False # Once we start printing filenames, we will print them all

        # guess maximum page number
        self.max_pagenum=0
        for line in readfile(jobname+".log",True): # cf #52
            if "Output written on "+jobname+".pdf" in line:
                self.max_pagenum=int(line.split('(')[1].split()[0])

    def process_logline(self,line):
        matches = re_page.findall(line)
        if matches:
            self.current_pagenum = max(self.current_pagenum, int(matches[-1]) + 1)
        # if line.count('(' ) + line.count(')'):
        #     print '##%d#%d##' % (line.count('('),
        #                          line.count(')') ) , line
        #     print "opened files:", tracker_opened_files

        if self.should_skip_next_line:
            self.should_skip_next_line=False
            return 

        # skip the (dangerous) line after a badbox warning, so as not to
        # be confused by text coming from the document (test-cases #35, #42)
        if line.startswith("Underfull") or line.startswith("Overfull"):
            self.should_skip_next_line=True

        # we  walk the  logline one  character  at a  time, searching  for
        # parentheses,  and tracking  nesting level.  Some of  the opening
        # parentheses are  followed by a pathname,  so we push these  on a
        # pathname stack.
        while line:
            if line[0] == ')':
                try:
                    self.opened_files.pop()
                except: # this is a workaround for #51
                    pass

            if line[0] == '(':
                suffix=line[1:]

                # if suffix does not even look like a pathname, let's not bother walking it
                if suffix[0] not in './':
                    suffix=""

                # what we want is the longest prefix of suffix that _is_ a pathname
                while suffix and not os.path.isfile(suffix):
                    suffix=suffix[:-1]

                self.opened_files.append(suffix)

            line = line[1:]

    def get_current_file(self):
        """Returns the filename where the tracker believes we are"""
        for i in range(-1, -len(self.opened_files)-1,-1):
            if self.opened_files[i]:
                return self.opened_files[i]
        return "./"+jobname+".tex" # cf #48

    def pprint(self,text):
        """Prints either `text', `file:line text', or text (page n), etc."""
        if self.print_all_filenames or (self.get_current_file() != "./"+jobname+".tex"):
            print("in file %s:"%self.get_current_file(), end=' ')
            self.print_all_filenames = True
        if self.current_pagenum > self.max_pagenum:
            # page number is obviously wrong => unhelpful => skip it
            print(text)
        else:
            print(text + " (page %d)" % self.current_pagenum)

#####################################################################
# Latex full compilation: Rerun pdflatex and friends until we reach a fixpoint

def latex_full_build():

    ####################
    # Perform first pass: pdflatex, then bibtex/biber if needed

    before=snapshot()
    
    for tool in helper_tools:
        tool.before_first_pass()
    
    print('compiling %s...' % (jobname+'.tex'))
    try:
        run_command(options.engine+' '+
                     '-halt-on-error '+
                     '-file-line-error '+
                     '-synctex=1 '+
                     '-recorder '+
                     '-shell-escape '+
                     '-interaction=nonstopmode '+
                     jobname,quiet=True)
    except CalledProcessError as e:
        pretty_print_errors()
        raise
    for tool in helper_tools:
        tool.after_first_pass()
    after=snapshot()
    # print('snapshot: ',dict_hexdigest(after))
    
    ####################
    # Perform later pass(es): rerun until fixpoint
    while before != after:
        before=snapshot()
        for tool in helper_tools:
            tool.before_later_pass()
        # print('before: ',dict_hexdigest(before))
        # print('after : ',dict_hexdigest(after))

        print('recompiling %s...' % (jobname+'.tex'))
        try:
            run_command(options.engine+' '+
                         '-halt-on-error '+
                         '-file-line-error '+
                         '-synctex=1 '+
                         '-recorder '+
                         '-shell-escape '+
                         '-interaction=nonstopmode '+
                         jobname,quiet=True)
        except CalledProcessError as e:
            # errors *may* only appear after a later pass, cf #41
            pretty_print_errors()
            raise
        for tool in helper_tools:
            tool.after_later_pass()
        after=snapshot()
        # print('snapshot: ',dict_hexdigest(after))
    
    pretty_print_warnings()

#####################################################################
# Automated software update

def selfupdate():
    import urllib.request
    try:
        urllib.request.urlretrieve('https://raw.githubusercontent.com/guillaumesalagnac/latex-compile/master/latex-compile',
                                   filename="/tmp/latex-compile")
    except urllib.error.URLError as error:
        print("Network error:",error)
        return
    old_ver = run_command("python3 "   +sys.argv[0]+" --version").rstrip().split()[1]
    new_ver = run_command("python3 /tmp/latex-compile --version").rstrip().split()[1]

    if old_ver == new_ver:
        print("Already up to date: "+old_ver)
        return
    if old_ver < new_ver:
        os.replace("/tmp/latex-compile", sys.argv[0])
        os.chmod(sys.argv[0], 0o755)
        print("Updated to newer version: "+old_ver+" -> "+new_ver)
        return

#####################################################################
# Command-line Interface

jobname=None
if __name__ == '__main__':
    ####################
    # Command-line option parsing
    argparser = argparse.ArgumentParser()
    argparser.add_argument('-v','--version', help='print version information and exit', action="version",
                           version='%(prog)s 2024-07-04')
    argparser.add_argument('-l','--loop', help='interactive mode: loop forever, recompile when needed',action="store_true")
    argparser.add_argument('-b','--nobadboxes', help='ignore warnings about overfull and underfull boxes', action="store_true")
    argparser.add_argument('--engine',help='compile with this program instead of pdflatex',default="pdflatex")
    argparser.add_argument('--selfupdate',help='download most recent version from github',action="store_true")
    argparser.add_argument('filename',metavar='FILENAME', help='your latex file')

    if "--selfupdate" in sys.argv: # not via argparse, so that FILENAME is not required
        selfupdate()
        sys.exit(0)
        
    options=argparser.parse_args()
    
    ####################
    # Argument validation
    jobname=options.filename
    if not os.path.exists(jobname+'.tex'): jobname=jobname.replace('.tex','')
    if not os.path.exists(jobname+'.tex'): 
        print(argparser.prog+": cannot find file '"+options.filename+"'")
        sys.exit(1)

    ####################
    # Main business logic
    while True:
        try:
            latex_full_build()
        except CalledProcessError:
            if not options.loop:
                sys.exit(1)
        except KeyboardInterrupt:
            print()# newline after ^C to look good
            sys.exit(1)

        if not options.loop:
            sys.exit(0)
            
        after_last_build=snapshot()
        # print(dict_hexdigest(after_last_build))
        try:
            while True:
                time.sleep(1)
                if snapshot() != after_last_build:
                    # print(dict_hexdigest(snapshot()))
                    break
        except KeyboardInterrupt:
            print()# newline after ^C to look good
            sys.exit(0)
