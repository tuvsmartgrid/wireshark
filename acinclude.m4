dnl Macros that test for specific features.
dnl This file is part of the Autoconf packaging for Ethereal.
dnl Copyright (C) 1998-2000 by Gerald Combs.
dnl
dnl $Id$
dnl
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2, or (at your option)
dnl any later version.
dnl
dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program; if not, write to the Free Software
dnl Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
dnl 02111-1307, USA.
dnl
dnl As a special exception, the Free Software Foundation gives unlimited
dnl permission to copy, distribute and modify the configure scripts that
dnl are the output of Autoconf.  You need not follow the terms of the GNU
dnl General Public License when using or distributing such scripts, even
dnl though portions of the text of Autoconf appear in them.  The GNU
dnl General Public License (GPL) does govern all other use of the material
dnl that constitutes the Autoconf program.
dnl
dnl Certain portions of the Autoconf source text are designed to be copied
dnl (in certain cases, depending on the input) into the output of
dnl Autoconf.  We call these the "data" portions.  The rest of the Autoconf
dnl source text consists of comments plus executable code that decides which
dnl of the data portions to output in any given case.  We call these
dnl comments and executable code the "non-data" portions.  Autoconf never
dnl copies any of the non-data portions into its output.
dnl
dnl This special exception to the GPL applies to versions of Autoconf
dnl released by the Free Software Foundation.  When you make and
dnl distribute a modified version of Autoconf, you may extend this special
dnl exception to the GPL to apply to your modified version as well, *unless*
dnl your modified version has the potential to copy into its output some
dnl of the text that was the non-data portion of the version that you started
dnl with.  (In other words, unless your change moves or copies text from
dnl the non-data portions to the data portions.)  If your modification has
dnl such potential, you must delete any notice of this special exception
dnl to the GPL from your modified version.
dnl
dnl Written by David MacKenzie, with help from
dnl Franc,ois Pinard, Karl Berry, Richard Pixley, Ian Lance Taylor,
dnl Roland McGrath, Noah Friedman, david d zuhn, and many others.

#
# AC_ETHEREAL_ADD_DASH_L
#
# Add to the variable specified as the first argument a "-L" flag for the
# directory specified as the second argument, and, on Solaris, add a
# "-R" flag for it as well.
#
# XXX - IRIX, and other OSes, may require some flag equivalent to
# "-R" here.
#
AC_DEFUN([AC_ETHEREAL_ADD_DASH_L],
[$1="$$1 -L$2"
case "$host_os" in
  solaris*)
    $1="$$1 -R$2"
  ;;
esac
])


#
# AC_ETHEREAL_STRUCT_SA_LEN
#
dnl AC_STRUCT_ST_BLKSIZE extracted from the file in question,
dnl "acspecific.m4" in GNU Autoconf 2.12, and turned into
dnl AC_ETHEREAL_STRUCT_SA_LEN, which checks if "struct sockaddr"
dnl has the 4.4BSD "sa_len" member, and defines HAVE_SA_LEN; that's
dnl what's in this file.
dnl Done by Guy Harris <guy@alum.mit.edu> on 1998-11-14. 

dnl ### Checks for structure members

