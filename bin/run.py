# MIT License
#
#  Copyright (c) 2020, Bert Verrycken, bertv@verrycken.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from pathlib import Path
from vunit   import VUnit
import os

# Where are we
key = 'PRJ_NAME'
PRJNAME  = os.getenv(key)
SRC_PATH = Path(__file__).parent
SRC_PATH_RES = SRC_PATH.resolve()
SRC_PATH_PTS = SRC_PATH_RES.parts

CNT=99 # absurd value
UNIT=""
for i in SRC_PATH_PTS:
    if (i == PRJNAME):
        CNT = 0 # root of project found
    else:
        CNT+=1

VU = VUnit.from_argv()
VU.add_osvvm()
VU.add_verification_components()

#print("level", SRC_PATH_PTS[-1], CNT)
LEVEL=SRC_PATH_PTS[-1]
if (CNT==0):
    print("level", SRC_PATH_PTS[-1])
if (CNT==1):
    print("hdlsrc level", SRC_PATH_PTS[-1])
if (CNT==2):
    print("UNIT level", SRC_PATH_PTS[-1])
    SRC_PATH = Path(__file__).parent / "rtl"
    if (Path(SRC_PATH).exists()):
        LIB=VU.add_library(LEVEL)
        FILES=LIB.add_source_files([SRC_PATH / "*.vhd"])
        VU.main()
    else:
        print("This path doesn't exist")
if (CNT>2):
    print("Level not supported") # Something went wrong
    raise SystemExit
