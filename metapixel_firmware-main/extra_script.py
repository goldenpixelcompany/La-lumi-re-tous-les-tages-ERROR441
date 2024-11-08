Import("env")
import subprocess

version_string = subprocess.run("git describe --always --tags --dirty".split(' '), capture_output=True, text=True).stdout

env.Replace(PROGNAME="firmware_%s" % version_string.strip())