AC_DEFUN([AC_ETHEREAL_STRUCT_SA_LEN],
[AC_CACHE_CHECK([for sa_len in struct sockaddr], ac_cv_ethereal_struct_sa_len,
[AC_TRY_COMPILE([#include <sys/types.h>
#include <sys/socket.h>], [struct sockaddr s; s.sa_len;],
ac_cv_ethereal_struct_sa_len=yes, ac_cv_ethereal_struct_sa_len=no)])
if test $ac_cv_ethereal_struct_sa_len = yes; then
  AC_DEFINE(HAVE_SA_LEN, 1, [Define if sa_len field exists in struct sockaddr])
fi
])


dnl
dnl Check whether a given format can be used to print 64-bit integers
dnl
AC_DEFUN([AC_ETHEREAL_CHECK_64BIT_FORMAT],
[
  AC_MSG_CHECKING([whether %$1x can be used to format 64-bit integers])
  AC_RUN_IFELSE(
    [
      AC_LANG_SOURCE(
	[[
#	  ifdef HAVE_INTTYPES_H
	  #include <inttypes.h>
#	  endif
	  #include <glib.h>
	  #include <stdio.h>
	  #include <sys/types.h>

	  main()
	  {
	    guint64 t = 1;
	    char strbuf[16+1];
	    sprintf(strbuf, "%016$1x", t << 32);
	    if (strcmp(strbuf, "0000000100000000") == 0)
	      exit(0);
	    else
	      exit(1);
	  }
	]])
    ],
    [
      AC_DEFINE(PRId64, "$1d", [Format for printing 64-bit signed decimal numbers])
      AC_DEFINE(PRIo64, "$1o", [Format for printing 64-bit unsigned octal numbers])
      AC_DEFINE(PRIx64, "$1x", [Format for printing 64-bit unsigned hexadecimal numbers])
      AC_DEFINE(PRIu64, "$1u", [Format for printing 64-bit unsigned decimal numbers])
      AC_MSG_RESULT(yes)
    ],
    [
      AC_MSG_RESULT(no)
      $2
    ])
])

#
# AC_ETHEREAL_IPV6_STACK
#
# By Jun-ichiro "itojun" Hagino, <itojun@iijlab.net>
#
AC_DEFUN([AC_ETHEREAL_IPV6_STACK],
[
	v6type=unknown
	v6lib=none

	AC_MSG_CHECKING([ipv6 stack type])
	for i in v6d toshiba kame inria zeta linux linux-glibc solaris8; do
		case $i in
		v6d)
			AC_EGREP_CPP(yes, [
#include </usr/local/v6/include/sys/types.h>
#ifdef __V6D__
yes
#endif],
				[v6type=$i; v6lib=v6;
				v6libdir=/usr/local/v6/lib;
				CFLAGS="-I/usr/local/v6/include $CFLAGS"])
			;;
		toshiba)
			AC_EGREP_CPP(yes, [
#include <sys/param.h>
#ifdef _TOSHIBA_INET6
yes
#endif],
				[v6type=$i; v6lib=inet6;
				v6libdir=/usr/local/v6/lib;
				CFLAGS="-DINET6 $CFLAGS"])
			;;
		kame)
			AC_EGREP_CPP(yes, [
#include <netinet/in.h>
#ifdef __KAME__
yes
#endif],
				[v6type=$i; v6lib=inet6;
				v6libdir=/usr/local/v6/lib;
				CFLAGS="-DINET6 $CFLAGS"])
			;;
		inria)
			AC_EGREP_CPP(yes, [
#include <netinet/in.h>
#ifdef IPV6_INRIA_VERSION
yes
#endif],
				[v6type=$i; CFLAGS="-DINET6 $CFLAGS"])
			;;
		zeta)
			AC_EGREP_CPP(yes, [
#include <sys/param.h>
#ifdef _ZETA_MINAMI_INET6
yes
#endif],
				[v6type=$i; v6lib=inet6;
				v6libdir=/usr/local/v6/lib;
				CFLAGS="-DINET6 $CFLAGS"])
			;;
		linux)
			if test -d /usr/inet6; then
				v6type=$i
				v6lib=inet6
				v6libdir=/usr/inet6
				CFLAGS="-DINET6 $CFLAGS"
			fi
			;;
		linux-glibc)
			AC_EGREP_CPP(yes, [
#include <features.h>
#if defined(__GLIBC__) && defined(__GLIBC_MINOR__)
#if (__GLIBC__ == 2 && __GLIBC_MINOR__ >= 1) || __GLIBC__ > 2
yes
#endif
#endif],
			[v6type=$i; v6lib=inet6; CFLAGS="-DINET6 $CFLAGS"])
			;;
		solaris8)
			if test "`uname -s`" = "SunOS" && test "`uname -r`" = "5.8"; then
				v6type=$i
				v6lib=inet6
				[CFLAGS="-DINET6 -DSOLARIS8_INET6 $CFLAGS"]
			fi
			;; 
		esac
		if test "$v6type" != "unknown"; then
			break
		fi
	done

	if test "$v6lib" != "none"; then
		for dir in $v6libdir /usr/local/v6/lib /usr/local/lib; do
			if test -d $dir -a -f $dir/lib$v6lib.a; then
				LIBS="-L$dir $LIBS -l$v6lib"
				break
			fi
		done
		enable_ipv6="yes"
	else
		enable_ipv6="no"
	fi
	AC_MSG_RESULT(["$v6type, $v6lib"])
])

#
# AC_ETHEREAL_GETHOSTBY_LIB_CHECK
#
# Checks whether we need "-lnsl" to get "gethostby*()", which we use
# in "resolv.c".
#
# Adapted from stuff in the AC_PATH_XTRA macro in "acspecific.m4" in
# GNU Autoconf 2.13; the comment came from there.
# Done by Guy Harris <guy@alum.mit.edu> on 2000-01-14. 
#
AC_DEFUN([AC_ETHEREAL_GETHOSTBY_LIB_CHECK],
[
    # msh@cis.ufl.edu says -lnsl (and -lsocket) are needed for his 386/AT,
    # to get the SysV transport functions.
    # chad@anasazi.com says the Pyramid MIS-ES running DC/OSx (SVR4)
    # needs -lnsl.
    # The nsl library prevents programs from opening the X display
    # on Irix 5.2, according to dickey@clark.net.
    AC_CHECK_FUNC(gethostbyname, ,
	AC_CHECK_LIB(nsl, gethostbyname, NSL_LIBS="-lnsl"))
    AC_SUBST(NSL_LIBS)
])

#
# AC_ETHEREAL_SOCKET_LIB_CHECK
#
# Checks whether we need "-lsocket" to get "socket()", which is used
# by libpcap on some platforms - and, in effect, "gethostby*()" on
# most if not all platforms (so that it can use NIS or DNS or...
# to look up host names).
#
# Adapted from stuff in the AC_PATH_XTRA macro in "acspecific.m4" in
# GNU Autoconf 2.13; the comment came from there.
# Done by Guy Harris <guy@alum.mit.edu> on 2000-01-14. 
#
# We use "connect" because that's what AC_PATH_XTRA did.
#
AC_DEFUN([AC_ETHEREAL_SOCKET_LIB_CHECK],
[
    # lieder@skyler.mavd.honeywell.com says without -lsocket,
    # socket/setsockopt and other routines are undefined under SCO ODT
    # 2.0.  But -lsocket is broken on IRIX 5.2 (and is not necessary
    # on later versions), says simon@lia.di.epfl.ch: it contains
    # gethostby* variants that don't use the nameserver (or something).
    # -lsocket must be given before -lnsl if both are needed.
    # We assume that if connect needs -lnsl, so does gethostbyname.
    AC_CHECK_FUNC(connect, ,
      AC_CHECK_LIB(socket, connect, SOCKET_LIBS="-lsocket",
		AC_MSG_ERROR(Function 'socket' not found.), $NSL_LIBS))
    AC_SUBST(SOCKET_LIBS)
])

