This implements D language support in the GCC back end, and adds
relevant documentation about the GDC front end.
---

--- a/gcc/config/rs6000/rs6000.c
+++ b/gcc/config/rs6000/rs6000.c
@@ -31980,11 +31980,12 @@ rs6000_output_function_epilogue (FILE *file,
 	 use language_string.
 	 C is 0.  Fortran is 1.  Pascal is 2.  Ada is 3.  C++ is 9.
 	 Java is 13.  Objective-C is 14.  Objective-C++ isn't assigned
-	 a number, so for now use 9.  LTO, Go and JIT aren't assigned numbers
-	 either, so for now use 0.  */
+	 a number, so for now use 9.  LTO, Go, D, and JIT aren't assigned
+	 numbers either, so for now use 0.  */
       if (lang_GNU_C ()
 	  || ! strcmp (language_string, "GNU GIMPLE")
 	  || ! strcmp (language_string, "GNU Go")
+	  || ! strcmp (language_string, "GNU D")
 	  || ! strcmp (language_string, "libgccjit"))
 	i = 0;
       else if (! strcmp (language_string, "GNU F77")
--- a/gcc/doc/frontends.texi
+++ b/gcc/doc/frontends.texi
@@ -9,6 +9,7 @@
 @cindex GNU Compiler Collection
 @cindex GNU C Compiler
 @cindex Ada
+@cindex D
 @cindex Fortran
 @cindex Go
 @cindex Objective-C
@@ -16,7 +17,7 @@
 GCC stands for ``GNU Compiler Collection''.  GCC is an integrated
 distribution of compilers for several major programming languages.  These
 languages currently include C, C++, Objective-C, Objective-C++,
-Fortran, Ada, Go, and BRIG (HSAIL).
+Fortran, Ada, D, Go, and BRIG (HSAIL).
 
 The abbreviation @dfn{GCC} has multiple meanings in common use.  The
 current official meaning is ``GNU Compiler Collection'', which refers
--- a/gcc/doc/install.texi
+++ b/gcc/doc/install.texi
@@ -916,7 +916,7 @@ only for the listed packages.  For other packages, only static libraries
 will be built.  Package names currently recognized in the GCC tree are
 @samp{libgcc} (also known as @samp{gcc}), @samp{libstdc++} (not
 @samp{libstdc++-v3}), @samp{libffi}, @samp{zlib}, @samp{boehm-gc},
-@samp{ada}, @samp{libada}, @samp{libgo}, and @samp{libobjc}.
+@samp{ada}, @samp{libada}, @samp{libgo}, @samp{libobjc}, and @samp{libphobos}.
 Note @samp{libiberty} does not support shared libraries at all.
 
 Use @option{--disable-shared} to build only static libraries.  Note that
@@ -1626,12 +1626,12 @@ their runtime libraries should be built.  For a list of valid values for
 grep ^language= */config-lang.in
 @end smallexample
 Currently, you can use any of the following:
-@code{all}, @code{default}, @code{ada}, @code{c}, @code{c++}, @code{fortran},
-@code{go}, @code{jit}, @code{lto}, @code{objc}, @code{obj-c++}.
+@code{all}, @code{default}, @code{ada}, @code{c}, @code{c++}, @code{d},
+@code{fortran}, @code{go}, @code{jit}, @code{lto}, @code{objc}, @code{obj-c++}.
 Building the Ada compiler has special requirements, see below.
 If you do not pass this flag, or specify the option @code{default}, then the
 default languages available in the @file{gcc} sub-tree will be configured.
-Ada, Go, Jit, and Objective-C++ are not default languages.  LTO is not a
+Ada, D, Go, Jit, and Objective-C++ are not default languages.  LTO is not a
 default language, but is built by default because @option{--enable-lto} is
 enabled by default.  The other languages are default languages.  If
 @code{all} is specified, then all available languages are built.  An
@@ -2715,7 +2715,7 @@ on a simulator as described at @uref{http://gcc.gnu.org/simtest-howto.html}.
 
 In order to run sets of tests selectively, there are targets
 @samp{make check-gcc} and language specific @samp{make check-c},
-@samp{make check-c++}, @samp{make check-fortran},
+@samp{make check-c++}, @samp{make check-d} @samp{make check-fortran},
 @samp{make check-ada}, @samp{make check-objc}, @samp{make check-obj-c++},
 @samp{make check-lto}
 in the @file{gcc} subdirectory of the object directory.  You can also
--- a/gcc/doc/invoke.texi
+++ b/gcc/doc/invoke.texi
@@ -1345,6 +1345,15 @@ Go source code.
 @item @var{file}.brig
 BRIG files (binary representation of HSAIL).
 
+@item @var{file}.d
+D source code.
+
+@item @var{file}.di
+D interface file.
+
+@item @var{file}.dd
+D documentation code (Ddoc).
+
 @item @var{file}.ads
 Ada source code file that contains a library unit declaration (a
 declaration of a package, subprogram, or generic, or a generic
@@ -1391,6 +1400,7 @@ objective-c  objective-c-header  objective-c-cpp-output
 objective-c++ objective-c++-header objective-c++-cpp-output
 assembler  assembler-with-cpp
 ada
+d
 f77  f77-cpp-input f95  f95-cpp-input
 go
 brig
--- a/gcc/doc/sourcebuild.texi
+++ b/gcc/doc/sourcebuild.texi
@@ -106,6 +106,10 @@ The Objective-C and Objective-C++ runtime library.
 @item libquadmath
 The runtime support library for quad-precision math operations.
 
+@item libphobos
+The D standard and runtime library.  The bulk of this library is mirrored
+from the @uref{https://github.com/@/dlang, master D repositories}.
+
 @item libssp
 The Stack protector runtime library.
 
--- a/gcc/doc/standards.texi
+++ b/gcc/doc/standards.texi
@@ -309,6 +309,12 @@ capability is typically utilized to implement the HSA runtime API's HSAIL
 finalization extension for a gcc supported processor. HSA standards are
 freely available at @uref{http://www.hsafoundation.com/standards/}.
 
+@section D language
+
+GCC supports the D 2.0 programming language.  The D language itself is
+currently defined by its reference implementation and supporting language
+specification, described at @uref{https://dlang.org/spec/spec.html}.
+
 @section References for Other Languages
 
 @xref{Top, GNAT Reference Manual, About This Guide, gnat_rm,
--- a/gcc/dwarf2out.c
+++ b/gcc/dwarf2out.c
@@ -5083,6 +5083,16 @@ is_ada (void)
   return lang == DW_LANG_Ada95 || lang == DW_LANG_Ada83;
 }
 
+/* Return TRUE if the language is D.  */
+
+static inline bool
+is_dlang (void)
+{
+  unsigned int lang = get_AT_unsigned (comp_unit_die (), DW_AT_language);
+
+  return lang == DW_LANG_D;
+}
+
 /* Remove the specified attribute if present.  Return TRUE if removal
    was successful.  */
 
@@ -23599,6 +23609,8 @@ gen_compile_unit_die (const char *filename)
 	language = DW_LANG_ObjC;
       else if (strcmp (language_string, "GNU Objective-C++") == 0)
 	language = DW_LANG_ObjC_plus_plus;
+      else if (strcmp (language_string, "GNU D") == 0)
+	language = DW_LANG_D;
       else if (dwarf_version >= 5 || !dwarf_strict)
 	{
 	  if (strcmp (language_string, "GNU Go") == 0)
@@ -25182,7 +25194,7 @@ declare_in_namespace (tree thing, dw_die_ref context_die)
 
   if (ns_context != context_die)
     {
-      if (is_fortran ())
+      if (is_fortran () || is_dlang ())
 	return ns_context;
       if (DECL_P (thing))
 	gen_decl_die (thing, NULL, NULL, ns_context);
@@ -25205,7 +25217,7 @@ gen_namespace_die (tree decl, dw_die_ref context_die)
     {
       /* Output a real namespace or module.  */
       context_die = setup_namespace_context (decl, comp_unit_die ());
-      namespace_die = new_die (is_fortran ()
+      namespace_die = new_die (is_fortran () || is_dlang ()
 			       ? DW_TAG_module : DW_TAG_namespace,
 			       context_die, decl);
       /* For Fortran modules defined in different CU don't add src coords.  */
@@ -25272,7 +25284,7 @@ gen_decl_die (tree decl, tree origin, struct vlr_context *ctx,
       break;
 
     case CONST_DECL:
-      if (!is_fortran () && !is_ada ())
+      if (!is_fortran () && !is_ada () && !is_dlang ())
 	{
 	  /* The individual enumerators of an enum type get output when we output
 	     the Dwarf representation of the relevant enum type itself.  */
@@ -25820,7 +25832,7 @@ dwarf2out_decl (tree decl)
     case CONST_DECL:
       if (debug_info_level <= DINFO_LEVEL_TERSE)
 	return;
-      if (!is_fortran () && !is_ada ())
+      if (!is_fortran () && !is_ada () && !is_dlang ())
 	return;
       if (TREE_STATIC (decl) && decl_function_context (decl))
 	context_die = lookup_decl_die (DECL_CONTEXT (decl));
--- a/gcc/gcc.c
+++ b/gcc/gcc.c
@@ -1309,6 +1309,7 @@ static const struct compiler default_compilers[] =
   {".java", "#Java", 0, 0, 0}, {".class", "#Java", 0, 0, 0},
   {".zip", "#Java", 0, 0, 0}, {".jar", "#Java", 0, 0, 0},
   {".go", "#Go", 0, 1, 0},
+  {".d", "#D", 0, 1, 0}, {".dd", "#D", 0, 1, 0}, {".di", "#D", 0, 1, 0},
   /* Next come the entries for C.  */
   {".c", "@c", 0, 0, 1},
   {"@c",
