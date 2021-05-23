pushd zlib
nmake -f win32/Makefile.msc
mkdir include
mkdir lib
copy zconf.h include
copy zlib.h include
copy zutil.h include
copy zlib.lib lib
copy zlib.pdb lib
nmake -f win32/Makefile.msc clean
popd
pushd curl
call buildconf.bat
cd winbuild\
nmake /f Makefile.vc mode=static ENABLE_UNICODE=yes DEBUG=no GEN_PDB=no MACHINE=x64 WITH_PREFIX=..\build WITH_ZLIB=static ZLIB_PATH=..\..\zlib
popd

:eof