#
# AC_ETHEREAL_PCAP_CHECK
#
AC_DEFUN([AC_ETHEREAL_PCAP_CHECK],
[
	if test -z "$pcap_dir"
	then
	  # Pcap header checks
	  # XXX need to set a var AC_CHECK_HEADER(pcap.h,,)

	  #
	  # The user didn't specify a directory in which libpcap resides;
	  # we assume that the current library search path will work,
	  # but we may have to look for the header in a "pcap"
	  # subdirectory of "/usr/include" or "/usr/local/include",
	  # as some systems apparently put "pcap.h" in a "pcap"
	  # subdirectory, and we also check "$prefix/include" - and
	  # "$prefix/include/pcap", in case $prefix is set to
	  # "/usr/include" or "/usr/local/include".
	  #
	  # XXX - should we just add "$prefix/include" to the include
	  # search path and "$prefix/lib" to the library search path?
	  #
	  AC_MSG_CHECKING(for extraneous pcap header directories)
	  found_pcap_dir=""
	  pcap_dir_list="/usr/include/pcap $prefix/include/pcap $prefix/include"
	  if test "x$ac_cv_enable_usr_local" = "xyes" ; then
	    pcap_dir_list="$pcap_dir_list /usr/local/include/pcap"
	  fi
	  for pcap_dir in $pcap_dir_list
	  do
	    if test -d $pcap_dir ; then
		if test x$pcap_dir != x/usr/include -a x$pcap_dir != x/usr/local/include ; then
		    CFLAGS="$CFLAGS -I$pcap_dir"
		    CPPFLAGS="$CPPFLAGS -I$pcap_dir"
		fi
		found_pcap_dir=" $found_pcap_dir -I$pcap_dir"
		break
	    fi
	  done

	  if test "$found_pcap_dir" != "" ; then
	    AC_MSG_RESULT(found --$found_pcap_dir added to CFLAGS)
	  else
	    AC_MSG_RESULT(not found)
	  fi
	else
	  #
	  # The user specified a directory in which libpcap resides,
	  # so add the "include" subdirectory of that directory to
	  # the include file search path and the "lib" subdirectory
	  # of that directory to the library search path.
	  #
	  # XXX - if there's also a libpcap in a directory that's
	  # already in CFLAGS, CPPFLAGS, or LDFLAGS, this won't
	  # make us find the version in the specified directory,
	  # as the compiler and/or linker will search that other
	  # directory before it searches the specified directory.
	  #
	  CFLAGS="$CFLAGS -I$pcap_dir/include"
	  CPPFLAGS="$CPPFLAGS -I$pcap_dir/include"
	  AC_ETHEREAL_ADD_DASH_L(LDFLAGS, $pcap_dir/lib)
	fi

	# Pcap header check
	AC_CHECK_HEADER(pcap.h,, 
	    AC_MSG_ERROR([[Header file pcap.h not found; if you installed libpcap
from source, did you also do \"make install-incl\", and if you installed a
binary package of libpcap, is there also a developer's package of libpcap,
and did you also install that package?]]))

	#
	# Check to see if we find "pcap_open_live" in "-lpcap".
	#
	AC_CHECK_LIB(pcap, pcap_open_live,
	  [
	    PCAP_LIBS=-lpcap
	    AC_DEFINE(HAVE_LIBPCAP, 1, [Define to use libpcap library])
	  ], [
	    AC_MSG_CHECKING([for pcap_open_live in -lpcap -lcfg -lodm])
	    ac_save_LIBS="$LIBS"
	    LIBS="-lpcap -lcfg -lodm"
	    AC_TRY_LINK(
		[
#	include <pcap.h>
		],
		[
	pcap_open_live(NULL, 0, 0, 0, NULL);
		],
		[
		AC_MSG_RESULT([yes])
		PCAP_LIBS="-lpcap -lcfg -lodm"
		AC_DEFINE(HAVE_LIBPCAP, 1, [Define to use libpcap library])
		],
		[
		AC_MSG_RESULT([no])
		AC_MSG_ERROR([Library libpcap not found.])
		])
	    LIBS=$ac_save_LIBS
	  ], $SOCKET_LIBS $NSL_LIBS)
	AC_SUBST(PCAP_LIBS)

	#
	# Check whether various variables and functions are defined by
	# libpcap.
	#
	ac_save_LIBS="$LIBS"
	AC_MSG_CHECKING(whether pcap_version is defined by libpcap)
	LIBS="$PCAP_LIBS $SOCKET_LIBS $NSL_LIBS $LIBS"
	AC_TRY_LINK(
	   [
#	include <stdio.h>
	extern char *pcap_version;
	   ],
	   [
	printf ("%s\n", pcap_version);
	   ],
	   ac_cv_pcap_version_defined=yes,
	   ac_cv_pcap_version_defined=no,
	   [echo $ac_n "cross compiling; assumed OK... $ac_c"])
	if test "$ac_cv_pcap_version_defined" = yes ; then
		AC_MSG_RESULT(yes)
		AC_DEFINE(HAVE_PCAP_VERSION, 1, [Define if libpcap version is known])
	else
		AC_MSG_RESULT(no)
	fi
	AC_CHECK_FUNCS(pcap_open_dead)
	#
	# Later versions of Mac OS X 10.3[.x] ship a pcap.h that
	# doesn't define pcap_if_t but ship an 0.8[.x] libpcap,
	# so the library has "pcap_findalldevs()", but pcap.h
	# doesn't define "pcap_if_t" so you can't actually *use*
	# "pcap_findalldevs()".
	#
	# That even appears to be true of systems shipped with
	# 10.3.4, so it doesn't appear only to be a case of
	# Software Update not updating header files.
	#
	# (You can work around this by installing the 0.8 header
	# files.)
	#
	AC_CACHE_CHECK([whether pcap_findalldevs is present and usable],
	  [ac_cv_func_pcap_findalldevs],
	  [
	    AC_LINK_IFELSE(
	      [
		AC_LANG_SOURCE(
		  [[
		    #include <pcap.h>
		    main()
		    {
		      pcap_if_t *devpointer;
		      char errbuf[1];

		      pcap_findalldevs(&devpointer, errbuf);
		    }
		  ]])
	      ],
	      [
		ac_cv_func_pcap_findalldevs=yes
	      ],
	      [
		ac_cv_func_pcap_findalldevs=no
	      ])
	  ])
	#
	# Don't check for other new routines that showed up after
	# "pcap_findalldevs()" if we don't have a usable
	# "pcap_findalldevs()", so we don't end up using them if the
	# "pcap.h" is crufty and old and doesn't declare them.
	#
	if test $ac_cv_func_pcap_findalldevs = "yes" ; then
	  AC_DEFINE(HAVE_PCAP_FINDALLDEVS, 1,
	   [Define to 1 if you have the `pcap_findalldevs' function and a pcap.h that declares pcap_if_t.'])
	  AC_CHECK_FUNCS(pcap_datalink_val_to_name pcap_datalink_name_to_val)
	  AC_CHECK_FUNCS(pcap_list_datalinks pcap_set_datalink pcap_lib_version)
	fi
	LIBS="$ac_save_LIBS"
])

#
# AC_ETHEREAL_ZLIB_CHECK
#
AC_DEFUN([AC_ETHEREAL_ZLIB_CHECK],
[
	if test "x$zlib_dir" != "x"
	then
	  #
	  # The user specified a directory in which zlib resides,
	  # so add the "include" subdirectory of that directory to
	  # the include file search path and the "lib" subdirectory
	  # of that directory to the library search path.
	  #
	  # XXX - if there's also a zlib in a directory that's
	  # already in CFLAGS, CPPFLAGS, or LDFLAGS, this won't
	  # make us find the version in the specified directory,
	  # as the compiler and/or linker will search that other
	  # directory before it searches the specified directory.
	  #
	  ethereal_save_CFLAGS="$CFLAGS"
	  CFLAGS="$CFLAGS -I$zlib_dir/include"
	  ethereal_save_CPPFLAGS="$CPPFLAGS"
	  CPPFLAGS="$CPPFLAGS -I$zlib_dir/include"
	  ethereal_save_LIBS="$LIBS"
	  AC_ETHEREAL_ADD_DASH_L(LIBS, $zlib_dir/lib)
	fi

	#
	# Make sure we have "zlib.h".  If we don't, it means we probably
	# don't have zlib, so don't use it.
	#
	AC_CHECK_HEADER(zlib.h,,
	  [
	    if test "x$zlib_dir" != "x"
	    then
	      #
	      # The user used "--with-zlib=" to specify a directory
	      # containing zlib, but we didn't find the header file
	      # there; that either means they didn't specify the
	      # right directory or are confused about whether zlib
	      # is, in fact, installed.  Report the error and give up.
	      #
	      AC_MSG_ERROR([zlib header not found in directory specified in --with-zlib])
	    else
	      if test "x$want_zlib" = "xyes"
	      then
		#
		# The user tried to force us to use the library, but we
		# couldn't find the header file; report an error.
		#
		AC_MSG_ERROR(Header file zlib.h not found.)
	      else
		#
		# We couldn't find the header file; don't use the
		# library, as it's probably not present.
		#
		want_zlib=no
	      fi
	    fi
	  ])

	if test "x$want_zlib" != "xno"
	then
		#
		# Well, we at least have the zlib header file.
		#
		# Check for "gzgets()" in zlib, because we need it, but
		# some older versions of zlib don't have it.  It appears
		# from the zlib ChangeLog that any released version of zlib
		# with "gzgets()" should have the other routines we
		# depend on, such as "gzseek()", "gztell()", and "zError()".
		#
		# Another reason why we require "gzgets()" is that
		# some versions of zlib that didn't have it, such
		# as 1.0.8, had a bug in "gzseek()" that meant that it
		# doesn't work correctly on uncompressed files; this
		# means we cannot use version 1.0.8.  (Unfortunately,
		# that's the version that comes with recent X11 source,
		# and many people who install XFree86 on their Slackware
		# boxes don't realize that they should configure it to
		# use the native zlib rather than building and installing
		# the crappy old version that comes with XFree86.)
		#
		# I.e., we can't just avoid using "gzgets()", as
		# versions of zlib without "gzgets()" are likely to have
		# a broken "gzseek()".
		#
		AC_CHECK_LIB(z, gzgets,
		[
			if test "x$zlib_dir" != "x"
			then
				#
				# Put the "-I" and "-L" flags for zlib at
				# the beginning of CFLAGS, CPPFLAGS, and
				# LIBS.
				#
				LIBS=""
				AC_ETHEREAL_ADD_DASH_L(LIBS, $zlib_dir/lib)
				LIBS="$LIBS -lz $ethereal_save_LIBS"
			else
				LIBS="-lz $LIBS"
			fi
			AC_DEFINE(HAVE_LIBZ, 1, [Define to use libz library])
		],[
			if test "x$zlib_dir" != "x"
			then
				#
				# Restore the versions of CFLAGS, CPPFLAGS,
				# and LIBS before we added the "-with-zlib="
				# directory, as we didn't actually find
				# zlib there, or didn't find a zlib that
				# contains gzgets there.
				#
			        CFLAGS="$ethereal_save_CFLAGS"
				CPPFLAGS="$ethereal_save_CPPFLAGS"
				LIBS="$ethereal_save_LIBS"
			fi
			want_zlib=no
		])
	fi

	if test "x$want_zlib" != "xno"
	then
		#
		# Well, we at least have the zlib header file and a zlib
		# with "gzgets()".
		#
		# Now check for "gzgets()" in zlib when linking with the
		# linker flags for GTK+ applications; people often grab
		# XFree86 source and build and install it on their systems,
		# and they appear sometimes to misconfigure XFree86 so that,
		# even on systems with zlib, it assumes there is no zlib,
		# so the XFree86 build process builds and installs its
		# own zlib in the X11 library directory.
		#
		# The XFree86 zlib is an older version that lacks
		# "gzgets()", and that's the zlib with which Ethereal
		# gets linked, so the build of Ethereal fails.
		#
		ac_save_CFLAGS="$CFLAGS"
		ac_save_LIBS="$LIBS"
		CFLAGS="$CFLAGS $GTK_CFLAGS"
		LIBS="$GTK_LIBS -lz $LIBS"
		AC_MSG_CHECKING([for gzgets missing when linking with X11])
	        AC_TRY_LINK_FUNC(gzgets, AC_MSG_RESULT(no),
		  [
		    AC_MSG_RESULT(yes)
		    AC_MSG_ERROR(old zlib found when linking with X11 - get rid of old zlib.)
		  ])
		CFLAGS="$ac_save_CFLAGS"
		LIBS="$ac_save_LIBS"
	fi
])

#
# AC_ETHEREAL_LIBPCRE_CHECK
#
AC_DEFUN([AC_ETHEREAL_LIBPCRE_CHECK],
[
	if test "x$pcre_dir" != "x"
	then
	  #
	  # The user specified a directory in which libpcre resides,
	  # so add the "include" subdirectory of that directory to
	  # the include file search path and the "lib" subdirectory
	  # of that directory to the library search path.
	  #
	  # XXX - if there's also a libpcre in a directory that's
	  # already in CFLAGS, CPPFLAGS, or LDFLAGS, this won't
	  # make us find the version in the specified directory,
	  # as the compiler and/or linker will search that other
	  # directory before it searches the specified directory.
	  #
	  ethereal_save_CFLAGS="$CFLAGS"
	  CFLAGS="$CFLAGS -I$pcre_dir/include"
	  ethereal_save_CPPFLAGS="$CPPFLAGS"
	  CPPFLAGS="$CPPFLAGS -I$pcre_dir/include"
	  ethereal_save_LIBS="$LIBS"
	  LIBS="$LIBS -lpcre"
	  ethereal_save_LDFLAGS="$LDFLAGS"
	  LDFLAGS="$LDFLAGS -L$pcre_dir/lib"
	fi

	#
	# Make sure we have "pcre.h".  If we don't, it means we probably
	# don't have libpcre, so don't use it.
	#
	AC_CHECK_HEADER(pcre.h,,
	  [
	    if test "x$pcre_dir" != "x"
	    then
	      #
	      # The user used "--with-pcre=" to specify a directory
	      # containing libpcre, but we didn't find the header file
	      # there; that either means they didn't specify the
	      # right directory or are confused about whether libpcre
	      # is, in fact, installed.  Report the error and give up.
	      #
	      AC_MSG_ERROR([libpcre header not found in directory specified in --with-pcre])
	    else
	      if test "x$want_pcre" = "xyes"
	      then
		#
		# The user tried to force us to use the library, but we
		# couldn't find the header file; report an error.
		#
		AC_MSG_ERROR(Header file pcre.h not found.)
	      else
		#
		# We couldn't find the header file; don't use the
		# library, as it's probably not present.
		#
		want_pcre=no
	      fi
	    fi
	  ])

	if test "x$want_pcre" != "xno"
	then
		#
		# Well, we at least have the pcre header file.
		#
		# We're only using standard functions from libpcre,
		# so we don't need to perform extra checks.
		#
		AC_CHECK_LIB(pcre, pcre_compile,
		[
			if test "x$pcre_dir" != "x"
			then
				#
				# Put the "-I" and "-L" flags for pcre at
				# the beginning of CFLAGS, CPPFLAGS,
				# LDFLAGS, and LIBS.
				#
				PCRE_LIBS="-L$pcre_dir/lib -lpcre $ethereal_save_LIBS"
			else
				PCRE_LIBS="-lpcre"
			fi
			AC_DEFINE(HAVE_LIBPCRE, 1, [Define to use libpcre library])
		],[
			if test "x$pcre_dir" != "x"
			then
				#
				# Restore the versions of CFLAGS, CPPFLAGS,
				# LDFLAGS, and LIBS before we added the
				# "--with-pcre=" directory, as we didn't
				# actually find pcre there.
				#
				CFLAGS="$ethereal_save_CFLAGS"
				CPPFLAGS="$ethereal_save_CPPFLAGS"
				LDFLAGS="$ethereal_save_LDFLAGS"
				LIBS="$ethereal_save_LIBS"
				PCRE_LIBS=""
			fi
			want_pcre=no
		])
		AC_SUBST(PCRE_LIBS)
	fi
])

#
# AC_ETHEREAL_UCDSNMP_CHECK
#
AC_DEFUN([AC_ETHEREAL_UCDSNMP_CHECK],
[
	if test "x$ucdsnmp_dir" != "x"
	then
		#
		# The user specified a directory in which UCD SNMP resides,
		# so add the "include" subdirectory of that directory to
		# the include file search path and the "lib" subdirectory
		# of that directory to the library search path.
		#
		# XXX - if there's also a libpcap in a directory that's
		# already in CFLAGS, CPPFLAGS, or LDFLAGS, this won't
		# make us find the version in the specified directory,
		# as the compiler and/or linker will search that other
		# directory before it searches the specified directory.
		#
		CFLAGS="$CFLAGS -I$ucdsnmp_dir/include"
		CPPFLAGS="$CPPFLAGS -I$ucdsnmp_dir/include"
		AC_ETHEREAL_ADD_DASH_L(LDFLAGS, $ucdsnmp_dir/lib)
	fi

	#
	# Check for one of the UCD SNMP header files we include,
	# to see whether we have UCD SNMP installed.
	#
	AC_CHECK_HEADER(ucd-snmp/ucd-snmp-config.h,
	[
		#
		# UCD SNMP or Net-SNMP might require various helper
		# libraries on various platforms, such as "-ldes425"
		# in "/usr/kerberos/lib" on some versions of Red
		# Hat Linux, or "-lkstat" on Solaris.
		# XXX - it may also require "-lcrypto" on some platforms;
		# we should check for that as well, rather than requiring
		# users to explicitly indicate whether it's required.
		#
		# XXX - autoconf really needs a way to test for
		# a given routine in a given library *and* to test
		# whether additional "-L"/"-R"/whatever flags are
		# needed *before* the "-l" flag for the library
		# and to test whether additional libraries are
		# needed after the library *and* to cache all that
		# information.
		#
		ac_save_LIBS="$LIBS"
		for extras in "" "-L/usr/kerberos/lib -ldes425" "-lkstat"
		do
			LIBS="-lsnmp $extras $SOCKET_LIBS $NSL_LIBS $SSL_LIBS"
			AC_TRY_LINK(
			[
			],
			[
			sprint_realloc_objid();
			],
			[
			SNMP_LIBS="-lsnmp $extras"; break;
			],
			[
			])
			
#        int sprint_realloc_objid(u_char **buf, size_t *buf_len, size_t *out_len, int allow_realloc, const oid *objid, size_t objidlen);
#        AC_TRY_LINK(includes, body, [if-found], [if-not-found])
#			AC_CHECK_LIB(snmp, sprint_realloc_objid,
#			  [
#				SNMP_LIBS="-lsnmp $extras"; break
#			  ],
#			  [
#				#
#				# Throw away the cached "we didn't find it"
#				# answer, so that if we rerun "configure",
#				# we still do all these checks and don't
#				# just blithely assume we don't need
#				# the extra libraries.
#				#
#				unset ac_cv_lib_snmp_sprint_realloc_objid
#			  ], $SOCKET_LIBS $NSL_LIBS $SSL_LIBS $extras)
		done
		LIBS=$ac_save_LIBS

		#
		# If we didn't find "sprint_realloc_objid()", fail.
		# Either the user needs a newer version of UCD SNMP
		# with "sprint_realloc_objid()", or they may need to
		# specify "--with-ssl".
		#
		if test "$ac_cv_lib_snmp_sprint_realloc_objid" = no; then
		    AC_MSG_ERROR([UCD SNMP header files found, but sprint_realloc_objid not found in SNMP library.])
		fi

		#
		# We found it, so we have UCD SNMP.
		#
		AC_DEFINE(HAVE_UCD_SNMP, 1, [Define to enable support for UCD-SNMP])
		have_ucd_snmp="yes"
	],[
		#
		# No, we don't have it.
		# If the user explicitly asked for UCD SNMP, fail,
		# otherwise just don't use the UCD SNMP library.
		#
		if test "x$want_ucdsnmp" = "xyes" ; then
			AC_MSG_ERROR(Header file ucd-snmp/snmp.h not found.)
		fi
	])
])

#
# AC_ETHEREAL_SSL_CHECK
#
AC_DEFUN([AC_ETHEREAL_SSL_CHECK],
[
	want_ssl=defaultno

	AC_ARG_WITH(ssl,
changequote(<<, >>)dnl
<<  --with-ssl[=DIR]        use SSL crypto library (located in directory DIR, if supplied).   [default=no]>>,
changequote([, ])dnl
	[
	if   test "x$withval" = "xno";  then
		want_ssl=no
	elif test "x$withval" = "xyes"; then
		want_ssl=yes
	elif test -d "$withval"; then
		want_ssl=yes
		AC_ETHEREAL_ADD_DASH_L(LDFLAGS, ${withval}/lib)
	fi
	])

	if test "x$want_ssl" = "xdefaultyes"; then
		want_ssl=yes
		withval=/usr/local/ssl
		if test -d "$withval"; then
			AC_ETHEREAL_ADD_DASH_L(LDFLAGS, ${withval}/lib)
		fi
	fi

	if test "x$want_ssl" = "xyes"; then
	    LIBS="-lcrypto"
            AC_TRY_LINK(
                [
		void EVP_md5();
                ],
                [
        	EVP_md5();
                ],
                [
		AC_MSG_RESULT([yes])
		SSL_LIBS=-lcrypto
                ],
                [
                AC_MSG_RESULT([no])
                AC_MSG_ERROR([libcrypto failed link test.])
                ])

	else
		AC_MSG_RESULT(not required)
	fi
])

#
# AC_ETHEREAL_RPM_CHECK
# Looks for the rpm program, and checks to see if we can redefine "_topdir".
#
AC_DEFUN([AC_ETHEREAL_RPM_CHECK],
[
	AC_CHECK_PROG(ac_cv_ethereal_have_rpm, rpm, "yes", "no")
	if test "x$ac_cv_ethereal_have_rpm" = "xyes"; then
		rpm --define '_topdir /tmp' > /dev/null 2>&1
		AC_MSG_CHECKING(to see if we can redefine _topdir)
		if test $? -eq 0 ; then
			AC_MSG_RESULT(yes)
			HAVE_RPM=yes
		else
			AC_MSG_RESULT(no.  You'll have to build packages manually.)
			HAVE_RPM=no
		fi
	fi
])

#
# AC_ETHEREAL_GNU_SED_CHECK
# Checks if GNU sed is the first sed in PATH.
#
AC_DEFUN([AC_ETHEREAL_GNU_SED_CHECK],
[
	AC_MSG_CHECKING(for GNU sed as first sed in PATH)
	if  ( sh -c "sed --version" </dev/null 2> /dev/null | grep "GNU sed" 2>&1 > /dev/null ) ;  then
		AC_MSG_RESULT(yes)
		HAVE_GNU_SED=yes
	else
		AC_MSG_RESULT(no)
		HAVE_GNU_SED=no
	fi
])

#
# AC_ETHEREAL_ADNS_CHECK
#
AC_DEFUN([AC_ETHEREAL_ADNS_CHECK],
[
	want_adns=defaultyes

	AC_ARG_WITH(adns,
changequote(<<, >>)dnl
<<  --with-adns[=DIR]       use GNU ADNS (located in directory DIR, if supplied).   [default=yes, if present]>>,
changequote([, ])dnl
	[
	if   test "x$withval" = "xno";  then
		want_adns=no
	elif test "x$withval" = "xyes"; then
		want_adns=yes
	elif test -d "$withval"; then
		want_adns=yes
		AC_ETHEREAL_ADD_DASH_L(LDFLAGS, ${withval}/lib)
	fi
	])

	if test "x$want_adns" = "xdefaultyes"; then
		want_adns=yes
		withval=/usr/local
		if test -d "$withval"; then
			AC_ETHEREAL_ADD_DASH_L(LDFLAGS, ${withval}/lib)
		fi
	fi

	if test "x$want_adns" = "xyes"; then
		AC_CHECK_LIB(adns, adns_init,
		  [
		    ADNS_LIBS=-ladns
	    	AC_DEFINE(HAVE_GNU_ADNS, 1, [Define to use GNU ADNS library])
		have_good_adns=yes
		  ],, $SOCKET_LIBS $NSL_LIBS
		)
	else
		AC_MSG_RESULT(not required)
	fi
])


#
# AC_ETHEREAL_KRB5_CHECK
#
AC_DEFUN([AC_ETHEREAL_KRB5_CHECK],
[
	if test "x$krb5_dir" != "x"
	then
	  #
	  # The user specified a directory in which kerberos resides,
	  # so add the "include" subdirectory of that directory to
	  # the include file search path and the "lib" subdirectory
	  # of that directory to the library search path.
	  #
	  # XXX - if there's also a kerberos in a directory that's
	  # already in CFLAGS, CPPFLAGS, or LDFLAGS, this won't
	  # make us find the version in the specified directory,
	  # as the compiler and/or linker will search that other
	  # directory before it searches the specified directory.
	  #
	  ethereal_save_CFLAGS="$CFLAGS"
	  CFLAGS="$CFLAGS -I$krb5_dir/include"
	  ethereal_save_CPPFLAGS="$CPPFLAGS"
	  CPPFLAGS="$CPPFLAGS -I$krb5_dir/include"
	  KRB5_LIBS="-lkrb5 -lasn1 $SSL_LIBS -lroken -lcrypt -lresolv"
	  ethereal_save_LDFLAGS="$LDFLAGS"
	  LDFLAGS="$LDFLAGS -L$krb5_dir/lib"
	  ac_krb5_version=`grep -i heimdal $krb5_dir/include/krb5.h | head -n 1 | sed 's/^.*heimdal.*$/HEIMDAL/i'` 
	else
	  AC_PATH_PROG(KRB5_CONFIG, krb5-config) 
	  if test -x "$KRB5_CONFIG"
	  then
	    KRB5_FLAGS=`"$KRB5_CONFIG" --cflags`
	    CFLAGS="$CFLAGS $KRB5_FLAGS"
            CPPFLAGS="$CPPFLAGS $KRB5_FLAGS"
	    KRB5_LIBS=`"$KRB5_CONFIG" --libs | sed 's/-lcrypto//'`
	    KRB5_LIBS="$KRB5_LIBS $SSL_LIBS"
	    # Looks like krb5-config is lacking -lresolv on some systems
	    AC_MSG_CHECKING(whether library list looks OK)
	    if echo "$KRB5_LIBS" | grep resolv >/dev/null
	    then
		AC_MSG_RESULT(yes)
	    else
		KRB5_LIBS="$KRB5_LIBS -lresolv"
		AC_MSG_RESULT(Adding -lresolv to libs)
	    fi

	    #LIBS="$LIBS $KRB5_LIBS"
	    ac_krb5_version=`"$KRB5_CONFIG" --version | head -n 1 | sed 's/^.*heimdal.*$/HEIMDAL/i'`
 	  fi
	fi

	#
	# Make sure we have "krb5.h".  If we don't, it means we probably
	# don't have kerberos, so don't use it.
	#
	AC_CHECK_HEADER(krb5.h,,
	  [
	    if test "x$krb5_dir" != "x"
	    then
	      #
	      # The user used "--with-krb5=" to specify a directory
	      # containing kerberos, but we didn't find the header file
	      # there; that either means they didn't specify the
	      # right directory or are confused about whether kerberos
	      # is, in fact, installed.  Report the error and give up.
	      #
	      AC_MSG_ERROR([kerberos header not found in directory specified in --with-krb5])
	    else
	      if test "x$want_krb5" = "xyes"
	      then
		#
		# The user tried to force us to use the library, but we
		# couldn't find the header file; report an error.
		#
		AC_MSG_ERROR(Header file krb5.h not found.)
	      else
		#
		# We couldn't find the header file; don't use the
		# library, as it's probably not present.
		#
		want_krb5=no
	      fi
	    fi
	  ])

	if test "x$want_krb5" != "xno" -a "x$ac_krb5_version" = "xHEIMDAL"
	then
		#
		# Well, we at least have the krb5 header file.
		#
		AC_CHECK_LIB(krb5, krb5_kt_resolve,
		[
			if test "x$krb5_dir" != "x"
			then
				#
				# Put the "-I" and "-L" flags for krb5 at
				# the beginning of CFLAGS, CPPFLAGS,
				# LDFLAGS, and LIBS.
				#
				KRB5_LIBS="-L$krb5_dir/lib $KRB5_LIBS"
			fi
			AC_DEFINE(HAVE_KERBEROS, 1, [Define to use kerberos])
			AC_DEFINE(HAVE_HEIMDAL_KERBEROS, 1, [Define to use heimdal kerberos])
		],[
			if test "x$krb5_dir" != "x"
			then
				#
				# Restore the versions of CFLAGS, CPPFLAGS,
				# LDFLAGS, and LIBS before we added the
				# "--with-krb5=" directory, as we didn't
				# actually find kerberos there.
				#
				CFLAGS="$ethereal_save_CFLAGS"
				CPPFLAGS="$ethereal_save_CPPFLAGS"
				LDFLAGS="$ethereal_save_LDFLAGS"
				#LIBS="$ethereal_save_LIBS"
				KRB5_LIBS=""
			fi
			want_krb5=no
		], $KRB5_LIBS)
	else
		KRB5_LIBS=""
		want_krb5=no
	fi
	AC_SUBST(KRB5_LIBS)
])

