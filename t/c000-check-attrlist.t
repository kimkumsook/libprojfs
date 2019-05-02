#!/bin/sh
#
# Copyright (C) 2019 GitHub, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/ .

test_description='projfs test suite attribute list checks

Check that attribute lists are parsed correctly for projfs test suite.
'

. ./test-lib.sh

ECHO_ATTRLIST="$TEST_DIRECTORY/echo_attrlist"
EXPECT_DIR="$TEST_DIRECTORY/$(basename "$0" .t | sed 's/-.*//')"

MAX_NAME=256
MAX_TOTAL=1024

test_expect_success 'check missing attribute list options' '
	test_must_fail "$ECHO_ATTRLIST" &&
	test_must_fail "$ECHO_ATTRLIST" --attrlist &&
	test_must_fail "$ECHO_ATTRLIST" --attrlist-file
'

test_expect_success 'check empty attribute lists' '
	"$ECHO_ATTRLIST" --attrlist "" >empty.out &&
	"$ECHO_ATTRLIST" --attrlist "$(printf \\n)" >>empty.out &&
	touch empty.list &&
	"$ECHO_ATTRLIST" --attrlist-file empty.list >>empty.out &&
	printf "   #ignore\n\t\n##\n" >empty.list &&
	"$ECHO_ATTRLIST" --attrlist-file empty.list >>empty.out &&
	test_cmp empty.out "$EXPECT_DIR/empty.msg"
'

test_expect_success 'check simple attribute lists' '
	"$ECHO_ATTRLIST" --attrlist "n1 v1" >simple.out &&
	"$ECHO_ATTRLIST" --attrlist "n2/n2 v2/v2" >>simple.out &&
	test_cmp simple.out "$EXPECT_DIR/simple.echo"
'

test_expect_success 'check multi-line attribute lists with whitespace' '
	"$ECHO_ATTRLIST" --attrlist "  n1	v1      
				     n2/n2	  v2/v2	" >simple.out &&
	test_cmp simple.out "$EXPECT_DIR/simple.echo"
'

max_name=$(printf %0${MAX_NAME}d | tr 0 x)

#### name: with slash
#### value: empty, binary, binary with null, with slash
####   empty => remove?

#sq_empty="''"
#dq_empty='""'
#
#test_expect_success 'check attribute list name parsing' '
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "d $sq_empty 0755" &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "d $dq_empty 0755" &&
#	"$ECHO_ATTRLIST" \
#		--attrlist-file "$EXPECT_DIR/quotes.list" >quotes.out &&
#	test_cmp quotes.out "$EXPECT_DIR/quotes.echo" &&
#	test_must_fail "$ECHO_ATTRLIST" \
#		--attrlist-file "$EXPECT_DIR/badquotes1.list" &&
#	test_must_fail "$ECHO_ATTRLIST" \
#		--attrlist-file "$EXPECT_DIR/badquotes2.list" &&
#	test_must_fail "$ECHO_ATTRLIST" \
#		--attrlist-file "$EXPECT_DIR/badquotes3.list"
#'
#
## 2*NAME_MAX + 93*"x" + "d " + " 0775" == MAX_ATTRLIST_ENTRY_LEN
#max_line="d $max_name$max_name$(printf %093d | tr 0 x) 0755"
#
#test_expect_success NAME_MAX 'check attribute list name maximum length' '
#	"$ECHO_ATTRLIST" --attrlist "l $max_name $max_name" &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "l x$max_name x" 2>&1 | \
#		grep "invalid entry name (too long)" &&
#	echo "f x 0644 0 x$max_name" >long.list &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist-file long.list 2>&1 | \
#		grep "invalid entry source path (too long)" &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "l x x$max_name" 2>&1 | \
#		grep "invalid entry target path (too long)" &&
#	echo "l x$max_name x$max_name" >long.list &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist-file long.list 2>&1 | \
#		grep "invalid entry name (too long)" &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "$max_line" 2>&1 | \
#		grep "invalid entry name (too long)"
#'
#
#long_line="l $max_name$max_name $max_name$max_name"
#
#test_expect_success NAME_MAX 'check attribute list entry maximum length' '
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "x$max_line" 2>&1 | \
#		grep "invalid entry (line too long)" &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "$long_line" 2>&1 | \
#		grep "invalid entry (line too long)" &&
#	echo "$long_line" >long.list &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist-file long.list 2>&1 | \
#		grep "invalid entry (line too long)"
#'
#
#test_expect_success 'check invalid file attribute lists' '
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "f f1 0755 10 s1 extra" &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "f" &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "f f1" &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "f f1 0644" &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "f f1 0644 10" &&
#	test_must_fail "$ECHO_ATTRLIST" --attrlist "f f1/f2 0755 10 s1"
#'

test_expect_success 'check attribute list option precedence' '
	echo "n1 v1" >ignore.list &&
	"$ECHO_ATTRLIST" --attrlist "n2 v2" \
		--attrlist-file ignore.list >ignore.out &&
	test_cmp ignore.out "$EXPECT_DIR/ignore.echo"
'

#test_expect_success 'check attribute list file parsing' '
#	printf "   #ignore\n\t\n##\n" >file.list &&
#	echo "f f1 0644 0xFf s1" >>file.list &&
#	printf "   #ignore\n\t\n##\n" >>file.list &&
#	printf "d x\001x\rx\177x\377x 0755\n" >>file.list &&
#	echo "f f1 00000 0 s1/f1" >>file.list &&
#	echo "l l1 ///t1///f1///" >>file.list &&
#	echo "f f1 0644 $big_num s1" >>file.list &&
#	printf "   #ignore\n\t\n##\n" >>file.list &&
#	echo "d \"d1   d1\" 07777" >>file.list &&
#	head -n 1 "$EXPECT_DIR/quotes.list" >>file.list &&
#	printf "   #ignore\n\t\n##\n" >>file.list &&
#	"$ECHO_ATTRLIST" --attrlist-file file.list >file.out &&
#	test_cmp file.out "$EXPECT_DIR/file.echo"
#'

test_done

# vim: set ft=sh:
